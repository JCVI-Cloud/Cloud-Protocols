# This script automates the convertion of an S3 based AMI to EBS based.
#
# CREDIT GOES TO http://www.full360.com/blogs/Migrating-Linux-S3-Based-AMI-EBS-Based-AMI
#

#!/bin/bash

mkdir /mnt/aws


#EC2 AMI Tools 
cd /tmp
wget http://s3.amazonaws.com/ec2-downloads/ec2-ami-tools.zip -O ec2-ami-tools.zip
mkdir /usr/local/EC2
cd /usr/local/EC2
unzip /tmp/ec2-ami-tools.zip
ln -s `find . -type d -name ec2-ami-tools-*` ec2-ami-tools
chmod -R go-rwsx ec2*
rm -rf /tmp/ec2*


#EC2 API Tools
cd /tmp
wget http://s3.amazonaws.com/ec2-downloads/ec2-api-tools.zip
cd /usr/local/EC2
unzip /tmp/ec2-api-tools.zip
ln -s `find . -type d -name ec2-api-tools*` ec2-api-tools
chmod -R go-rwsx ec2*
rm -rf /tmp/ec2*



cat > /mnt/aws/aws_paths.sh <<\EOF
#!/bin/bash
export EC2_PRIVATE_KEY=/mnt/ec2/pk.pem
export EC2_CERT=/mnt/ec2/cert.pem
export EC2_AMITOOL_HOME=/usr/local/EC2/ec2-ami-tools
export EC2_APITOOL_HOME=/usr/local/EC2/ec2-api-tools
export EC2_HOME=/usr/local/EC2/ec2-api-tools
export JAVA_HOME=/usr
export AMAZON_USER_ID=
export AWS_ACCESS_KEY_ID=
export AWS_SECRET_ACCESS_KEY=
PATH=$EC2_AMITOOL_HOME/bin:$PATH
EOF


chmod a+x /mnt/aws/aws_paths.sh

