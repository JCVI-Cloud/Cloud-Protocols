# Change these to suit your environment
vol_size=40
dev=/dev/sdp
desc="EBS Migration"


# Call the environment setup script
. /mnt/aws/aws_paths.sh

# Get basic info from instance meta-data
instance_id=`curl -s http://169.254.169.254/latest/meta-data/instance-id`
avail_zone=`curl -s \
http://169.254.169.254/latest/meta-data/placement/availability-zone`


# Create the Volume
vol=`ec2-create-volume -K "$EC2_PRIVATE_KEY" -C "$EC2_CERT" -z "$avail_zone"\
--size $vol_size| cut -f2`


# Attach the volume
ec2attvol "$vol" -K "$EC2_PRIVATE_KEY" -C "$EC2_CERT" -i "$instance_id" -d "$dev"
while [[ "$vol_status" != "attached"  ]];
do
vol_status=`ec2-describe-volumes -K "$EC2_PRIVATE_KEY" -C "$EC2_CERT" "$vol"\
| grep ATTACHMENT | cut -f5`
echo Status of "$vol" : $vol_status
done


# Prepare the volume
mkfs.ext3 "$dev"
mkdir -p /vol
mount "$dev" /vol
rm -rf /mnt/image*
rm -rf /mnt/img-mnt


# Use bundle to create a clean image (we will not upload)
ec2-bundle-vol -c $EC2_CERT -k $EC2_PRIVATE_KEY -u $AMAZON_USER_ID \
-e /vol -d /mnt


# take the clean image and install on the EBS Volume
mount -o loop /mnt/image /mnt/img-mnt
rsync -av /mnt/img-mnt/ /vol/


# Set the fstab up 
cat > /vol/etc/fstab << FSTABEOF
#
<file system>                                 <mount
point>   <type>  <options>       <dump> 
<pass>
proc                                            /proc           proc    defaults        0       0
/dev/sda3                                       None            swap    defaults        0       0
/dev/sdb                                       /               ext3    defaults        0       0
/dev/sda2                                       /mnt            ext3    defaults        0       0
FSTABEOF


# Snapshot the volume. Note the snapshot id for the registration step
umount /vol
ec2addsnap -C $EC2_CERT -K $EC2_PRIVATE_KEY -d $desc $vol


