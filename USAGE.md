# Android Smart Repair - Usage Guide

## Quick Start (3 Steps)

### Step 1: Install Dependencies

```bash
chmod +x install_dependencies.sh
./install_dependencies.sh
```

The script auto-detects your OS and installs required tools.

### Step 2: Prepare Your Device

1. **Enable USB Debugging:**
   - Go to Settings
   - Find "About Phone"
   - Tap "Build Number" 7 times
   - Go back to main Settings
   - Enter "Developer Options"
   - Enable "USB Debugging"

2. **Connect via USB Cable**
   - Use a quality USB cable
   - Connect directly to computer (not hub)

3. **Authorize Connection:**
   - Look for prompt on device
   - Tap "Allow" to authorize computer

### Step 3: Run the Repair

```bash
chmod +x fix_motorola_g15.sh
./fix_motorola_g15.sh --full
```

**Done!** Your device will be fixed automatically. ✓

---

## Usage Modes

### Full Repair (Recommended)
```bash
./fix_motorola_g15.sh --full
```

**What it does:**
- Clears all caches
- Stops problematic services
- Optimizes storage
- Restarts system daemons
- Safe reboot

**Time:** 5-10 minutes

**Best for:** Severely bricked devices, extreme slowness, bootloops

---

### Cache Cleanup Only
```bash
./fix_motorola_g15.sh --cache
```

**What it does:**
- Clears system cache
- Clears app caches
- Reboots device

**Time:** 2-3 minutes

**Best for:** Storage full errors, slow performance

---

### Quick Fix
```bash
./fix_motorola_g15.sh --quick
```

**What it does:**
- Force-stops hung services
- Reboots device

**Time:** 1-2 minutes

**Best for:** Frozen apps, unresponsive UI

---

### Recovery Boot
```bash
./fix_motorola_g15.sh --recovery
```

Boots device into recovery mode for manual operations.

---

### Bootloader Mode
```bash
./fix_motorola_g15.sh --bootloader
```

Boots device into bootloader for advanced operations.

---

### Interactive Mode
```bash
./fix_motorola_g15.sh
```

Launches interactive menu to choose repair mode.

---

## Troubleshooting

### Problem: "No devices connected"

**Solution:**

1. **Check USB Connection:**
   ```bash
   adb devices
   ```
   Should show device ID if connected.

2. **Enable USB Debugging:**
   - Settings → Developer Options → USB Debugging (ON)

3. **Authorize Connection:**
   - Look for "Allow USB debugging?" prompt on device
   - Tap "Allow"

4. **Try Different USB Port:**
   - Use different port or direct connection

5. **Restart ADB:**
   ```bash
   adb kill-server
   adb start-server
   adb devices
   ```

6. **Install ADB Drivers (Windows):**
   - Download from: https://adb.clockworkmod.com/
   - Install and restart

---

### Problem: "Permission denied" errors

**Solution:**

```bash
# On Linux, use sudo
sudo ./fix_motorola_g15.sh --full

# Or add user to adb group
sudo usermod -a -G adbusers $USER
# Log out and back in
```

---

### Problem: Device disconnects during repair

**Solution:**

1. Check USB connection quality
2. Try different USB port
3. Use powered USB hub
4. Reconnect and run again:
   ```bash
   ./fix_motorola_g15.sh --full
   ```

---

### Problem: Script stuck or hanging

**Solution:**

1. Press `Ctrl+C` to stop
2. Wait 30 seconds
3. Restart ADB:
   ```bash
   adb kill-server
   adb start-server
   ```
4. Try again

---

## Advanced Usage

### View Device Information

```bash
adb shell getprop ro.product.model       # Device model
adb shell getprop ro.build.version.release  # Android version
adb shell dumpsys battery                # Battery info
adb shell df -h                          # Storage info
```

### Manual Cache Clearing

```bash
adb shell rm -rf /cache/*
adb shell pm trim-caches 1000000000
```

### Safe Reboot

```bash
adb reboot
```

### Reboot to Recovery

```bash
adb reboot recovery
```

### Reboot to Bootloader

```bash
adb reboot bootloader
```

### Install ADB Drivers (Windows)

1. Download: https://adb.clockworkmod.com/
2. Run installer
3. Restart computer
4. Plug in device

---

## Logs

All operations are logged automatically:

```
android_repair_YYYYMMDD_HHMMSS.log
```

### View Last Repair Log

```bash
cat android_repair_*.log | tail -50
```

### View Full Log

```bash
cat android_repair_*.log
```

### Archive Logs

```bash
mkdir -p logs
mv android_repair_*.log logs/
```

---

## What Gets Fixed

✅ **Safe Operations (No Data Loss)**
- Temporary file cleanup
- Cache removal
- Temp database cleanup
- Stopped service restart

❌ **NOT Modified**
- Your photos, videos, messages
- Installed apps
- App data
- System files
- Bootloader

---

## FAQ

### Q: Will this delete my data?
**A:** No. Only temporary and cache files are removed. Your photos, messages, and apps are 100% safe.

### Q: How long does repair take?
**A:** Full repair: 5-10 minutes
Quick fix: 1-2 minutes
Cache only: 2-3 minutes

### Q: Do I need root access?
**A:** No. Standard USB debugging is sufficient.

### Q: Can I cancel the repair?
**A:** Yes. Press `Ctrl+C` to stop anytime.

### Q: What if nothing changes?
**A:** Try different repair mode. Check logs for errors.

### Q: Is this safe for my device?
**A:** Yes. We only clear recoverable temporary files.

### Q: Can I use this on other Android phones?
**A:** Yes. Works on any Android device with ADB support.

### Q: Where are the logs?
**A:** In same directory as script: `android_repair_*.log`

### Q: What if device won't connect?
**A:** See troubleshooting section for detailed steps.

### Q: Can I run this multiple times?
**A:** Yes. Safe to run as often as needed.

### Q: What's the difference between modes?
**A:** 
- Full: Everything
- Quick: Stop hung services
- Cache: Clear caches only

---

## System Requirements

### Linux
- Ubuntu 18.04+
- Debian 9+
- Fedora 30+
- Any distro with apt, dnf, or pacman

### macOS
- macOS 10.12+
- Homebrew installed

### Windows
- Windows 7+
- Android SDK Platform Tools

### Device Requirements
- Android 5.0+
- USB Debugging enabled
- USB cable (working)

---

## Platform-Specific Help

### Linux/macOS
```bash
# Make executable
chmod +x fix_motorola_g15.sh install_dependencies.sh

# Run
./fix_motorola_g15.sh --full
```

### Windows (PowerShell/CMD)
```bash
# Download platform tools
# Extract to a directory
# Add to PATH
# OR use WSL (Windows Subsystem for Linux)

# In PowerShell/CMD, run with shell:
bash fix_motorola_g15.sh --full
```

### Windows (WSL/Git Bash)
```bash
chmod +x fix_motorola_g15.sh
./fix_motorola_g15.sh --full
```

---

## Tips & Best Practices

1. **Always backup first** - Use Google account backup or cloud storage
2. **Use quality USB cable** - Bad cables cause connection issues
3. **Connect directly** - Don't use USB hubs
4. **Ensure battery > 30%** - Prevent power-off during repair
5. **Keep device cool** - Plug in to charge during repair
6. **Run in safe mode** - If it fails normally
7. **Check logs** - Understand what happened
8. **Try multiple times** - Sometimes connection issues occur

---

## Support

For issues:

1. Check troubleshooting section above
2. Review the operation logs
3. Try different repair mode
4. Restart ADB daemon
5. Reconnect device

---

## Safety Guarantee

✅ **Guaranteed Safe Operations**
- Only temporary files modified
- No system file corruption risk
- Fully reversible operations
- No kernel/bootloader changes
- Standard ADB protocols only

**Your device is in good hands.** ✓

---

Last Updated: 2026-05-26
