#!/usr/bin/env bash

set -xeuo pipefail

systemctl enable sshd
systemctl enable podman-auto-update.timer
systemctl enable --global podman-auto-update.timer

dnf -y remove \
  toolbox \
  yggdrasil


dnf5 install -y vulkan-tools mesa-vulkan-drivers

install_amd_rocm() {
  local rocm_el_major="${ROCM_EL_MAJOR:-10}"
  local rocm_version="${ROCM_VERSION:-latest}"
  local rocm_repo_baseurl="${ROCM_REPO_BASEURL:-https://repo.radeon.com/rocm/el${rocm_el_major}/${rocm_version}/main}"
  local rocm_packages_string="${ROCM_PACKAGES:-rocm-hip-runtime rocm-opencl-runtime hipcc rocminfo amd-smi-lib rocm-smi-lib}"
  local rocm_packages

  if [[ "$(uname -m)" != "x86_64" ]]; then
    echo "Skipping AMD ROCm install: repo.radeon.com ROCm RPMs for EL are x86_64-only."
    return 0
  fi

  read -r -a rocm_packages <<<"${rocm_packages_string}"

  cat >/etc/yum.repos.d/amd-rocm.repo <<EOF
[amd-rocm]
name=AMD ROCm ${rocm_version} for EL${rocm_el_major}
baseurl=${rocm_repo_baseurl}
enabled=1
priority=50
gpgcheck=1
gpgkey=https://repo.radeon.com/rocm/rocm.gpg.key
EOF

  dnf5 -y install --setopt=install_weak_deps=False \
    python3-setuptools \
    python3-wheel \
    environment-modules

  dnf5 -y install --setopt=install_weak_deps=False "${rocm_packages[@]}"

  cat >/etc/ld.so.conf.d/rocm.conf <<'EOF'
/opt/rocm/lib
/opt/rocm/lib64
EOF
  ldconfig

  cat >/etc/profile.d/rocm.sh <<'EOF'
# AMD ROCm user-space tools from repo.radeon.com.
if [ -d /opt/rocm/bin ]; then
    case ":${PATH}:" in
        *:/opt/rocm/bin:*) ;;
        *) export PATH="${PATH:+${PATH}:}/opt/rocm/bin" ;;
    esac
fi
EOF

  cat >/usr/lib/udev/rules.d/70-amdgpu-rocm.rules <<'EOF'
KERNEL=="kfd", GROUP="render", MODE="0660"
SUBSYSTEM=="drm", KERNEL=="renderD*", GROUP="render", MODE="0660"
EOF

  # Keep the image as the update source; do not let rpm-ostree/layering pull
  # ROCm updates independently from the bootc image build.
  sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/amd-rocm.repo
}

install_amd_rocm


dnf -y install --setopt=install_weak_deps=False \
  cockpit-machines \
  cockpit-networkmanager \
  cockpit-podman \
  cockpit-selinux \
  cockpit-storaged \
  cockpit-system \
  firewalld \
  git-core \
  libatomic \
  libvirt-client \
  libvirt-daemon \
  libvirt-daemon-kvm \
  NetworkManager-wifi \
  open-vm-tools \
  pcp-zeroconf \
  qemu-guest-agent \
  rsync \
  systemd-resolved \
  udisks2-lvm2 \
  virt-install \
  xdg-user-dirs \
  fish

systemctl enable firewalld


dnf5 install -y 'dnf5-command(config-manager)'

dnf5 config-manager addrepo --from-repofile=https://pkgs.tailscale.com/stable/fedora/tailscale.repo
dnf5 -y install tailscale
sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/tailscale.repo
systemctl enable tailscaled

dnf -y copr enable ublue-os/packages
dnf -y copr disable ublue-os/packages
dnf -y install --enablerepo="copr:copr.fedorainfracloud.org:ublue-os:packages" --setopt=install_weak_deps=False \
    ublue-os-libvirt-workarounds

dnf -y install https://github.com/fastfetch-cli/fastfetch/releases/download/2.50.2/fastfetch-linux-amd64.rpm
install -d /usr/local/bin
install -m 0755 /usr/share/kaiserschmarrn/fastfetch/fastfetch-wrapper /usr/local/bin/fastfetch

dnf -y install NetworkManager-wifi \
    atheros-firmware \
    brcmfmac-firmware \
    iwlegacy-firmware \
    iwlwifi-dvm-firmware \
    iwlwifi-mvm-firmware \
    mt7xxx-firmware \
    nxpwireless-firmware \
    realtek-firmware \
    tiwilink-firmware

dnf -y install @development-tools

dnf -y install just btop htop

# Apply IP Forwarding before installing Docker to prevent messing with LXC networking
sysctl -p

# Load iptable_nat module for docker-in-docker.
# See:
#   - https://github.com/ublue-os/bluefin/issues/2365
#   - https://github.com/devcontainers/features/issues/1235
mkdir -p /etc/modules-load.d && cat >>/etc/modules-load.d/ip_tables.conf <<EOF
iptable_nat
EOF
  
echo "Installing Docker CE..."  
# 4. Install Docker packages  
dnf5 -y install containerd.io docker-buildx-plugin docker-ce docker-ce-cli docker-compose-plugin
sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/docker-ce.repo

  
if rpm -q docker-ce >/dev/null; then
    systemctl enable docker.socket
fi



# rm -rf /etc/group
  
# 6. Disable Docker repository to prevent runtime updates    
echo "Docker CE installation complete!"

# Create sysusers.d entries for groups without systemd configuration
mkdir -p /usr/lib/sysusers.d
cat >/usr/lib/sysusers.d/jackuser.conf <<EOF
g jackuser - -
EOF

cat >/usr/lib/sysusers.d/qat.conf <<EOF
g qat - -
EOF

echo "Installing cloud init" 

dnf5 install -y cloud-init


tee /usr/lib/systemd/zram-generator.conf <<EOF
[zram0]
zram-size = min(ram, 8192)
EOF

sed -i 's|^ExecStart=.*|ExecStart=/usr/bin/bootc update --quiet|' /usr/lib/systemd/system/bootc-fetch-apply-updates.service
sed -i 's|^OnUnitInactiveSec=.*|OnUnitInactiveSec=7d\nPersistent=true|' /usr/lib/systemd/system/bootc-fetch-apply-updates.timer
sed -i 's|#AutomaticUpdatePolicy.*|AutomaticUpdatePolicy=stage|' /etc/rpm-ostreed.conf
sed -i 's|#LockLayering.*|LockLayering=true|' /etc/rpm-ostreed.conf

mv '/usr/share/doc/just/README.中文.md' '/usr/share/doc/just/README.zh-cn.md'

cat >/usr/lib/systemd/system-preset/91-resolved-default.preset <<'EOF'
enable systemd-resolved.service
EOF
cat >/usr/lib/tmpfiles.d/resolved-default.conf <<'EOF'
L /etc/resolv.conf - - - - ../run/systemd/resolve/stub-resolv.conf
EOF
systemctl preset systemd-resolved.service

KERNEL_VERSION="$(find "/usr/lib/modules" -maxdepth 1 -type d ! -path "/usr/lib/modules" -exec basename '{}' ';' | sort | tail -n 1)"
export DRACUT_NO_XATTR=1
dracut --no-hostonly --kver "$KERNEL_VERSION" --reproducible --zstd -v --add ostree -f "/usr/lib/modules/$KERNEL_VERSION/initramfs.img"
chmod 0600 "/usr/lib/modules/${KERNEL_VERSION}/initramfs.img"
# /run is a tmpfs mount during the build step, so runtime state is not persisted.
# Deleting systemd-resolved's live stub here is unnecessary and fails on GitHub Actions.
