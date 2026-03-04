FROM ghcr.io/ublue-os/bluefin-nvidia:44

RUN dnf config-manager --set-disabled rawhide || true

RUN dnf -y in virt-manager \
    libvirt-daemon-kvm \
    distrobox

RUN systemctl enable libvirtd

RUN dnf clean all
