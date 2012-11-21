#!/bin/bash
#this script will deploy current ami for each account listed in ec2/keys

accounts=`ls /ebs/ec2`
arch=`uname -i`
log=/ebs/log.bundle
version=$1

#sanity checks
if [ -z $1 ]
then 
  echo "Missing parameter: version number"
  exit 1
fi

#set bits variable according to system arch
if [ $arch = "i386" ]
then
  bits=32
else
  bits=64
fi

clear

cat /dev/null > $log

for i in $accounts
do
  source /ebs/ec2/$i/vars

#bundle
  echo
  echo -en '\E[40;32m'"\033[1m"`date +%H:%M:%S` Bundling for $i"\033[0m"
  echo `date +%H:%M:%S`" Bundling for $i" >> $log
  echo
  ec2-bundle-vol -e /ebs -p "baseV"$version"-"$bits.$i -d /mnt -k $EC2_PRIVATE_KEY -c $EC2_CERT -u $awsUID  -r $arch 
  if [ $? -ne 0 ]
  then
    echo
    echo -en '\E[40;31m'"\033[1m"`date +%H:%M:%S` Bundling for $i failed"\033[0m"
    echo
    echo `date +%H:%M:%S`" Bundle of $i failed " >> $log
  else
    echo -en '\E[40;32m'"\033[1m"`date +%H:%M:%S`" Bundling of $i completed successfully""\033[0m"
    echo
  fi

#upload
  manifest="baseV"$version"-"$bits.$i."manifest.xml"
  echo
  echo -en '\E[40;32m'"\033[1m"`date +%H:%M:%S` Uploading to $i:$awss3bucket"\033[0m"
  echo `date +%H:%M:%S`" Uploading to $i:$awss3bucket" >> $log
  echo
  ec2-upload-bundle -b $awss3bucket -a $awsAID -s $awsSID -m /mnt/$manifest
  if [ $? -ne 0 ]
  then
    echo
    echo -en '\E[40;31m'"\033[1m"`date +%H:%M:%S`" Upload to $i failed ""\033[0m"
    echo
    echo `date +%H:%M:%S`" Upload to $i failed " >> $log
    echo
    echo -en '\E[40;32m'"\033[1m"`date +%H:%M:%S` Re-Uploading to $i:$awss3bucket"\033[0m"
    echo `date +%H:%M:%S`" Re-Uploading to $i:$awss3bucket" >> $log
    echo
    ec2-upload-bundle -b $awss3bucket -a $awsAID -s $awsSID -m /mnt/$manifest
  else
    echo -en '\E[40;32m'"\033[1m"`date +%H:%M:%S`" Uppload to $i completed successfully""\033[0m"
    echo
  fi
  #rm -rf /mnt/"baseV"$version.$i*
done

echo 
echo -en '\E[05;40;32m'"\033[1m"`date +%H:%M:%S`" Deployment completed""\033[0m"
echo `date +%H:%M:%S`"  Completed" >> $log
echo

exit 0
