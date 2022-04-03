# Personal Cloud Server

## Develop

### Create A virtual machine

1. Edit the virtual machine configuration

```bash
DISKSIZE=30GB
CPUNUM=4
RAM=4096
ISOSOURCE=/home/ssfdust/Downloads/ISO/Rocky-8.4-x86_64-minimal.iso
```

2. Create the kvm

```bash
cd qemu
bash create-kvm.sh
```
