FROM quay.io/fedora/fedora-silverblue:44

RUN systemctl set-default graphical.target

RUN mkdir -p /usr/lib/bootc/kargs.d/ && \
    echo 'kargs = ["rd.driver.blacklist=nouveau", "modprobe.blacklist=nouveau", "nouveau.modeset=0"]' > /usr/lib/bootc/kargs.d/99-blacklist-nouveau.toml

RUN mkdir -p /usr/lib/bootc/kargs.d/ && \
    echo 'kargs = ["quiet", "rhgb", "loglevel=3", "rd.udev.log_level=3", "vt.global_cursor_default=0"]' > /usr/lib/bootc/kargs.d/01-silent-boot.toml

RUN dnf -y install \
     https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
     https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

RUN dnf -y install \ 
    akmod-nvidia \
    xorg-x11-drv-nvidia-cuda

RUN dnf -y in virt-manager \
    libvirt-daemon-kvm \
    distrobox

RUN akmods --force --kernels $(rpm -qva | grep "kernel-devel" | head -n 1 | sed "s/kernel-devel-//")

RUN systemctl enable libvirtd

RUN dnf clean all
