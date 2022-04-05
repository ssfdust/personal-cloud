#!/bin/sh
set -e
PROJECTPATH=$(cd `dirname $0`;cd ..;pwd)

if [ ! -s "${PROJECTPATH}/qemu/.rootpw" ];
then
    echo -n Root Password:
    read -s password
    echo ${password} >"${PROJECTPATH}/qemu/.rootpw"
fi

AttachProject(){
    m4 "-DPROJECTPATH=${PROJECTPATH}" "${PROJECTPATH}/qemu/virtfs.xml.m4" > /tmp/virtfs.xml
    virsh attach-device rocky /tmp/virtfs.xml --live
    rm -f /tmp/virtfs.xml
    expect "${PROJECTPATH}/qemu/command.exp" "mkdir /mnt/rocky" "${PROJECTPATH}/qemu/.rootpw"
    expect "${PROJECTPATH}/qemu/command.exp" "mount -t virtiofs host_rocky /mnt/rocky" "${PROJECTPATH}/qemu/.rootpw"
}

DetachProejct() {
    expect "${PROJECTPATH}/qemu/command.exp" "umount /mnt/rocky" "${PROJECTPATH}/qemu/.rootpw"
    m4 "-DPROJECTPATH=${PROJECTPATH}" "${PROJECTPATH}/qemu/virtfs.xml.m4" > /tmp/virtfs.xml
    virsh detach-device rocky /tmp/virtfs.xml --live
    rm -f /tmp/virtfs.xml
}

while getopts "da" arg
do
    case ${arg} in
        a)
            AttachProject
            ;;
        d)
            DetachProejct
            ;;
    esac
done
