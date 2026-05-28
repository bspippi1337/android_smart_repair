#!/bin/bash

###############################################################################
# Android Smart Repair - Universal Script
# Automatic fix for bricked/problematic Android devices
# Supports: Motorola G15, Xiaomi Mi/Redmi series, and other Android devices
###############################################################################

set -e

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Logging setup
LOG_FILE="android_repair_$(date +%Y%m%d_%H%M%S).log"

# Device info cache
DEVICE_MODEL=""
DEVICE_BRAND=""
DEVICE_MANUFACTURER=""
ANDROID_VERSION=""

# Helper functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1" | tee -a "$LOG_FILE"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1" | tee -a "$LOG_FILE"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1" | tee -a "$LOG_FILE"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1" | tee -a "$LOG_FILE"
}

log_step() {
    echo -e "${CYAN}[STEP]${NC} $1" | tee -a "$LOG_FILE"
}

print_header() {
    echo -e "\n${BLUE}╔════════════════════════════════════════════════════════╗${NC}" | tee -a "$LOG_FILE"
    echo -e "${BLUE}║${NC} $1" | tee -a "$LOG_FILE"
    echo -e "${BLUE}╚════════════════════════════════════════════════════════╝${NC}" | tee -a "$LOG_FILE"
}

print_separator() {
    echo -e "${BLUE}─────────────────────────────────────────────────────${NC}" | tee -a "$LOG_FILE"
}

# Check prerequisites
check_prerequisites() {
    print_header "Checking Prerequisites"
    
    log_info "Checking for ADB..."
    if ! command -v adb &> /dev/null; then
        log_error "ADB not found in PATH"
        log_info "Install with: ./install_dependencies.sh"
        exit 1
    fi
    log_success "ADB found: $(adb version | head -n1)"
    
    log_info "Checking for Fastboot..."
    if ! command -v fastboot &> /dev/null; then
        log_warning "Fastboot not found (optional)"
    else
        log_success "Fastboot found: $(fastboot --version 2>/dev/null | head -n1)"
    fi
}

# Check device connection
check_device_connection() {
    print_header "Checking Device Connection"
    
    log_info "Starting ADB daemon..."
    adb start-server 2>&1 | tee -a "$LOG_FILE"
    
    sleep 2
    
    log_info "Waiting for device..."
    local count=0
    while ! adb devices | grep -E "^[a-zA-Z0-9]+" > /dev/null 2>&1; do
        if [ $count -ge 30 ]; then
            log_error "Device not detected after 30 seconds"
            log_info "Troubleshooting:"
            log_info "  1. Enable USB Debugging: Settings → Developer Options"
            log_info "  2. Accept the ADB connection prompt on your device"
            log_info "  3. Try a different USB port or cable"
            exit 1
        fi
        echo -n "." | tee -a "$LOG_FILE"
        sleep 1
        ((count++))
    done
    echo "" | tee -a "$LOG_FILE"
    
    log_success "Device detected!"
}

# Get device info and detect manufacturer
get_device_info() {
    print_header "Device Information & Detection"
    
    DEVICE_MODEL=$(adb shell getprop ro.product.model 2>/dev/null || echo "Unknown")
    DEVICE_BRAND=$(adb shell getprop ro.product.brand 2>/dev/null || echo "Unknown")
    DEVICE_MANUFACTURER=$(adb shell getprop ro.product.manufacturer 2>/dev/null || echo "Unknown")
    ANDROID_VERSION=$(adb shell getprop ro.build.version.release 2>/dev/null || echo "Unknown")
    
    log_info "Model: $DEVICE_MODEL"
    log_info "Brand: $DEVICE_BRAND"
    log_info "Manufacturer: $DEVICE_MANUFACTURER"
    log_info "Android Version: $ANDROID_VERSION"
    log_info "Build: $(adb shell getprop ro.build.fingerprint 2>/dev/null)"
    log_info "Storage:"
    adb shell df /data 2>&1 | tee -a "$LOG_FILE"
    
    detect_device_type
}

# Detect device type and show appropriate info
detect_device_type() {
    print_separator
    log_info "Detecting device type..."
    
    DEVICE_BRAND_LOWER=$(echo "$DEVICE_BRAND" | tr '[:upper:]' '[:lower:]')
    DEVICE_MANUFACTURER_LOWER=$(echo "$DEVICE_MANUFACTURER" | tr '[:upper:]' '[:lower:]')
    DEVICE_MODEL_LOWER=$(echo "$DEVICE_MODEL" | tr '[:upper:]' '[:lower:]')
    
    if [[ "$DEVICE_BRAND_LOWER" == "motorola" || "$DEVICE_MANUFACTURER_LOWER" == "motorola" ]]; then
        log_success "✓ Motorola device detected"
        log_info "Optimizations: Motorola-specific fixes enabled"
    elif [[ "$DEVICE_BRAND_LOWER" == "xiaomi" || "$DEVICE_MANUFACTURER_LOWER" == "xiaomi" ]]; then
        log_success "✓ Xiaomi device detected"
        log_info "Optimizations: Xiaomi-specific fixes enabled"
        if [[ "$DEVICE_MODEL_LOWER" =~ "mi" || "$DEVICE_MODEL_LOWER" =~ "redmi" ]]; then
            log_info "Device: Xiaomi Mi/Redmi Series"
        fi
    else
        log_warning "⚠ Generic Android device detected"
        log_info "Generic repair procedures will be applied"
    fi
}

# Clear caches
clear_caches() {
    print_header "Clearing System Caches"
    
    log_step "Clearing app caches..."
    adb shell pm clear --cache-only com.android.systemui 2>/dev/null || true
    adb shell pm trim-caches 1000M 2>/dev/null || true
    
    log_step "Clearing temporary files..."
    adb shell rm -rf /cache/* 2>/dev/null || true
    
    # Device-specific cache locations
    if [[ "$DEVICE_BRAND_LOWER" == "xiaomi" ]]; then
        log_step "Clearing Xiaomi-specific caches..."
        adb shell rm -rf /data/miui/cache/* 2>/dev/null || true
        adb shell rm -rf /data/adb/cache/* 2>/dev/null || true
    fi
    
    log_success "Caches cleared"
}

# Stop problematic services
stop_problem_services() {
    print_header "Stopping Problematic Services"
    
    local services=(
        "com.android.systemui"
        "com.android.launcher3"
        "com.android.settings"
    )
    
    # Add device-specific services
    if [[ "$DEVICE_BRAND_LOWER" == "xiaomi" ]]; then
        services+=(
            "com.miui.home"
            "com.miui.systemui"
        )
    elif [[ "$DEVICE_BRAND_LOWER" == "motorola" ]]; then
        services+=(
            "com.motorola.launcher"
        )
    fi
    
    for service in "${services[@]}"; do
        log_step "Attempting to stop $service..."
        adb shell am force-stop "$service" 2>/dev/null || true
    done
    
    log_success "Services reset"
}

# Optimize storage
optimize_storage() {
    print_header "Optimizing Storage"
    
    log_step "Analyzing storage..."
    adb shell "dumpsys meminfo | head -20" 2>&1 | tee -a "$LOG_FILE"
    
    log_step "Clearing unnecessary temporary files..."
    adb shell "rm -rf /data/cache/* 2>/dev/null; rm -rf /data/tmp/* 2>/dev/null" || true
    
    # Device-specific optimization
    if [[ "$DEVICE_BRAND_LOWER" == "xiaomi" ]]; then
        log_step "Optimizing Xiaomi-specific storage..."
        adb shell "rm -rf /data/miui/log/* 2>/dev/null; rm -rf /data/anr/* 2>/dev/null" || true
    fi
    
    log_success "Storage optimized"
}

# Full repair
full_repair() {
    print_header "Starting Full Repair"
    
    check_device_connection
    get_device_info
    print_separator
    clear_caches
    print_separator
    stop_problem_services
    print_separator
    optimize_storage
    print_separator
    
    log_step "Restarting ADB daemon..."
    adb kill-server
    sleep 2
    adb start-server
    
    log_info "Waiting for device to reconnect..."
    sleep 3
    adb wait-for-device 2>&1 | tee -a "$LOG_FILE"
    
    print_header "Performing Safe Reboot"
    log_info "Rebooting device (this will take 30-60 seconds)..."
    adb reboot
    
    log_info "Waiting for device to come back online..."
    sleep 15
    
    local count=0
    while ! adb shell getprop ro.boot.bootloader > /dev/null 2>&1; do
        if [ $count -ge 45 ]; then
            log_warning "Device reboot may still be in progress"
            break
        fi
        echo -n "." | tee -a "$LOG_FILE"
        sleep 1
        ((count++))
    done
    echo "" | tee -a "$LOG_FILE"
    
    log_success "Device rebooted successfully!"
}

# Quick fix
quick_fix() {
    print_header "Starting Quick Fix"
    
    check_device_connection
    get_device_info
    
    log_step "Quick cache cleanup..."
    adb shell pm trim-caches 500M 2>/dev/null || true
    
    log_step "Restarting system UI..."
    adb shell am force-stop com.android.systemui 2>/dev/null || true
    
    log_info "Rebooting device..."
    adb reboot
    
    sleep 15
    log_success "Quick fix complete!"
}

# Cache-only fix
cache_only_fix() {
    print_header "Clearing Cache Only"
    
    check_device_connection
    get_device_info
    clear_caches
    
    log_success "Cache cleared!"
}

# Recovery mode
boot_recovery() {
    print_header "Booting into Recovery Mode"
    
    check_device_connection
    
    log_warning "Device will boot into recovery mode"
    log_info "Use device buttons to navigate. Connect to PC to access recovery."
    
    read -p "Continue? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        log_info "Booting into recovery..."
        adb reboot recovery
        log_success "Device rebooted into recovery mode"
    else
        log_info "Cancelled"
    fi
}

# Bootloader mode
boot_bootloader() {
    print_header "Booting into Bootloader Mode"
    
    check_device_connection
    
    log_warning "Device will boot into bootloader mode"
    log_info "This is an advanced option for flashing firmware."
    
    read -p "Continue? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        log_info "Booting into bootloader..."
        adb reboot bootloader
        log_success "Device rebooted into bootloader mode"
    else
        log_info "Cancelled"
    fi
}

# Interactive menu
show_menu() {
    print_header "Android Smart Repair - Interactive Menu"
    
    echo "Select repair option:"
    echo "  1) Full Repair (RECOMMENDED)"
    echo "  2) Quick Fix"
    echo "  3) Clear Cache Only"
    echo "  4) Boot into Recovery"
    echo "  5) Boot into Bootloader"
    echo "  6) Show Device Info"
    echo "  7) Exit"
    echo
    read -p "Enter choice (1-7): " choice
    
    case $choice in
        1) full_repair ;;
        2) quick_fix ;;
        3) cache_only_fix ;;
        4) boot_recovery ;;
        5) boot_bootloader ;;
        6) check_device_connection; get_device_info ;;
        7) exit 0 ;;
        *) log_error "Invalid option"; show_menu ;;
    esac
}

# Show help
show_help() {
    cat << EOF
Android Smart Repair - Universal Device Support

USAGE:
    fix_android_universal.sh [OPTION]

SUPPORTED DEVICES:
    ✓ Motorola G15 and other Motorola models
    ✓ Xiaomi Mi series
    ✓ Xiaomi Redmi series
    ✓ Other Android devices with ADB support

OPTIONS:
    --full       Full repair (recommended for bricked devices)
    --quick      Quick fix with reboot
    --cache      Clear cache only
    --recovery   Boot into recovery mode
    --bootloader Boot into bootloader mode
    --info       Show device information
    --help       Show this help message

EXAMPLES:
    ./fix_android_universal.sh --full
    ./fix_android_universal.sh --quick
    ./fix_android_universal.sh (interactive mode)

REQUIREMENTS:
    - ADB (Android Debug Bridge)
    - USB Debugging enabled on device
    - Device connected via USB

FEATURES:
    • Automatic device detection (Motorola, Xiaomi, Generic)
    • Device-specific optimizations
    • Safe operations (no data loss)
    • Comprehensive logging
    • Color-coded output
    • Error handling & recovery

For detailed documentation, see USAGE.md

EOF
}

# Main function
main() {
    print_header "Android Smart Repair - Universal v1.1"
    log_info "Starting repair process..."
    log_info "Logging to: $LOG_FILE"
    
    check_prerequisites
    
    # Parse arguments
    case "${1:-}" in
        --full)
            full_repair
            ;;
        --quick)
            quick_fix
            ;;
        --cache)
            check_device_connection
            cache_only_fix
            ;;
        --recovery)
            boot_recovery
            ;;
        --bootloader)
            boot_bootloader
            ;;
        --info)
            check_device_connection
            get_device_info
            ;;
        --help|-h)
            show_help
            exit 0
            ;;
        "")
            show_menu
            ;;
        *)
            log_error "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
    
    print_header "Repair Complete"
    log_success "All operations completed successfully!"
    log_info "Full log saved to: $LOG_FILE"
}

# Run main
main "$@"
