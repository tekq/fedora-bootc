text
network --bootproto=dhcp
zerombr
clearpart --all --initlabel

part /boot/efi --fstype="efi" --size=512

part /boot --fstype="xfs" --size=2048

part btrfs.01 --grow --size=1 --encrypted --passphrase=<REPLACE-ME>

btrfs none --label=fedora_root btrfs.01
btrfs / --subvol --name=root fedora_root
btrfs /var --subvol --name=var fedora_root
btrfs /home --subvol --name=home fedora_root

bootc install to-disk --source ghcr.io/tekq/fedora-bootc:latest
