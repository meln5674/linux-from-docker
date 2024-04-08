#!/bin/bash -xeu


# First, we have to create a file large enough to hold the raw volume we are about to create

# Disks are divided into blocks called "sectors", and our virtual device will default to this many bytes
sector_bytes=512

# We need a space to put the bootloader, so we will reserve 5M before the main partition for it and the
# GPT header, which includes the boot sector
boot_part_off=2048
boot_part_sectors=8192
root_part_off=$(bc <<< "${boot_part_off} + ${boot_part_sectors}")
boot_part_end=$(bc <<< "${root_part_off} - 1")

# Get the size of the root FS on the current LFS rootfs
rootfs_bytes=$(du -sb /mnt/lfs | awk '{ print $1 }')
# The files themselves are not the whole picture, we need space for the ext2 filesystme metadata,
# so we add an extra 100MiB (This can probably be shrunk later or autodetected)
root_part_bytes=$(bc <<< "${rootfs_bytes} + 1024 * 1024 * 100")
# Divide by the bytes per sector, and round up 
root_part_sectors=$(bc <<< "${root_part_bytes} / ${sector_bytes} + 1")
root_part_end=$(bc <<< "${boot_part_off} + ${boot_part_sectors} + ${root_part_sectors} - 1")
# Calculate the sectors needed for the GPT header, boot partition (plus offset), rootfs, and GPT footer
# GPT reserves the last 34 sectors for a backup of the header
gpt_footer_sectors=34
image_sectors=$(bc <<< "${boot_part_off} + ${boot_part_sectors} + ${root_part_sectors} + ${gpt_footer_sectors}")

# Create a file with that many bytes, all zeros
dd if=/dev/zero of=$LFS.img bs="${sector_bytes}" count="${image_sectors}"

# This fdisk script creates an image file with a GPT partition table
# with two partitions:
# the first from 2048 to 10240 sectors marked as a bootable BIOS Boot volume (A feature of GRUB)
# the second to the end of the volume marked as a linux filesystem
fdisk -w always $LFS.img <<EOF
p
g
n
1
${boot_part_off}
${boot_part_end}
t
4
p
n
2
${root_part_off}
${root_part_end}
t
2
20
p
w

EOF

# Supermin allows us to create a miniature VM based on the host container we run in,
# and mount in the LFS rootfs directory as well as mount in our newly partitioned file
# as a virtual disk
supermin --prepare bash coreutils util-linux mount -o supermin.d

# This script will run at startup instead of an init system, format the partition on
# the virtual disk, mount both the local filesystem containing the LFS rootfs, and the
# formatted virtual parition, and then copy the contents.
# Finally, we can chroot into the LFS, and run the grub installer on the virtual disk.
cat > init <<EOF
#!/bin/bash

set -xeu
echo 'Supermin Appliance Has Started'
mount -t proc none /proc
mount -t sysfs none /sys
mount -t devtmpfs none /dev
echo 1 > /proc/sys/kernel/sysrq
trap 'set -x; echo "Supermin Appliance is Requesting Shutdown"; echo s > /proc/sysrq-trigger; echo o > /proc/sysrq-trigger; while true; do sleep 3600; done; echo "This should never be seen, the appliance kernel is about to panic! You will need to manually stop the script, this will never exit"' EXIT

echo 'Mounting Source Filesystem'
mkdir -pv /mnt/lfs/{src,dest}
mount -t 9p lfs /mnt/lfs/src

echo 'Formatting Root Filesystem Partition'
mkdir -pv /mnt/lfs/src/{dev,proc,sys}
mount -t proc none /mnt/lfs/src/proc
mount -t sysfs none /mnt/lfs/src/sys
mount -t devtmpfs none /mnt/lfs/src/dev
chroot /mnt/lfs/src/ /usr/sbin/mkfs.ext2 /dev/sda2
umount /mnt/lfs/src/proc
umount /mnt/lfs/src/sys
umount /mnt/lfs/src/dev

echo 'Copying to Root Filesystem'
mount /dev/sda2 /mnt/lfs/dest
cp -av /mnt/lfs/src/. /mnt/lfs/dest/
# mkdir -pv /mnt/lfs/dest/usr
# cp -av /mnt/lfs/src/{dev,proc,sys} /mnt/lfs/dest/
# cp -av /mnt/lfs/src/usr/bin /mnt/lfs/dest/usr/bin
# cp -av /mnt/lfs/src/usr/sbin /mnt/lfs/dest/usr/sbin
# cp -av /mnt/lfs/src/usr/lib /mnt/lfs/dest/usr/lib
# cp -av /mnt/lfs/src/lib /mnt/lfs/dest/lib
umount /mnt/lfs/src

echo 'Installing Bootloader'
mkdir -pv /mnt/lfs/dest/{dev,proc,sys}
mount -t proc none /mnt/lfs/dest/proc
mount -t sysfs none /mnt/lfs/dest/sys
mount -t devtmpfs none /mnt/lfs/dest/dev
chroot /mnt/lfs/dest/ /usr/sbin/grub-install /dev/sda
umount /mnt/lfs/dest/proc
umount /mnt/lfs/dest/sys
umount /mnt/lfs/dest/dev
umount /mnt/lfs/dest


echo 'Creating success sentinel file'
mkdir -pv /mnt/lfs/signal
mount -t 9p lfs-signal /mnt/lfs/signal
touch /mnt/lfs/signal/done

EOF

chmod +x init
tar zcf supermin.d/init.tar.gz ./init

supermin --build supermin.d -f ext2 -o appliance.d

# After building the VM, we run it in QEMU
# The script is set to trigger a shutdown just before it exits.
qemu-system-x86_64 \
    -nodefaults -nographic \
    -m 2048 \
    -kernel appliance.d/kernel \
    -initrd appliance.d/initrd \
    -hda $LFS.img \
    -hdb appliance.d/root \
    -virtfs local,path=$LFS,mount_tag=lfs,security_model=passthrough \
    -virtfs local,path=$LFS_SRC,mount_tag=lfs-signal,security_model=passthrough \
    -serial stdio -append "console=ttyS0 root=/dev/sdb"

if ! [ -f $LFS_SRC/done ]; then
    echo 'The success sentinel file did not exist after the appliance exited, this indicates that the transfer did not succdeed, please check the logs above for the reason'
    exit 1
fi

# Once the image is ready, we can compress it to save space and remove the original
qemu-img convert -O qcow2 $LFS.img $LFS.qcow2

rm $LFS.img
