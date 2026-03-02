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

RUN TARGET_KVER=$(dnf repoquery --depends nvidia-open | grep kernel-devel-matched | awk -F'-matched-' '{print $2}') && \
    echo "NVIDIA Repo targets: $TARGET_KVER" && \
    dnf -y install \
        kernel-core-$TARGET_KVER \
        kernel-devel-$TARGET_KVER \
        kernel-modules-$TARGET_KVER \
        kernel-modules-extra-$TARGET_KVER && \
    rpm -qa | grep kernel-core | grep -v "$TARGET_KVER" | x86_64 xargs -r dnf -y remove && \
    dnf -y install nvidia-open && \
    dnf clean all

RUN TARGET_KVER=$(rpm -q --queryformat '%{VERSION}-%{RELEASE}.%{ARCH}\n' kernel-core | head -n 1) && \
    ls -l /usr/lib/modules/$TARGET_KVER/extra/nvidia/nvidia.ko || \
    (echo "Driver mismatch! No module found for $TARGET_KVER" && exit 1)

RUN dnf -y in virt-manager \
    libvirt-daemon-kvm \
    distrobox

RUN systemctl enable libvirtd

RUN TARGET_KVER=$(rpm -q --queryformat '%{VERSION}-%{RELEASE}.%{ARCH}\n' kernel-core | head -n 1) && \
    depmod -a $TARGET_KVER
