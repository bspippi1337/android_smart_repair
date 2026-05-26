#!/bin/bash

###############################################################################
# Android Smart Repair - Dependency Installation Script
# This script installs required tools (ADB and Fastboot)
###############################################################################

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_header() {
    echo -e "${BLUE}================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}================================${NC}"
}

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Detect OS
detect_os() {
    case "$(uname -s)" in
        Linux*)
            OS="Linux"
            ;;
        Darwin*)
            OS="macOS"
            ;;
        CYGWIN*)
            OS="Windows"
            ;;
        *)
            OS="Unknown"
            ;;
    esac
    echo "$OS"
}

# Install on Linux
install_linux() {
    print_header "Installing for Linux"
    
    log_info "Checking package manager..."
    
    if command -v apt-get &> /dev/null; then
        log_info "Using apt-get (Debian/Ubuntu)"
        sudo apt-get update
        sudo apt-get install -y android-tools-adb android-tools-fastboot
    elif command -v dnf &> /dev/null; then
        log_info "Using dnf (Fedora/RHEL)"
        sudo dnf install -y android-tools
    elif command -v pacman &> /dev/null; then
        log_info "Using pacman (Arch)"
        sudo pacman -S android-tools
    elif command -v zypper &> /dev/null; then
        log_info "Using zypper (openSUSE)"
        sudo zypper install -y android-tools
    else
        log_error "No supported package manager found"
        log_info "Please manually install android-tools-adb and android-tools-fastboot"
        return 1
    fi
    
    log_success "Installation complete"
}

# Install on macOS
install_macos() {
    print_header "Installing for macOS"
    
    if ! command -v brew &> /dev/null; then
        log_error "Homebrew not found"
        log_info "Install Homebrew first: https://brew.sh"
        return 1
    fi
    
    log_info "Using Homebrew to install Android tools..."
    brew install android-platform-tools
    
    log_success "Installation complete"
}

# Install on Windows
install_windows() {
    print_header "Installing for Windows"
    
    log_warning "Windows installation is semi-manual"
    log_info "Please follow these steps:"
    echo
    echo "1. Download Android SDK Platform Tools:"
    echo "   https://developer.android.com/studio/releases/platform-tools"
    echo
    echo "2. Extract the downloaded ZIP file"
    echo
    echo "3. Add to PATH:"
    echo "   - Open Settings > System > Environment Variables"
    echo "   - Click 'Edit the system environment variables'"
    echo "   - Click 'Environment Variables...'"
    echo "   - Under 'System variables', click 'New...'"
    echo "   - Variable name: PATH"
    echo "   - Variable value: C:\path\to\platform-tools"
    echo "   - Click OK on all dialogs"
    echo
    echo "4. Restart your terminal/PowerShell"
    echo
    echo "5. Verify installation:"
    echo "   adb --version"
    echo
    
    log_info "Alternatively, use Chocolatey if installed:"
    echo "   choco install android-platform-tools"
}

# Verify installation
verify_installation() {
    print_header "Verifying Installation"
    
    local adb_ok=true
    local fastboot_ok=true
    
    if command -v adb &> /dev/null; then
        log_success "ADB is installed: $(adb version | head -n1)"
    else
        log_error "ADB not found in PATH"
        adb_ok=false
    fi
    
    if command -v fastboot &> /dev/null; then
        log_success "Fastboot is installed: $(fastboot --version 2>/dev/null | head -n1)"
    else
        log_error "Fastboot not found in PATH"
        fastboot_ok=false
    fi
    
    if [ "$adb_ok" = true ] && [ "$fastboot_ok" = true ]; then
        log_success "All dependencies installed successfully!"
        return 0
    else
        log_error "Some dependencies are missing"
        return 1
    fi
}

# Main installation
main() {
    print_header "Android Smart Repair - Dependency Installer"
    
    OS=$(detect_os)
    log_info "Detected OS: $OS"
    
    case "$OS" in
        Linux)
            install_linux
            ;;
        macOS)
            install_macos
            ;;
        Windows)
            install_windows
            ;;
        *)
            log_error "Unsupported OS: $OS"
            exit 1
            ;;
    esac
    
    echo
    verify_installation
}

# Run main
main
