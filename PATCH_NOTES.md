# Patch Notes

This change set is intended to make the USB selection flow more resilient.

## Recommended direction

- Avoid fatal exits for transient USB states.
- Treat device reconnects as normal events.
- Keep a persistent selector loop alive while the device moves between states.
- Add debounce before declaring a device stable.
- Add reconnect storm protection.
- Separate transport detection from repair actions.
- Keep ADB and Fastboot probing independent.

## Why

Android devices commonly disconnect and reconnect while moving between normal mode, bootloader mode, recovery mode, and update mode. A selector should keep watching instead of stopping on the first failed probe.
