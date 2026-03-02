FROM quay.io/centos-bootc/centos-bootc:stream10


RUN dnf -y install \
    gnome-shell \
    gdm \
    gnome-control-center \
    nautilus \
    redhat-display-vf-fonts \
    redhat-text-vf-fonts \
    redhat-mono-vf-fonts \
    google-noto-sans-vf-fonts \
    google-noto-sans-math-fonts \
    google-noto-sans-symbols-vf-fonts \
    google-noto-color-emoji-fonts \
    default-fonts-core-sans \
    ptyxis \
    flatpak \
    mesa-dri-drivers \
    pipewire \
    pipewire-pulseaudio \
    pipewire-alsa \
    && dnf clean all 

RUN dnf -y rm gnome-tour 

RUN mkdir -p /etc/flatpak/remotes.d && \
    curl --retry 3 -o /etc/flatpak/remotes.d/flathub.flatpakrepo "https://dl.flathub.org/repo/flathub.flatpakrepo"

RUN systemctl -f enable gdm

RUN dnf -y install --nogpgcheck \ 
    https://dl.fedoraproject.org/pub/epel/epel-release-latest-$(rpm -E %rhel).noarch.rpm

RUN dnf -y install --nogpgcheck \ 
    https://mirrors.rpmfusion.org/free/el/rpmfusion-free-release-$(rpm -E %rhel).noarch.rpm \
    https://mirrors.rpmfusion.org/nonfree/el/rpmfusion-nonfree-release-$(rpm -E %rhel).noarch.rpm

RUN /usr/bin/crb enable

RUN dnf -y config-manager --add-repo \
    https://developer.download.nvidia.com/compute/cuda/repos/rhel10/x86_64/cuda-rhel10.repo

RUN dnf -y update kernel* && \
    dnf -y install kernel-devel kernel-headers && \
    KVER=$(rpm -q --queryformat '%{VERSION}-%{RELEASE}.%{ARCH}\n' kernel-core | sort -V | tail -n 1) && \
    dnf -y install nvidia-open && \
    dnf clean all

RUN KVER=$(rpm -q --queryformat '%{VERSION}-%{RELEASE}.%{ARCH}\n' kernel-core | sort -V | tail -n 1) && \
    ls -l /usr/lib/modules/$KVER/extra/nvidia/nvidia.ko

RUN dnf -y in virt-manager \
    libvirt-daemon-kvm \
    distrobox

RUN systemctl enable libvirtd
