# Android Smart Repair

> Automatic fix for any trouble with your Android phone (initial focus on Motorola G15)

## 🎯 Purpose

**Android Smart Repair** is a foolproof, bulletproof bash script that automatically fixes bricked and problematic Android devices with a single command. No technical knowledge required.

## ✨ Features

- ✅ **Fully Automated** - One command fixes everything
- ✅ **Safe Operations** - No data loss, no system file modification
- ✅ **Multiple Repair Modes** - Full, quick, or cache-only repair
- ✅ **Comprehensive Logging** - Track every operation
- ✅ **Error Handling** - Graceful error recovery
- ✅ **Color-coded Output** - Clear, readable progress
- ✅ **Cross-Platform** - Works on Linux, macOS, Windows (WSL)
- ✅ **Device Detection** - Automatic device validation
- ✅ **Advanced Options** - For power users

## 🚀 Quick Start

```bash
# 1. Install dependencies (one time only)
chmod +x install_dependencies.sh
./install_dependencies.sh

# 2. Enable USB Debugging on your device:
#    Settings → About Phone → Build Number (tap 7 times) 
#    → Developer Options → USB Debugging (enable)

# 3. Connect device via USB and run:
chmod +x fix_motorola_g15.sh
./fix_motorola_g15.sh --full
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

### Command Options

```bash
./fix_motorola_g15.sh --full       # Complete repair (recommended)
./fix_motorola_g15.sh --cache      # Cache cleanup only
./fix_motorola_g15.sh --quick      # Quick fix with reboot
./fix_motorola_g15.sh --recovery   # Boot into recovery mode
./fix_motorola_g15.sh --help       # Show help
```

### Interactive Mode

```bash
./fix_motorola_g15.sh
```

Launch the interactive menu for step-by-step repair options.

## 📚 Documentation

- **[USAGE.md](USAGE.md)** - Detailed usage guide, troubleshooting, and advanced options
- **[LICENSE](LICENSE)** - MIT License

## 🔧 What You Need

### Required
- ADB (Android Debug Bridge)
- USB cable
- USB Debugging enabled on device

### Supported Devices
- ✅ Motorola G15 (primary focus)
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

## 📄 License

MIT License - Free to use, modify, and distribute.

## 🎓 How It Works

```
┌─ Prerequisites Check (ADB, Fastboot)
├─ Device Connection Validation
├─ Device Information Retrieval
├─ System Repair Operations
│  ├─ Clear caches
│  ├─ Stop problematic services
│  ├─ Optimize storage
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

### More Help?
See [USAGE.md](USAGE.md) for detailed troubleshooting and advanced usage.

---

**Made with ❤️ for Motorola G15 users**
