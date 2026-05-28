# BLCKSWAN Universal Recovery Workspace

`recovery.img` must not be a random file name in a recommendation. Android Smart Repair should treat recovery as a prepared workspace artifact.

## Canonical artifact

Default path:

```text
artifacts/recovery/blckswan-universal-recovery.img
```

Environment override:

```text
BLCKSWAN_RECOVERY_IMG=/path/to/recovery.img
```

## Policy

When a device is detected in FASTBOOT mode, recommendations should say:

```text
Next: fastboot reboot
Or: boot prepared BLCKSWAN recovery workspace
```

Do not suggest a generic `recovery.img` unless the artifact exists and has been verified.

## Required preflight checks

Before offering a recovery boot action, the tool should verify:

1. The recovery image path exists.
2. The file is non-empty.
3. The image has an Android boot/recovery header or a known supported container format.
4. The connected fastboot device reports a compatible architecture or product profile.
5. The operation is clearly presented as a temporary boot unless flashing is explicitly selected.

## Design goal

The BLCKSWAN recovery workspace should be a portable diagnostic surface with:

- ADB shell access where supported.
- Partition inventory tools.
- Log collection.
- Slot and dynamic partition inspection.
- AVB/vbmeta inspection.
- Storage and filesystem diagnostics.
- Exportable repair bundle logs.

It should not be treated as a magic universal bypass. It is a controlled workspace for devices that already allow booting or flashing a custom recovery image.
