#!/bin/bash

# setup.sh - Comprehensive environment setup script
# Author: Piotr Tamulewicz (pt@petertam.pro)
# Website: https://petertam.pro/
# Date: March 19, 2025

# Set strict mode
set -e

# Colours for pretty output (optimized for both light and dark backgrounds)
RED='\033[1;31m'      # Bright Red - more visible on both dark and light
GREEN='\033[1;32m'    # Bright Green
YELLOW='\033[1;33m'   # Bright Yellow
BLUE='\033[1;36m'     # Cyan - better visibility than blue on dark backgrounds
NC='\033[0m'          # No Colour
BOLD='\033[1m'        # Bold text

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

# Error handling
handle_error() {
    log_error "An error occurred on line $1"
    exit 1
}

# Set up error trap
trap 'handle_error $LINENO' ERR

# Function to check if a command exists
command_exists() {
    command -v "$1" &> /dev/null
}

# Check installed items
check_installed_components() {
    log_info "Checking already installed components..."
    
    local components=""
    
    # Check Docker
    if command_exists docker; then
        components="${components}${GREEN}✓ Docker${NC} ($(docker --version | cut -d ' ' -f 3 | tr -d ','))\n"
    else
        components="${components}${RED}✗ Docker${NC} (Not installed)\n"
    fi
    
    # Check Docker Compose
    if command_exists docker-compose; then
        components="${components}${GREEN}✓ Docker Compose${NC} ($(docker-compose --version | awk '{print $3}' | tr -d ','))\n"
    else
        components="${components}${RED}✗ Docker Compose${NC} (Not installed)\n"
    fi
    
    # Check Caddy
    if command_exists caddy; then
        components="${components}${GREEN}✓ Caddy${NC} ($(caddy version | head -n1 | awk '{print $1}'))\n"
    else
        components="${components}${RED}✗ Caddy${NC} (Not installed)\n"
    fi
    
    # Check caddyAddDomain script
    if [ -x /usr/local/bin/caddyAddDomain ]; then
        components="${components}${GREEN}✓ caddyAddDomain${NC} (Installed)\n"
    else
        components="${components}${RED}✗ caddyAddDomain${NC} (Not installed)\n"
    fi
    
    # Check Node.js
    if command_exists node; then
        components="${components}${GREEN}✓ Node.js${NC} ($(node --version))\n"
    else
        components="${components}${RED}✗ Node.js${NC} (Not installed)\n"
    fi
    
    # Check npm
    if command_exists npm; then
        components="${components}${GREEN}✓ npm${NC} ($(npm --version))\n"
    else
        components="${components}${RED}✗ npm${NC} (Not installed)\n"
    fi
    
    # Check pnpm
    if command_exists pnpm; then
        components="${components}${GREEN}✓ pnpm${NC} ($(pnpm --version))\n"
    else
        components="${components}${RED}✗ pnpm${NC} (Not installed)\n"
    fi
    
    # Check Miniconda
    if [ -d "$HOME/miniconda3" ] || command_exists conda; then
        components="${components}${GREEN}✓ Miniconda${NC} (Installed)\n"
    else
        components="${components}${RED}✗ Miniconda${NC} (Not installed)\n"
    fi
    
    echo -e "$components"
}

# Update system packages
update_system() {
    log_info "Updating system packages..."
    sudo apt-get update -y
    sudo apt-get upgrade -y
    log_success "System packages updated"
}

# Install Docker and Docker Compose
install_docker() {
    if command_exists docker && command_exists docker-compose; then
        log_success "Docker and Docker Compose are already installed"
        
        # Make sure current user is in docker group
        if ! groups | grep -q docker; then
            log_warning "User $USER is not in the docker group. Adding now..."
            sudo usermod -aG docker "$USER"
            # Also fix docker socket permissions directly for immediate access
            sudo chmod 666 /var/run/docker.sock
            log_success "Docker permissions fixed immediately!"
        fi
        
        # Always ensure docker socket has right permissions for everyone
        sudo chmod 666 /var/run/docker.sock
        log_success "Docker socket permissions fixed for immediate use"
        
        return 0
    fi
    
    log_info "Installing Docker and Docker Compose..."
    
    # Install prerequisites
    sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common gnupg lsb-release
    
    # Add Docker's official GPG key
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    
    # Set up the stable repository for Ubuntu or Debian
    if command_exists lsb_release && [ "$(lsb_release -is)" = "Ubuntu" ]; then
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    elif command_exists lsb_release && [ "$(lsb_release -is)" = "Debian" ]; then
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    else
        log_error "Unsupported distribution. This script supports Ubuntu and Debian."
        exit 1
    fi
    
    # Install Docker Engine
    sudo apt-get update -y
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
    
    # Install Docker Compose
    sudo apt-get install -y docker-compose
    
    # Add current user to the docker group
    sudo usermod -aG docker "$USER"
    
    # Fix docker socket permissions directly for immediate access
    sudo chmod 666 /var/run/docker.sock
    
    log_success "Docker and Docker Compose installed"
    log_success "Docker socket permissions fixed for immediate use"
    echo
    
    return 0
}

# Install Caddy server
install_caddy() {
    if command_exists caddy; then
        log_success "Caddy is already installed"
        
        # Ensure Caddy service is enabled and running
        sudo systemctl enable caddy
        sudo systemctl restart caddy
        log_success "Caddy service enabled and restarted"
        return 0
    fi
    
    log_info "Installing Caddy server..."
    
    # Install Caddy prerequisites
    sudo apt-get install -y debian-keyring debian-archive-keyring apt-transport-https
    
    # Add Caddy repository
    curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | sudo gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg
    curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | sudo tee /etc/apt/sources.list.d/caddy-stable.list
    
    # Install Caddy
    sudo apt-get update -y
    sudo apt-get install -y caddy
    
    # Ensure Caddy service is enabled and running
    sudo systemctl enable caddy
    sudo systemctl start caddy
    
    log_success "Caddy installed and started"
    return 0
}

# Create caddyAddDomain script
create_caddy_domain_script() {
    if [ -x /usr/local/bin/caddyAddDomain ]; then
        log_success "caddyAddDomain script already exists"
        return 0
    fi
    
    log_info "Creating caddyAddDomain script..."
    
    # Create the script
    cat << 'EOF' | sudo tee /usr/local/bin/caddyAddDomain > /dev/null
#!/bin/bash

# caddyAddDomain - A wrapper script for Caddy to add domain configurations
# Author: Piotr Tamulewicz (pt@petertam.pro)
# Website: https://petertam.pro/

# Colours for pretty output (optimized for both light and dark backgrounds)
RED='\033[1;31m'      # Bright Red
GREEN='\033[1;32m'    # Bright Green
YELLOW='\033[1;33m'   # Bright Yellow
BLUE='\033[1;36m'     # Cyan - better visibility than blue on dark backgrounds
NC='\033[0m'          # No Colour
BOLD='\033[1m'        # Bold text

# Caddy configuration file
CADDY_FILE="/etc/caddy/Caddyfile"

# Check if Caddy is installed
if ! command -v caddy &> /dev/null; then
    echo -e "${RED}Error: Caddy is not installed.${NC}"
    exit 1
fi

# Check if user has permissions to modify Caddy file
if [ ! -w "$CADDY_FILE" ] && [ "$(id -u)" -ne 0 ]; then
    echo -e "${RED}Error: You need root permissions to modify $CADDY_FILE.${NC}"
    echo -e "${YELLOW}Please run this script with sudo.${NC}"
    exit 1
fi

# Prompt for domain and port
read -p "Enter domain name: " domain
if [ -z "$domain" ]; then
    echo -e "${RED}Error: Domain name cannot be empty.${NC}"
    exit 1
fi

read -p "Enter port number: " port
if ! [[ "$port" =~ ^[0-9]+$ ]]; then
    echo -e "${RED}Error: Port must be a number.${NC}"
    exit 1
fi

# Check if domain already exists in Caddyfile
if grep -q "^$domain {" "$CADDY_FILE"; then
    echo -e "${YELLOW}Warning: Domain $domain already exists in Caddyfile.${NC}"
    read -p "Do you want to overwrite it? (y/n): " overwrite
    if [[ ! "$overwrite" =~ ^[Yy]$ ]]; then
        echo -e "${BLUE}Operation cancelled.${NC}"
        exit 0
    fi
fi

# Check if port is already in use in Caddyfile
if grep -q "reverse_proxy http://localhost:$port" "$CADDY_FILE"; then
    echo -e "${YELLOW}Warning: Port $port is already in use in Caddyfile.${NC}"
    echo -e "${YELLOW}Existing configuration:${NC}"
    grep -B 2 -A 1 "reverse_proxy http://localhost:$port" "$CADDY_FILE"
    read -p "Do you want to continue anyway? (y/n): " continue
    if [[ ! "$continue" =~ ^[Yy]$ ]]; then
        echo -e "${BLUE}Operation cancelled.${NC}"
        exit 0
    fi
fi

# Create domain configuration
echo -e "${BLUE}Adding domain $domain with port $port to Caddyfile...${NC}"

# If domain exists, remove it first
if grep -q "^$domain {" "$CADDY_FILE"; then
    # Get start and end line numbers for existing domain block
    start_line=$(grep -n "^$domain {" "$CADDY_FILE" | cut -d: -f1)
    # Find the closing brace
    end_line=$(tail -n +$start_line "$CADDY_FILE" | grep -n "^}" | head -n 1 | cut -d: -f1)
    end_line=$((start_line + end_line - 1))
    
    # Remove the domain block
    sudo sed -i "${start_line},${end_line}d" "$CADDY_FILE"
fi

# Append new domain configuration
sudo bash -c "cat << EOF >> $CADDY_FILE
$domain {
	tls {
		on_demand
	}
	reverse_proxy http://localhost:$port
}
EOF"

# Format Caddyfile
echo -e "${BLUE}Formatting Caddyfile...${NC}"
sudo caddy fmt --overwrite "$CADDY_FILE"

# Reload Caddy configuration
echo -e "${BLUE}Reloading Caddy configuration...${NC}"
sudo caddy reload --config "$CADDY_FILE"

# Check for Caddy status
echo -e "${BLUE}Checking Caddy status...${NC}"
sudo systemctl status caddy | head -n 20

# Display last few lines of the Caddy log
echo -e "${BLUE}Recent Caddy logs:${NC}"
sudo journalctl -u caddy -n 10 --no-pager

echo -e "${GREEN}Domain $domain has been successfully configured to point to port $port.${NC}"
echo -e "${GREEN}You can access your site at https://$domain${NC}"
echo -e "\n${BOLD}How to Use:${NC}"
echo -e "1. Make sure your application is running on port $port"
echo -e "2. Make sure your domain's DNS points to this server"
echo -e "3. Caddy will automatically obtain SSL certificates when the domain is accessed"
EOF

    # Make the script executable
    sudo chmod +x /usr/local/bin/caddyAddDomain
    
    log_success "caddyAddDomain script created at /usr/local/bin/caddyAddDomain"
    return 0
}

# Install Node.js, npm, and pnpm
install_node() {
    local install_required=0
    
    if ! command_exists node || ! command_exists npm; then
        install_required=1
    fi
    
    if [ "$install_required" -eq 0 ] && ! command_exists pnpm; then
        log_info "Node.js and npm are already installed, but pnpm is missing. Installing pnpm..."
        npm install -g pnpm
        log_success "pnpm installed"
        pnpm_version=$(pnpm --version)
        log_info "pnpm version: $pnpm_version"
        return 0
    elif [ "$install_required" -eq 0 ]; then
        log_success "Node.js, npm, and pnpm are already installed"
        return 0
    fi
    
    log_info "Installing Node.js, npm, and pnpm..."
    
    # Install Node.js and npm using NodeSource
    curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
    sudo apt-get install -y nodejs
    
    log_success "Node.js and npm installed"
    node_version=$(node --version)
    npm_version=$(npm --version)
    log_info "Node.js version: $node_version, npm version: $npm_version"
    
    # Install pnpm
    npm install -g pnpm
    log_success "pnpm installed"
    pnpm_version=$(pnpm --version)
    log_info "pnpm version: $pnpm_version"
    
    return 0
}

# Install Miniconda
install_miniconda() {
    if [ -d "$HOME/miniconda3" ] || command_exists conda; then
        log_success "Miniconda is already installed"
        return 0
    fi
    
    log_info "Installing Miniconda..."
    
    # Download Miniconda installer
    miniconda_installer="Miniconda3-latest-Linux-$(uname -m).sh"
    wget "https://repo.anaconda.com/miniconda/${miniconda_installer}" -O ~/miniconda.sh
    
    # Run the installer in batch mode
    bash ~/miniconda.sh -b -p "$HOME/miniconda3"
    
    # Initialize conda for the shell
    "$HOME/miniconda3/bin/conda" init bash
    
    # Clean up
    rm ~/miniconda.sh
    
    log_success "Miniconda installed to $HOME/miniconda3"
    log_warning "You may need to restart your shell for conda to be available"
    return 0
}

# Print usage instructions
print_usage_instructions() {
    echo
    echo -e "${BOLD}${BLUE}=== Usage Instructions ===${NC}"
    echo
    echo -e "${BOLD}Docker Usage:${NC}"
    echo -e "Docker should work immediately with these commands:"
    echo -e "${GREEN}docker ps${NC} - List running containers"
    echo -e "${GREEN}docker-compose up -d${NC} - Start containers defined in docker-compose.yml"
    echo
    echo -e "${BOLD}Adding a Domain to Caddy:${NC}"
    echo -e "Run: ${GREEN}caddyAddDomain${NC}"
    echo -e "This will guide you through adding a domain that points to a local port."
    echo
    echo -e "${BOLD}Restarting Services:${NC}"
    echo -e "${GREEN}sudo systemctl restart caddy${NC} - Restart Caddy server"
    echo
    echo -e "${BOLD}First Time Setup:${NC}"
    echo -e "1. Deploy your application (e.g., on port 8080)"
    echo -e "2. Run ${GREEN}caddyAddDomain${NC} and enter your domain and port"
    echo -e "3. Ensure DNS for your domain points to this server"
    echo -e "4. Access your site at https://yourdomain.com"
    echo
}

# Main function
main() {
    echo -e "${BOLD}${BLUE}=====================================${NC}"
    echo -e "${BOLD}${BLUE}= Comprehensive Server Setup Script =${NC}"
    echo -e "${BOLD}${BLUE}=====================================${NC}"
    echo
    
    # Check if running as root without sudo
    if [ "$EUID" -eq 0 ] && [ -z "$SUDO_USER" ]; then
        log_warning "This script is being run as root without sudo."
        log_info "It's recommended to run this script as a regular user with sudo privileges."
        echo
        read -p "Do you want to setup a sudo user? (y/n): " setup_user_choice
        if [[ "$setup_user_choice" =~ ^[Yy]$ ]]; then
            # Get username
            read -p "Enter username: " username
            if [ -z "$username" ]; then
                log_error "Username cannot be empty"
                exit 1
            fi
            
            # Check if user already exists
            if id "$username" &>/dev/null; then
                log_warning "User $username already exists"
                
                # Check if user has sudo privileges
                if groups "$username" | grep -q '\bsudo\b'; then
                    log_info "User $username already has sudo privileges"
                else
                    log_warning "User $username does not have sudo privileges"
                    read -p "Add sudo privileges to this user? (y/n): " add_sudo
                    if [[ "$add_sudo" =~ ^[Yy]$ ]]; then
                        usermod -aG sudo "$username"
                        log_success "Sudo privileges added to user $username"
                    else
                        log_warning "User will not have sudo privileges. Some operations may fail."
                    fi
                fi
            else
                # Create the new user
                adduser "$username"
                
                # Add user to sudo group
                usermod -aG sudo "$username"
                log_success "User $username created with sudo privileges"
            fi
            
            # Copy script to user's home directory and make it executable
            script_path=$(realpath "$0")
            script_dir=$(dirname "$script_path")
            target_path="/home/$username/setup.sh"
            
            # Only copy if we're not already in the user's home directory
            if [ "$script_path" != "$target_path" ]; then
                cp "$script_path" "$target_path"
                chown "$username:$username" "$target_path"
                chmod +x "$target_path"
                log_success "Setup script copied to $target_path"
            else
                log_info "Script is already in $username's home directory"
                chown "$username:$username" "$script_path"
                chmod +x "$script_path"
            fi
            echo
            echo -e "${BOLD}${GREEN}=== EXACT COMMANDS TO RUN NEXT ===${NC}"
            echo -e "${BOLD}Run these commands to complete installation:${NC}"
            echo -e ""
            echo -e "    ${YELLOW}su - $username${NC}"
            echo -e "    ${YELLOW}sudo bash setup.sh${NC}"
            echo -e ""
            log_warning "DO NOT try to continue as root. Please follow the exact commands above."
            echo
            exit 0
        fi
    elif [ "$EUID" -ne 0 ]; then
        # Check if we have sudo privileges
        if ! sudo -v &>/dev/null; then
            log_error "This script requires sudo privileges but you don't have them."
            log_info "Please run this script as a user with sudo privileges."
            exit 1
        fi
        log_info "Running with sudo privileges. You may be prompted for your password."
    fi
    
    # Display already installed components
    echo -e "${BOLD}${BLUE}Currently installed components:${NC}"
    check_installed_components
    echo
    
    # Confirm installation
    read -p "Do you want to proceed with installation of missing components? (y/n): " confirm
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        log_info "Installation cancelled by user."
        exit 0
    fi
    
    # Update system packages
    update_system
    
    # Install required software
    install_docker
    install_caddy
    create_caddy_domain_script
    install_node
    install_miniconda
    
    # Print final summary
    echo
    log_success "${BOLD}==== Installation Summary ====${NC}"
    echo
    check_installed_components
    
    # Print usage instructions
    print_usage_instructions
    
    echo
    log_success "${BOLD}Installation process completed!${NC}"
    
    # Ensure Docker works immediately for other users too
    log_info "Ensuring Docker works for all created users..."
    
    # Loop through all the users we might have set up
    for user in $(ls /home); do
        if id "$user" &>/dev/null; then
            log_info "Setting up Docker permissions for user $user"
            
            # Add user to docker group
            sudo usermod -aG docker "$user"
            
            # Fix permissions on any docker config files in their home
            if [ -d "/home/$user/.docker" ]; then
                sudo chown -R "$user:$user" "/home/$user/.docker"
            fi
        fi
    done
    
    # Fix docker socket permissions directly for immediate access by anyone
    sudo chmod 666 /var/run/docker.sock
    echo
    log_info "For all changes to fully take effect, log out and log back in."
}

# Run the main function
main