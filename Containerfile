FROM quay.io/fedora/fedora-bootc:44


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
    pipewire \
    pipewire-pulseaudio \
    pipewire-alsa \
    && dnf clean all 

RUN dnf -y rm gnome-tour 

RUN mkdir -p /etc/flatpak/remotes.d && \
    curl --retry 3 -o /etc/flatpak/remotes.d/flathub.flatpakrepo "https://dl.flathub.org/repo/flathub.flatpakrepo"

RUN systemctl -f enable gdm

RUN dnf -y install \
     https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
     https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

RUN dnf -y install \ 
    akmod-nvidia \
    xorg-x11-drv-nvidia-cuda

RUN dnf -y in virt-manager \
    libvirt-daemon-kvm \
    distrobox

RUN systemctl enable libvirtd

RUN systemctl set-default graphical.target

RUN grubby --update-kernel=ALL --args='rd.driver.blacklist=nouveau' --args='modprobe.blacklist=nouveau'
