#!/bin/bash

###############################################################################
# USB Device Detector for Android Devices
# Detects bootloader modes: fastboot, FDL (Firehose), MTP, EDL, etc.
# Intelligently fuzzes protocols to determine device state
###############################################################################

set -e

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m'

# Logging
LOG_FILE="usb_detector_$(date +%Y%m%d_%H%M%S).log"

# Device state tracking
DETECTED_MODE=""
DETECTED_VENDOR_ID=""
DETECTED_PRODUCT_ID=""
DETECTED_SERIAL=""
DETECTED_MANUFACTURER=""
DETECTED_PRODUCT=""
DEVICE_BUS=""
DEVICE_PATH=""

# USB Vendor/Product ID Database for bootloader modes
declare -A BOOTLOADER_MODES=(
    # Fastboot modes
    ["0e8d:0003"]="fastboot"  # MediaTek fastboot
    ["05c6:9025"]="fastboot"  # Qualcomm fastboot (Gobi)
    ["18d1:d00d"]="fastboot"  # Google/Android fastboot
    ["0bb4:0fff"]="fastboot"  # HTC bootloader
    ["2717:ff00"]="fastboot"  # Xiaomi fastboot
    
    # EDL/Firehose modes (Qualcomm)
    ["05c6:900e"]="edl"       # Qualcomm EDL/Sahara
    ["05c6:9008"]="edl"       # Qualcomm EDL (Firehose)
    ["05c6:9048"]="edl"       # Qualcomm Firehose
    
    # MediaTek FDL/BROM modes
    ["0e8d:0000"]="fdl"       # MediaTek BROM/FDL mode
    ["0e8d:2000"]="fdl"       # MediaTek FDL
    
    # MTP modes
    ["05c6:f003"]="mtp"       # Qualcomm MTP
    ["0e8d:0005"]="mtp"       # MediaTek MTP
    ["18d1:4ee8"]="mtp"       # Google MTP
    ["2717:ff40"]="mtp"       # Xiaomi MTP
    
    # Motorola modes
    ["22b8:4e99"]="fastboot"  # Motorola fastboot
    ["22b8:2e82"]="mtp"       # Motorola MTP
    
    # Samsung modes
    ["04e8:5a0f"]="fastboot"  # Samsung fastboot
    ["04e8:6861"]="mtp"       # Samsung MTP
)

# Helper functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1" | tee -a "$LOG_FILE"
}

log_success() {
    echo -e "${GREEN}[✓]${NC} $1" | tee -a "$LOG_FILE"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1" | tee -a "$LOG_FILE"
}

log_warning() {
    echo -e "${YELLOW}[!]${NC} $1" | tee -a "$LOG_FILE"
}

log_debug() {
    echo -e "${MAGENTA}[DEBUG]${NC} $1" | tee -a "$LOG_FILE"
}

print_header() {
    echo -e "\n${CYAN}╔════════════════════════════════════════════════════════╗${NC}" | tee -a "$LOG_FILE"
    echo -e "${CYAN}║${NC} $1" | tee -a "$LOG_FILE"
    echo -e "${CYAN}╚════════════════════════════════════════════════════════╝${NC}" | tee -a "$LOG_FILE"
}

# Detect operating system
detect_os() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        echo "linux"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    elif [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" ]]; then
        echo "windows"
    else
        echo "unknown"
    fi
}

# Linux: Use lsusb to detect devices
detect_usb_linux() {
    print_header "Scanning USB Devices (Linux)"
    
    if ! command -v lsusb &> /dev/null; then
        log_error "lsusb not found. Install: sudo apt-get install usbutils"
        return 1
    fi
    
    log_info "Running: lsusb -v"
    local usb_output
    usb_output=$(lsusb -v 2>/dev/null || true)
    
    # Parse lsusb output to find Android/Motorola/Xiaomi/MediaTek devices
    while IFS= read -r line; do
        if [[ $line =~ "Bus "([0-9]+)" Device "([0-9]+)": ID "([0-9a-f]+)":"([0-9a-f]+)" ]]; then
            local bus="${BASH_REMATCH[1]}"
            local device="${BASH_REMATCH[2]}"
            local vendor_id="${BASH_REMATCH[3]}"
            local product_id="${BASH_REMATCH[4]}"
            local full_id="$vendor_id:$product_id"
            
            # Check if it's a known bootloader device
            if [[ -v BOOTLOADER_MODES[$full_id] ]]; then
                DETECTED_MODE="${BOOTLOADER_MODES[$full_id]}"
                DETECTED_VENDOR_ID="$vendor_id"
                DETECTED_PRODUCT_ID="$product_id"
                DEVICE_BUS="$bus"
                DEVICE_PATH="$device"
                
                log_success "Found device in ${BOOTLOADER_MODES[$full_id]} mode (USB $bus:$device)"
                log_info "Vendor ID: $vendor_id | Product ID: $product_id"
                return 0
            fi
        fi
    done <<< "$usb_output"
    
    # If no bootloader mode found, check for generic Android
    log_warning "No known bootloader mode detected via USB IDs"
    return 1
}

# macOS: Use system_profiler
detect_usb_macos() {
    print_header "Scanning USB Devices (macOS)"
    
    if ! command -v system_profiler &> /dev/null; then
        log_error "system_profiler not found"
        return 1
    fi
    
    log_info "Running: system_profiler SPUSBDataType"
    local usb_output
    usb_output=$(system_profiler SPUSBDataType 2>/dev/null || true)
    
    # Parse macOS USB output
    echo "$usb_output" | grep -A 5 "Vendor ID:" | while read -r line; do
        if [[ $line =~ "Vendor ID:"\ "0x"([0-9a-f]+) ]]; then
            DETECTED_VENDOR_ID="${BASH_REMATCH[1]}"
        fi
        if [[ $line =~ "Product ID:"\ "0x"([0-9a-f]+) ]]; then
            DETECTED_PRODUCT_ID="${BASH_REMATCH[1]}"
            local full_id="$DETECTED_VENDOR_ID:$DETECTED_PRODUCT_ID"
            
            if [[ -v BOOTLOADER_MODES[$full_id] ]]; then
                DETECTED_MODE="${BOOTLOADER_MODES[$full_id]}"
                log_success "Found device in ${BOOTLOADER_MODES[$full_id]} mode"
                return 0
            fi
        fi
    done
    
    log_warning "No known bootloader mode detected"
    return 1
}

# Windows: Use Get-PnpDevice
detect_usb_windows() {
    print_header "Scanning USB Devices (Windows)"
    
    if ! command -v powershell &> /dev/null; then
        log_error "PowerShell not found"
        return 1
    fi
    
    log_info "Running PowerShell: Get-PnpDevice -Class USB"
    local usb_output
    usb_output=$(powershell -Command "Get-PnpDevice -Class USB | Select-Object Name, InstanceId" 2>/dev/null || true)
    
    # Parse Windows USB output
    echo "$usb_output" | grep -i "android\|motorola\|xiaomi\|mediatek\|qualcomm" | head -5
    
    log_warning "Windows detection is basic. Consider using 'adb devices' instead."
    return 1
}

# Probe fastboot protocol
probe_fastboot() {
    print_header "Probing Fastboot Protocol"
    
    if ! command -v fastboot &> /dev/null; then
        log_warning "fastboot not found. Install Android Platform Tools."
        return 1
    fi
    
    log_info "Attempting: fastboot devices"
    local fb_output
    fb_output=$(fastboot devices 2>&1 || true)
    
    if [[ -n "$fb_output" && "$fb_output" != "* daemon not running; starting now at tcp:5037 *" ]]; then
        log_success "✓ Fastboot protocol active"
        DETECTED_MODE="fastboot"
        echo "$fb_output" | tee -a "$LOG_FILE"
        return 0
    else
        log_debug "No fastboot devices detected"
        return 1
    fi
}

# Probe ADB protocol
probe_adb() {
    print_header "Probing ADB Protocol"
    
    if ! command -v adb &> /dev/null; then
        log_warning "adb not found"
        return 1
    fi
    
    log_info "Starting ADB daemon..."
    adb start-server 2>&1 | tee -a "$LOG_FILE"
    sleep 1
    
    log_info "Attempting: adb devices"
    local adb_output
    adb_output=$(adb devices 2>&1 || true)
    
    if echo "$adb_output" | grep -E "^[a-zA-Z0-9]+" > /dev/null; then
        log_success "✓ ADB protocol active"
        DETECTED_MODE="adb"
        echo "$adb_output" | tee -a "$LOG_FILE"
        return 0
    else
        log_debug "No ADB devices detected"
        return 1
    fi
}

# Probe MTP (Media Transfer Protocol)
probe_mtp() {
    print_header "Probing MTP Protocol"
    
    if ! command -v libmtp-devices &> /dev/null && ! command -v mtp-probe &> /dev/null; then
        log_warning "MTP tools not found (libmtp-devices or mtp-probe)"
        log_info "Install: sudo apt-get install libmtp-tools"
        return 1
    fi
    
    log_info "Scanning for MTP devices..."
    
    if command -v libmtp-devices &> /dev/null; then
        local mtp_output
        mtp_output=$(libmtp-devices 2>&1 || true)
        if [[ -n "$mtp_output" && "$mtp_output" != "No MTP devices found"* ]]; then
            log_success "✓ MTP protocol active"
            DETECTED_MODE="mtp"
            echo "$mtp_output" | tee -a "$LOG_FILE"
            return 0
        fi
    fi
    
    log_debug "No MTP devices detected"
    return 1
}

# Probe FDL/MediaTek BROM
probe_fdl() {
    print_header "Probing FDL/MediaTek BROM Protocol"
    
    log_info "Checking for MediaTek FDL devices via USB..."
    
    if command -v lsusb &> /dev/null; then
        local fdl_devices
        fdl_devices=$(lsusb | grep -i "mediatek\|0e8d" || true)
        
        if [[ -n "$fdl_devices" ]]; then
            # Check for FDL-specific USB IDs
            if echo "$fdl_devices" | grep -q "0e8d:0000\|0e8d:2000"; then
                log_success "✓ FDL/BROM protocol detected"
                DETECTED_MODE="fdl"
                echo "$fdl_devices" | tee -a "$LOG_FILE"
                return 0
            fi
        fi
    fi
    
    log_debug "No FDL/BROM devices detected"
    return 1
}

# Probe EDL/Firehose (Qualcomm)
probe_edl() {
    print_header "Probing EDL/Firehose Protocol (Qualcomm)"
    
    log_info "Checking for Qualcomm EDL devices via USB..."
    
    if command -v lsusb &> /dev/null; then
        local edl_devices
        edl_devices=$(lsusb | grep -i "qualcomm\|05c6" || true)
        
        if [[ -n "$edl_devices" ]]; then
            # Check for EDL-specific USB IDs
            if echo "$edl_devices" | grep -q "05c6:900e\|05c6:9008\|05c6:9048"; then
                log_success "✓ EDL/Firehose protocol detected"
                DETECTED_MODE="edl"
                echo "$edl_devices" | tee -a "$LOG_FILE"
                return 0
            fi
        fi
    fi
    
    log_debug "No EDL/Firehose devices detected"
    return 1
}

# Main detection routine
main() {
    print_header "Android USB Device Mode Detector"
    
    local os_type
    os_type=$(detect_os)
    log_info "Operating System: $os_type"
    
    # Phase 1: USB Hardware Detection
    log_info "═══ PHASE 1: USB Hardware Detection ═══"
    
    case "$os_type" in
        linux)
            detect_usb_linux || true
            ;;
        macos)
            detect_usb_macos || true
            ;;
        windows)
            detect_usb_windows || true
            ;;
        *)
            log_warning "Unknown OS: $os_type"
            ;;
    esac
    
    # Phase 2: Protocol Probing (Intelligent Fuzzing)
    log_info ""
    log_info "═══ PHASE 2: Protocol Fuzzing/Probing ═══"
    
    # Try protocols in order of likelihood
    if [[ -z "$DETECTED_MODE" ]]; then
        log_info "No mode detected from USB IDs. Fuzzing protocols..."
        
        probe_fastboot || true
        probe_adb || true
        probe_mtp || true
        probe_fdl || true
        probe_edl || true
    fi
    
    # Phase 3: Summary
    print_header "Detection Summary"
    
    if [[ -n "$DETECTED_MODE" ]]; then
        log_success "Device Mode: $DETECTED_MODE"
        log_info "Vendor ID: $DETECTED_VENDOR_ID"
        log_info "Product ID: $DETECTED_PRODUCT_ID"
        
        # Provide recommendations
        echo ""
        log_info "═══ RECOMMENDATIONS ═══"
        case "$DETECTED_MODE" in
            fastboot)
                log_info "Device in FASTBOOT mode"
                log_info "→ Use: fastboot flash/erase commands"
                log_info "→ Next: fastboot reboot OR fastboot boot recovery.img"
                ;;
            adb)
                log_info "Device in ANDROID OS mode (ADB)"
                log_info "→ Use: adb shell/push/pull commands"
                log_info "→ Next: Run device repair scripts"
                ;;
            mtp)
                log_info "Device in MTP (Media Transfer) mode"
                log_info "→ Use: libmtp-* tools or file manager"
                log_info "→ Next: Boot to bootloader or enable USB Debugging"
                ;;
            fdl)
                log_info "Device in FDL/BROM mode (MediaTek)"
                log_info "→ Use: MediaTek BROM tools (mtk-client)"
                log_info "→ Next: Flash ROM via MediaTek tools"
                ;;
            edl)
                log_info "Device in EDL/Firehose mode (Qualcomm)"
                log_info "→ Use: Qualcomm Firehose tools"
                log_info "→ Next: Flash via Firehose protocol"
                ;;
        esac
    else
        log_error "No device mode detected"
        log_info "Troubleshooting:"
        log_info "1. Ensure device is connected via USB"
        log_info "2. Check USB cable and port"
        log_info "3. Enable USB Debugging if in Android OS"
        log_info "4. Try different USB port or cable"
        log_info "5. Check logs: cat $LOG_FILE"
    fi
    
    echo ""
    log_info "Full log saved to: $LOG_FILE"
}

# Run
main "$@"
