FROM quay.io/fedora/fedora-silverblue:44

RUN dnf config-manager --set-disabled rawhide || true

RUN dnf -y install \
     https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
     https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

RUN dnf in -y akmods

RUN mv /usr/bin/akmodsbuild{,.bak} && \
    ln -s /usr/bin/{true,akmodsbuild}

RUN dnf -y install \ 
    akmod-nvidia \
    xorg-x11-drv-nvidia-cuda

RUN rm /usr/bin/akmodsbuild && \
    mv /usr/bin/akmodsbuild{.bak,}

RUN akmods --force --kernels $(rpm -qva | grep "kernel-devel" | head -n 1 | sed "s/kernel-devel-//")

RUN dnf -y in virt-manager \
    libvirt-daemon-kvm \
    distrobox

RUN systemctl enable libvirtd

RUN dnf clean all
