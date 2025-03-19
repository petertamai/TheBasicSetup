# Server Setup Script

A comprehensive one-command server installation script that automatically sets up a complete development environment on Debian/Ubuntu systems.

![GitHub license](https://img.shields.io/badge/license-MIT-blue.svg)

## 🚀 Quick Install

**IMPORTANT**: Run this command from your home directory to avoid permission issues:

```bash
cd $HOME && curl -sSL https://raw.githubusercontent.com/petertamai/TheBasicSetup/main/setup.sh -o setup.sh && chmod +x setup.sh && bash setup.sh
```

## ✨ What Does This Script Install?

This script provides a complete development environment setup with:

- **Docker & Docker Compose** - With working permissions for immediate use
- **Caddy Server** - Modern web server with automatic HTTPS
- **Node.js & npm** - Latest LTS version
- **pnpm** - Fast, disk space efficient package manager
- **Miniconda** - Python environment management
- **caddyAddDomain Tool** - Custom utility for easy domain configuration

## 🛠️ Features

- **One-Command Setup**: Complete environment configuration with a single command
- **Smart User Management**: Creates or configures sudo users automatically
- **Bulletproof Permissions**: Fixes Docker permissions for immediate use
- **Intelligent Directory Handling**: Automatically uses the correct home directory
- **Interactive Domain Setup**: Easily configure domains with the included `caddyAddDomain` tool
- **User-Specific Installations**: Properly installs software for the correct user
- **Robust Error Handling**: Comprehensive logging and error management
- **Idempotent Design**: Can be run multiple times without issues
- **Security Best Practices**: Proper repository verification and secure installation methods
- **Colour-Coded Output**: Clear visual feedback during installation

## 📋 Detailed Component Overview

### Docker & Docker Compose
- Installs the latest stable Docker Engine
- Sets up Docker Compose for container orchestration
- Adds all users to the docker group
- **Fixes socket permissions for immediate use without logging out**

### Caddy Server
- Modern web server with automatic HTTPS
- Configured for optimal performance
- Includes custom domain management tools

### Node.js Ecosystem
- Installs Node.js LTS
- Sets up npm
- Installs pnpm for improved package management

### Miniconda
- User-specific Python environment management
- Conda initialization for your shell
- Ready for data science and Python development

### caddyAddDomain Tool
A custom utility that makes it easy to:
- Add new domains to your Caddy configuration
- Set up automatic HTTPS for your applications
- Configure reverse proxies to local services

## 🖥️ Using the caddyAddDomain Tool

After installation, you can easily configure new domains:

```bash
sudo caddyAddDomain  # sudo is required
```

The tool will:
1. Prompt for a domain name
2. Ask for the local port to proxy to
3. Check for conflicts with existing configurations
4. Update the Caddy configuration
5. Reload Caddy to apply changes
6. Display recent logs to confirm proper operation

## ⚙️ System Requirements

- Debian or Ubuntu-based system
- Sudo privileges on your account
- Internet connection for downloading packages

## 🔧 Troubleshooting

### Docker Commands Working Immediately
The script fixes Docker socket permissions, so Docker commands should work immediately without the need to log out or use group commands.

### Running the Script from the Wrong Directory
If you try to run the script from a directory where you don't have write permissions (like `/root`), the script will automatically:
- Detect the issue
- Change to your home directory
- Continue installation from there

### Miniconda Permissions
Miniconda is installed specifically for your user with proper permissions, avoiding any issues with root-owned files in your home directory.

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🤝 Contributing

Contributions, issues, and feature requests are welcome!

## 🔒 Security

This script follows security best practices:
- Uses official package repositories
- Verifies GPG keys before installation
- Implements proper error handling

## 📞 Contact

Created by [Piotr Tamulewicz](https://petertam.pro) - feel free to contact me at pt@petertam.pro