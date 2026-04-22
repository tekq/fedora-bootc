FROM quay.io/fedora/fedora-silverblue:44

RUN dnf -y install \
     https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
     https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm && \
     dnf clean all

RUN dnf -y in akmods

RUN mv /usr/bin/akmodsbuild{,.bak} && \
    ln -s /usr/bin/{true,akmodsbuild}

RUN dnf -y install \ 
    akmod-nvidia \
    xorg-x11-drv-nvidia-cuda && \
    dnf clean all

RUN rm /usr/bin/akmodsbuild && \
    mv /usr/bin/akmodsbuild{.bak,}

RUN akmods --force --kernels $(rpm -qva | grep "kernel-devel" | head -n 1 | sed "s/kernel-devel-//")

RUN mkdir -p /usr/lib/bootc/kargs.d/ && \
    echo 'kargs = ["rd.driver.blacklist=nouveau", "modprobe.blacklist=nouveau", "nouveau.modeset=0"]' > /usr/lib/bootc/kargs.d/99-blacklist-nouveau.toml

RUN mkdir -p /usr/lib/bootc/kargs.d/ && \
    echo 'kargs = ["quiet", "loglevel=3", "rd.udev.log_level=3"]' > /usr/lib/bootc/kargs.d/01-silent-boot.toml

RUN dnf -y in virt-manager \
    libvirt-daemon-kvm \
    distrobox \
    gnome-disk-utility && \
    dnf -y rm firefox \
    yelp \
    gnome-software \
    gnome-tour \
    gnome-system-monitor \
    malcontent-control \
    plymouth \
    rpm-ostree && \
    dnf clean all

RUN systemctl enable libvirtd && \
    systemctl mask NetworkManager-wait-online.service

RUN flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

RUN mkdir -p /etc/pki/containers /etc/containers/registries.d

COPY cosign.pub /etc/pki/containers/asmx2-bootc.pub

COPY policy.json /etc/containers/policy.json

COPY asmx2-bootc.yaml /etc/containers/registries.d/asmx2-bootc.yaml

RUN dnf clean all

