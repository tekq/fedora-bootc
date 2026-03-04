FROM quay.io/fedora/fedora-silverblue:44

RUN dnf config-manager --set-disabled rawhide || true

RUN dnf -y in virt-manager \
    libvirt-daemon-kvm \
    distrobox

RUN dnf -y install \
     https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
     https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

RUN systemctl enable libvirtd

RUN dnf clean all
