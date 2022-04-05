# Personal Cloud Server

Personal Cloud Server with SELinux Enabled.

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

```shell
# cd qemu
# bash create-kvm.sh
```

### Mount virtfs

#### Host

```shell
# sh qemu/use-hugesize.sh
# sh qemu/attach-project.sh -a
```

#### Guest

```shell
# mkdir /mnt/rocky
# mount -t virtiofs host_rocky /mnt/rocky
```

### Depoly

```
# sh run.sh
```

## Details

### Location

1. nextcloud server located at `/srv/www/nextcloud`
2. caddy files locate at `/etc/caddy/sites-enabled.d/*`
