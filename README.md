# Server Setup Script

A comprehensive one-command server installation script that automatically sets up a complete development environment on Debian/Ubuntu systems.

![GitHub license](https://img.shields.io/badge/license-MIT-blue.svg)

## 🚀 Quick Install

```bash
cd $HOME && curl -sSL https://raw.githubusercontent.com/petertamai/TheBasicSetup/refs/heads/main/setup.sh -o setup.sh && chmod +x setup.sh && bash setup.sh
```

## ✨ What Does This Script Install?

This script provides a complete development environment setup with:

- **Docker & Docker Compose** - With proper user permissions
- **Caddy Server** - Modern web server with automatic HTTPS
- **Node.js & npm** - Latest LTS version
- **pnpm** - Fast, disk space efficient package manager
- **Miniconda** - Python environment management
- **caddyAddDomain Tool** - Custom utility for easy domain configuration

## 🛠️ Features

- **One-Command Setup**: Complete environment configuration with a single command
- **Interactive Domain Setup**: Easily configure domains with the included `caddyAddDomain` tool
- **Robust Error Handling**: Comprehensive logging and error management
- **Idempotent Design**: Can be run multiple times without issues
- **Security Best Practices**: Proper repository verification and secure installation methods
- **Colour-Coded Output**: Clear visual feedback during installation

## 📋 Detailed Component Overview

### Docker & Docker Compose
- Installs the latest stable Docker Engine
- Sets up Docker Compose for container orchestration
- Adds the current user to the docker group (no sudo needed for docker commands)

### Caddy Server
- Modern web server with automatic HTTPS
- Configured for optimal performance
- Includes custom domain management tools

### Node.js Ecosystem
- Installs Node.js LTS
- Sets up npm
- Installs pnpm for improved package management

### Miniconda
- Python environment management
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
caddyAddDomain
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

### Docker Group Permissions
If Docker commands require sudo after installation, you may need to log out and back in for group changes to take effect, or run:

```bash
newgrp docker
```

### Conda Command Not Found
If the conda command isn't available after installation, initialize your shell with:

```bash
source ~/.bashrc
```

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