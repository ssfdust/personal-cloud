#!/bin/sh

# Get latest kernel version
LATEST_VERSION=$(dnf list kernel* --installed | awk '{print $2}' | grep -v Packages | sort -V | uniq | tail -1)

# get kernels list except latest version
old_kernel_pakcages=$(dnf list kernel* --installed | grep -v Packages | grep -v "${LATEST_VERSION}" | awk '{print $1}' | sort | uniq | xargs)

dnf remove -y ${old_kernel_pakcages}
find /boot -name "grub.cfg" -exec grub2-mkconfig -o {} \;
