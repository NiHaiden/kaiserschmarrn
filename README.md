# Kaiserschmarrn

Kaiserschmarrn is a Fedora Bootc 43 server image with cloud-init, Cockpit, Docker, Podman, libvirt/KVM, Tailscale, and a custom Fastfetch profile.

## Included

- Fedora Bootc 43 base image
- Cloud-init for first boot provisioning
- Cockpit with machines, networking, storage, Podman, and SELinux modules
- Docker CE with Buildx and Compose
- Podman with auto-update timer enabled
- libvirt/KVM, `virt-install`, and `qemu-guest-agent`
- Tailscale, firewalld, NetworkManager, and Wi-Fi firmware
- `fastfetch`, `just`, `fish`, `btop`, and `htop`

## Build

```bash
git clone https://github.com/NiHaiden/kaiserschmarrn.git
cd kaiserschmarrn
podman build -t kaiserschmarrn .
```

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
- `systemd-resolved` is preset as the DNS resolver
- Bootc updates are staged weekly
- RPM-OSTree layering is locked
- zRAM is set to `min(ram, 8192)`
- Root and newly created users get a custom Fastfetch config and logo

## Useful Commands

```bash
fastfetch
bootc status
sudo bootc update
sudo bootc rollback
```
