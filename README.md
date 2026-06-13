# Kaiserschmarrn

Kaiserschmarrn is a Fedora Bootc 44 server image with cloud-init, Cockpit, Docker, Podman, libvirt/KVM, Tailscale, AMD ROCm, and a custom Fastfetch profile.

## Included

- Fedora Bootc 44 base image
- Cloud-init for first boot provisioning
- Cockpit with machines, networking, storage, Podman, and SELinux modules
- Docker CE with Buildx and Compose
- Podman with auto-update timer enabled
- libvirt/KVM, `virt-install`, and `qemu-guest-agent`
- Tailscale, firewalld, NetworkManager, and Wi-Fi firmware
- AMD ROCm from AMD's EL10 `repo.radeon.com` packages (`ROCM_VERSION=latest`; runtime packages plus `hipcc` by default)
- Fedora `@development-tools`
- `fastfetch`, `just`, `fish`, `btop`, and `htop`

## Build

```bash
git clone https://github.com/NiHaiden/kaiserschmarrn.git
cd kaiserschmarrn
podman build -t kaiserschmarrn .
```

ROCm build args:

```bash
podman build \
  --build-arg ROCM_VERSION=latest \
  --build-arg ROCM_EL_MAJOR=10 \
  --build-arg ROCM_PACKAGES="rocm-hip-runtime rocm-opencl-runtime hipcc rocminfo amd-smi-lib rocm-smi-lib" \
  -t kaiserschmarrn .
```

`ROCM_PACKAGES` defaults to the runtime/diagnostic set above plus `hipcc`. Use `ROCM_PACKAGES="rocm"` for AMD's full ROCm meta-package, but note that it is much larger.

To build an ISO locally:

```bash
just iso ghcr.io/nihaiden/kaiserschmarrn:latest
```

GitHub Actions builds the container image on push and schedule, then builds an ISO from the published image.

## Install

```bash
sudo bootc install to-disk /dev/sdX
sudo bootc update
```

After boot, Cockpit is available at `https://<host>:9090`.

## Defaults

- `sshd`, `firewalld`, `tailscaled`, and `docker.socket` are enabled
- AMD ROCm userspace is installed under `/opt/rocm`; `/opt/rocm/bin` is added to login shells and `/opt/rocm/lib{,64}` is added to the linker path
- GPU device access is assigned to the `render` group by udev; add users that need ROCm to `render` and `video`
- `systemd-resolved` is preset as the DNS resolver
- Bootc updates are staged weekly
- RPM-OSTree layering is locked
- zRAM is set to `min(ram, 8192)`
- `fastfetch` uses a custom Kaiserschmarrn wrapper, config, and logo by default

## Useful Commands

```bash
fastfetch
rocminfo
amd-smi version
bootc status
sudo bootc update
sudo bootc rollback
```
