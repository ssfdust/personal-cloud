#!/bin/sh
set -e

HUGESIZE=$(sysctl -n vm.nr_hugepages)
BASEDIR=$(cd `dirname $0`;pwd)

source "${BASEDIR}/config"

SetupHugePage() {
    cur_nr_hugepages=$(sysctl -n vm.nr_hugepages)
    hugepagesize=$(awk '/Hugepages/ {print $2}' /proc/meminfo)
    nr_hugepages=$((${RAM} * 1024 / ${hugepagesize}))
    if [[ ${cur_nr_hugepages} != ${nr_hugepages} ]];
    then
        echo "vm.nr_hugepages = ${hugepagesize}" >/etc/sysctl.d/40-hugepage.conf
        reboot
    fi
}

CreateVol(){
    virsh pool-define-as virtual dir - - - - /home/virtual/images
    virsh pool-build virtual
    virsh pool-start virtual
    virsh pool-autostart virtual
    virsh vol-create-as virtual rocky ${DISKSIZE} --format qcow2
}

CreateKvm(){
    local isofile=$(basename "${ISOSOURCE}")
    local qemuisofile="/var/lib/libvirt/images/${isofile}"
    [ -f "${qemuisofile}" ] || install -o libvirt-qemu -g libvirt-qemu -m644 "${ISOSOURCE}" "${qemuisofile}"
    virt-install --name rocky --os-variant rocky8.5 \
        --memorybacking hugepages=yes \
        --vcpus=${CPUNUM} \
        --cpu=host,numa.cell.unit=MiB,numa.cell.memAccess=shared,numa.cell.memory=${RAM} \
        --virt-type kvm \
        --network bridge=virtbr0 \
        --boot hd,cdrom,bootmenu.enable=on,loader=/usr/share/edk2-ovmf/x64/OVMF.fd \
        --location "${qemuisofile}" \
        --check path_in_use=off \
        --disk vol=virtual/rocky \
        --console pty,target_type=serial -x 'console=ttyS0,115200n8 serial' \
        --xml 'xpath.delete=./devices/graphics' \
        --xml './devices/graphics/@defaultMode=insecure' \
        --xml './devices/graphics/@autoport=no' \
        --xml './devices/graphics/@type=spice' \
        --xml "./devices/graphics/@port=5930" \
        --wait
}

ConfigureNetwork(){
    # Create dummy interface
    nmcli connection add type dummy ifname virtdummy0 con-name virtdummy0 ipv4.method disabled ipv6.method disabled connection.autoconnect no
    nmcli connection up virtdummy0
    # Create bridge interface
    nmcli connection add type bridge ifname virtbr0 con-name virtbr0 ipv4.method manual ipv4.addresses 192.168.0.244/30 ipv6.method disabled
    nmcli connection add type dummy con-name virtdummy0-br ifname virtdummy0 master virtbr0
    nmcli connection down virtdummy0
    nmcli connection up virtdummy0-br
}

SetupSysctl() {
    install -m644 "${BASEDIR}/network-forwarding.conf" /etc/sysctl.d/network-forwarding.conf
    sysctl -p /etc/sysctl.d/network-forwarding.conf
}

ConfigureFirewall() {
    firewall-cmd --permanent --zone=public --add-forward || :
    firewall-cmd --reload || :
}

ResetNetwork() {
    nmcli connection down virtdummy0-br virtdummy0 virtbr0 || true
    nmcli connection delete virtdummy0-br virtdummy0 virtbr0 || true
    firewall-cmd --permanent --zone=public --remove-forward || true
    firewall-cmd --reload || true
    rm -rf /etc/sysctl.d/network-forwarding.conf
}

RemoveStorage() {
    virsh vol-delete rocky virtual || true
    virsh pool-destroy virtual || true
    virsh pool-delete virtual || true
    virsh pool-undefine virtual || true
}

DeleteKvm() {
    virsh destroy rocky || true
    virsh undefine rocky --snapshots-metadata --managed-save || true
}

while getopts "iu" arg
do
    case ${arg} in
        i)
            SetupHugePage
            ConfigureNetwork
            CreateVol
            SetupSysctl
            ConfigureFirewall
            CreateKvm
            ;;
        u)
            DeleteKvm
            ResetNetwork
            RemoveStorage
            ;;
    esac
done
