#!/bin/bash -xeu

make mrproper

# TODO: COPY/--mount this in
cat <<EOF >lfs.config
CONFIG_PSI=y
CONFIG_CGROUPS=y
CONFIG_MEMCG=y
CONFIG_RELOCATABLE=y
CONFIG_RANDOMIZE_BASE=y
CONFIG_STACKPROTECTOR=y
CONFIG_STACKPROTECTOR_STRONG=y
CONFIG_DEVTMPFS=y
CONFIG_DEVTMPFS_MOUNT=y
CONFIG_DRM_FBDEV_EMULATION=y
CONFIG_FRAMEBUFFER_CONSOLE=y
CONFIG_X86_X2APIC=y
CONFIG_PCI=y
CONFIG_PCI_MSI=y
CONFIG_IOMMU_SUPPORT=y
CONFIG_IRQ_REMAP=y
CONFIG_HIGHMEM64G=y
CONFIG_BLK_DEV_NVME=y
EOF

make defconfig
./scripts/kconfig/merge_config.sh .config lfs.config

make
make modules_install

mkdir -pv $LFS/boot $LFS/usr/share/doc
cp -iv arch/x86/boot/bzImage $LFS/boot/vmlinuz-6.7.4-lfs-12.1
cp -iv .config $LFS/boot/config-6.7.4
cp -r Documentation -T $LFS/usr/share/doc/linux-6.7.4

install -v -m755 -d $LFS/etc/modprobe.d
cat > $LFS/etc/modprobe.d/usb.conf << "EOF"
# Begin /etc/modprobe.d/usb.conf

install ohci_hcd /sbin/modprobe ehci_hcd ; /sbin/modprobe -i ohci_hcd ; true
install uhci_hcd /sbin/modprobe ehci_hcd ; /sbin/modprobe -i uhci_hcd ; true

# End /etc/modprobe.d/usb.conf
EOF

mv /lib/modules $LFS/lib/modules
