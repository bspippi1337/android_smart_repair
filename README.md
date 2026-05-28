#!/bin/bash

# Android Smart Repair
# Automatic fix for any trouble with your Android phone (Motorola G15, Xiaomi Mi/Redmi, and more)

## 🎯 Purpose

**Android Smart Repair** is a foolproof, bulletproof bash script that automatically fixes bricked and problematic Android devices with a single command. No technical knowledge required.

Now with **universal device support** for Motorola, Xiaomi, MediaTek, and other Android manufacturers!

## ✨ Features

- ✅ **Fully Automated** - One command fixes everything
- ✅ **Universal Device Support** - Works with Motorola, Xiaomi, MediaTek, and other Android devices
- ✅ **Automatic Device Detection** - Identifies your device and applies specific optimizations
- ✅ **USB Device Recognition** - Detects devices via USB vendor/product IDs
- ✅ **Safe Operations** - No data loss, no system file modification
- ✅ **Multiple Repair Modes** - Full, quick, or cache-only repair
- ✅ **Comprehensive Logging** - Track every operation
- ✅ **Error Handling** - Graceful error recovery
- ✅ **Color-coded Output** - Clear, readable progress
- ✅ **Cross-Platform** - Works on Linux, macOS, Windows (WSL)
- ✅ **Advanced Options** - For power users

## 📱 Supported Devices

- **Motorola:** G15, and other Motorola models with ADB support
- **Xiaomi:** Mi series (Mi 9, Mi 10, etc.)
- **Xiaomi:** Redmi series (Redmi Note 9, Redmi 9, etc.)
- **MediaTek:** Devices with MediaTek chipsets (MT6227, MT6737, etc.)
- **Generic:** Any Android device with ADB support (will use generic repair procedures)

## 🔌 USB Device Support

The script automatically detects devices via USB:

```
MediaTek Inc. MT6227 phone (ID: 0e8d:0003)
MediaTek Inc. MT6737 (ID: 0e8d:2007)
Xiaomi Mi/Redmi devices
Motorola devices
And many more...
```

## 🚀 Quick Start

```bash
# 1. Install dependencies (one time only)
chmod +x install_dependencies.sh
./install_dependencies.sh

# 2. Enable USB Debugging on your device:
#    Settings → About Phone → Build Number (tap 7 times) 
#    → Developer Options → USB Debugging (enable)

# 3. Connect device via USB and run:
chmod +x fix_android_universal.sh
./fix_android_universal.sh --full
```

**That's it!** Your device will be fixed. ✓

## 📋 What It Fixes

- 🔄 Frozen or slow devices
- 💾 Low storage space
- ⚡ Battery drain
- 🔗 Bootloop issues
- 💥 Random reboots
- 🛑 Unresponsive apps
- 🔧 System corruption

## 📖 Usage

### Universal Script (Recommended)

```bash
./fix_android_universal.sh --full       # Complete repair (recommended)
./fix_android_universal.sh --cache      # Cache cleanup only
./fix_android_universal.sh --quick      # Quick fix with reboot
./fix_android_universal.sh --recovery   # Boot into recovery mode
./fix_android_universal.sh --help       # Show help
```

### Legacy Device-Specific Scripts

For backward compatibility, device-specific scripts are still available:

```bash
./fix_motorola_g15.sh --full            # Motorola G15 specific
```

### Interactive Mode

```bash
./fix_android_universal.sh
```

Launch the interactive menu for step-by-step repair options.

## 🔍 Device Detection

The universal script automatically detects your device and applies specific optimizations:

- **Motorola devices:** Motorola-specific caches and services
- **Xiaomi devices:** MIUI-specific caches, logs, and system optimizations
- **MediaTek devices:** MediaTek firmware and chipset optimizations
- **Generic devices:** Standard Android repair procedures

## 📚 Documentation

- **[USAGE.md](USAGE.md)** - Detailed usage guide, troubleshooting, and advanced options
- **[LICENSE](LICENSE)** - MIT License

## 🔧 What You Need

### Required
- ADB (Android Debug Bridge)
- USB cable
- USB Debugging enabled on device

### Supported Devices
- ✅ Motorola G15 (and other Motorola models)
- ✅ Xiaomi Mi series
- ✅ Xiaomi Redmi series
- ✅ MediaTek MT series phones
- ✅ Other Android devices (with ADB support)

## ⚠️ Important Notes

### SAFE Operations
- Clears temporary caches (recoverable)
- Stops stuck services (resume on reboot)
- Optimizes storage safely

### NOT Modified
- ❌ Your photos, videos, messages
- ❌ Installed apps or data
- ❌ System files
- ❌ Bootloader

## 📝 Log Files

All operations logged automatically:
```
android_repair_YYYYMMDD_HHMMSS.log
```

View logs:
```bash
cat android_repair_*.log | tail -50
```

## 🛠️ Installation

### Automatic Installation
```bash
chmod +x install_dependencies.sh
./install_dependencies.sh
```

Supports: Ubuntu, Debian, Fedora, RHEL, Arch, macOS, Windows

### Manual Installation

**Linux (Ubuntu/Debian):**
```bash
sudo apt-get install android-tools-adb android-tools-fastboot
```

**macOS:**
```bash
brew install android-platform-tools
```

**Windows:**
Download: https://developer.android.com/studio/releases/platform-tools

## ❓ FAQ

**Q: Will this delete my data?**  
A: No. Only temporary files and caches are cleared. Your data is safe.

**Q: How long does it take?**  
A: 5-10 minutes for full repair, 2-3 minutes for quick fix.

**Q: Do I need root?**  
A: No. Standard ADB access is sufficient.

**Q: What if it fails?**  
A: Logs show exactly what happened. Check USAGE.md troubleshooting section.

**Q: Can I use this on my specific device?**  
A: If it runs Android and supports ADB, yes! Use `fix_android_universal.sh` for automatic device detection.

**Q: Can I repair MediaTek devices?**  
A: Yes! MediaTek devices (like MT6227, MT6737 phones) are fully supported with device-specific optimizations.

## 📄 License

MIT License - Free to use, modify, and distribute.

## 🎓 How It Works

```
┌─ USB Device Recognition (vendor:product IDs)
├─ Prerequisites Check (ADB, Fastboot)
├─ Device Connection Validation
├─ Device Type Detection (Motorola/Xiaomi/MediaTek/Generic)
├─ Device Information Retrieval
├─ System Repair Operations
│  ├─ Clear caches (device-specific)
│  ├─ Stop problematic services (device-specific)
│  ├─ Optimize storage (device-specific)
│  └─ Verify system integrity
├─ ADB Daemon Restart
└─ Safe Device Reboot ✓
```

## 🆘 Troubleshooting

### Device Not Detected?
1. Enable USB Debugging: Settings → Developer Options → USB Debugging
2. Authorize connection prompt on device
3. Try different USB port
4. Restart ADB: `adb kill-server && adb start-server`

### Check USB Device Recognition
```bash
# List connected USB devices
lsusb

# Should show your device like:
# Bus 001 Device 092: ID 0e8d:0003 MediaTek Inc. MT6227 phone
```

### Still Having Issues?
See [USAGE.md](USAGE.md) for detailed troubleshooting and advanced usage.

---

**Made with ❤️ for Android users worldwide**

Supports: Motorola G15 • Xiaomi Mi Series • Xiaomi Redmi Series • MediaTek Devices • and more
