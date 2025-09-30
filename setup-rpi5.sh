#!/bin/bash
# Quick setup script for HPOExplorer on Raspberry Pi 5

set -e

echo "=================================="
echo "HPOExplorer - Raspberry Pi 5 Setup"
echo "=================================="
echo ""

# Check if running on ARM64
ARCH=$(uname -m)
if [ "$ARCH" != "aarch64" ] && [ "$ARCH" != "arm64" ]; then
    echo "Warning: This script is designed for ARM64 architecture (Raspberry Pi 5)"
    echo "Detected architecture: $ARCH"
    read -p "Do you want to continue anyway? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "Docker is not installed."
    read -p "Would you like to install Docker now? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "Installing Docker..."
        curl -fsSL https://get.docker.com -o get-docker.sh
        sudo sh get-docker.sh
        sudo usermod -aG docker $USER
        rm get-docker.sh
        echo "Docker installed successfully!"
        echo "Note: You may need to log out and back in for group changes to take effect."
    else
        echo "Docker is required. Please install Docker first."
        exit 1
    fi
fi

# Check if docker compose is available
if ! docker compose version &> /dev/null; then
    echo "Docker Compose plugin is not installed."
    read -p "Would you like to install Docker Compose plugin now? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "Installing Docker Compose plugin..."
        sudo apt-get update
        sudo apt-get install -y docker-compose-plugin
        echo "Docker Compose plugin installed successfully!"
    else
        echo "Docker Compose is required. Please install it first."
        exit 1
    fi
fi

# Create directory
INSTALL_DIR="${HOME}/hpoexplorer"
echo ""
echo "Installation directory: $INSTALL_DIR"
read -p "Press Enter to continue with this directory, or type a new path: " custom_dir
if [ ! -z "$custom_dir" ]; then
    INSTALL_DIR="$custom_dir"
fi

mkdir -p "$INSTALL_DIR"
cd "$INSTALL_DIR"

# Download files
echo ""
echo "Downloading HPOExplorer Docker configuration files..."

if command -v wget &> /dev/null; then
    DOWNLOAD_CMD="wget -q"
elif command -v curl &> /dev/null; then
    DOWNLOAD_CMD="curl -sO"
else
    echo "Error: Neither wget nor curl is available. Please install one of them."
    exit 1
fi

BASE_URL="https://raw.githubusercontent.com/neurogenomics/HPOExplorer/master"

echo "Downloading Dockerfile..."
if command -v wget &> /dev/null; then
    wget -q -O Dockerfile "$BASE_URL/Dockerfile"
else
    curl -sL -o Dockerfile "$BASE_URL/Dockerfile"
fi

echo "Downloading docker-compose.yml..."
if command -v wget &> /dev/null; then
    wget -q -O docker-compose.yml "$BASE_URL/docker-compose.yml"
else
    curl -sL -o docker-compose.yml "$BASE_URL/docker-compose.yml"
fi

echo "Downloading .dockerignore..."
if command -v wget &> /dev/null; then
    wget -q -O .dockerignore "$BASE_URL/.dockerignore"
else
    curl -sL -o .dockerignore "$BASE_URL/.dockerignore"
fi

# Ask for password
echo ""
read -p "Enter a password for RStudio (default: hpoexplorer): " password
if [ ! -z "$password" ]; then
    # Update password in docker-compose.yml
    if command -v sed &> /dev/null; then
        sed -i "s/PASSWORD=hpoexplorer/PASSWORD=$password/" docker-compose.yml
    fi
fi

# Create data directories
mkdir -p data projects

echo ""
echo "Setup complete!"
echo ""
echo "To build and start HPOExplorer, run:"
echo "  cd $INSTALL_DIR"
echo "  docker compose build"
echo "  docker compose up -d"
echo ""
echo "Note: Building the image may take 30-60 minutes on Raspberry Pi 5."
echo "After the container starts, access RStudio at:"
echo "  http://localhost:8900"
echo "  Username: rstudio"
echo "  Password: $password"
echo ""
read -p "Would you like to build and start now? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo ""
    echo "Building Docker image (this will take a while)..."
    docker compose build
    echo ""
    echo "Starting container..."
    docker compose up -d
    echo ""
    echo "Container started successfully!"
    echo "Access RStudio at: http://localhost:8900"
    echo "Username: rstudio"
    echo "Password: ${password:-hpoexplorer}"
fi

echo ""
echo "For more information, see:"
echo "  https://github.com/neurogenomics/HPOExplorer/blob/master/README_RPI5.md"
