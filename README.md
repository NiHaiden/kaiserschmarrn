# 🥞 Kaiserschmarrn

> Tasty server image, built with Fedora Bootc and included cloud init support. Wozwa.

Kaiserschmarrn is a custom server operating system built on Fedora Bootc (version 42), designed for modern cloud-native deployments with built-in virtualization, containerization, and remote management capabilities.

## 🌟 Features

### Core Components
- **Fedora Bootc 42** - Image-based, bootable container foundation
- **Cloud-init** - First-boot configuration and cloud integration
- **Cockpit** - Web-based server management interface
- **systemd-resolved** - Modern DNS resolution

### Containerization & Virtualization
- **Docker CE** - Full Docker Engine support with BuildX and Compose plugins
- **Podman** - Container management with automatic updates
- **libvirt/KVM** - Full virtualization support with virt-install
- **QEMU Guest Agent** - Enhanced VM integration

### Networking
- **Tailscale** - Zero-config VPN and secure networking
- **NetworkManager** - Network configuration with WiFi support
- **firewalld** - Firewall management
- **systemd-resolved** - DNS resolution

### System Management
- **Cockpit modules**:
  - Machine management
  - NetworkManager integration
  - Podman integration
  - SELinux management
  - Storage management
- **just** - Command runner for automation
- **btop** & **htop** - System monitoring

## 🚀 Quick Start

### Building the Image

```bash
# Clone the repository
git clone https://github.com/NiHaiden/kaiserschmarrn.git
cd kaiserschmarrn

# Build the container image
podman build -t kaiserschmarrn .
```

### Deployment

```bash
# Deploy to disk
bootc install to-disk /dev/sdX

# Or install to existing root
bootc install to-existing-root
```

## 📦 Included Software

### Development & Utilities
- git-core
- rsync
- udisks2-lvm2
- xdg-user-dirs
- pcp-zeroconf

### Firmware & Drivers
- open-vm-tools (VMware integration)
- Complete wireless firmware suite

### Management Tools
- Cockpit web interface (enabled by default)
- SSH server (enabled by default)
- Tailscale VPN (installed, needs configuration)

## 🔧 Configuration

### System Users & Groups
The image includes pre-configured system groups:
- `docker` - Docker daemon access
- `dhcpd` - DHCP server
- `jackuser` - Jack audio
- `qat` - Intel QuickAssist Technology

### Automatic Updates
- **Bootc updates**: Weekly automatic checks and staged updates
- **Podman auto-update**: Timer enabled for container updates
- **RPM-OSTree**: Configured with `stage` policy and layer locking

### zRAM Configuration
Dynamic zRAM configuration: `min(RAM, 8192MB)`

## 🔒 Security Features

- SELinux enabled with Cockpit management
- firewalld for network security
- Automatic security updates via bootc
- SSH key-based authentication (recommended)

## 📚 Documentation

### Useful Commands

```bash
# Check bootc status
bootc status

# Update the system
sudo bootc update

# Switch to a different image
sudo bootc switch <image>

# Rollback to previous version
sudo bootc rollback
```

### Cockpit Access
After installation, access Cockpit at: `https://your-server:9090`

## 🤝 Contributing

Contributions are welcome! Please feel free to submit issues or pull requests.

## 📋 Topics

- bootc
- fedora
- fedora-bootc

Built with ❤️ using Fedora Bootc
