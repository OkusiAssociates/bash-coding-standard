# BCS Group-Based Access Control Setup

## Overview

The BCS repository now uses group-based access control to enable collaborative development. All files and directories are owned by the `bcs` group (GID 8088), with setgid bits ensuring new files automatically inherit group ownership.

## Group Configuration

**Group name:** `bcs`
**Group ID:** 8088
**Members:** gary, sysadmin

### Adding New Members

```bash
sudo usermod -aG bcs username
```

Users must log out and back in for group membership to take effect.

## Permission Structure

### Repository Location
**Path:** `/ai/scripts/Okusi/bash-coding-standard/`

| Type | Permissions | Octal | Description |
|------|-------------|-------|-------------|
| Directories | `drwxrwsr-x` | 2775 | Group rw + setgid |
| Regular files | `-rw-rw-r--` | 664 | Group rw |
| Shell scripts | `-rwxrwxr-x` | 775 | Group rwx |
| Symlinks | `lrwxrwxrwx` | 777 | Default (not affected) |

### Installed Location
**Path:** `/usr/local/share/yatti/bash-coding-standard/`

Same permission structure as repository.

### Binary Location
**Path:** `/usr/local/bin/bash-coding-standard` (and `bcs` symlink)

| Type | Permissions | Octal | Owner | Description |
|------|-------------|-------|-------|-------------|
| Binary | `-rwxr-xr-x` | 755 | root:root | World-executable |

## Setgid Behavior

The setgid bit (2000) on directories ensures:
- New files created by any `bcs` group member are owned by group `bcs`
- New subdirectories inherit the setgid bit
- Collaborative editing works seamlessly

**Example:**
```bash
# User 'gary' creates a file in data/
touch /ai/scripts/Okusi/bash-coding-standard/data/new-file.md

# File is automatically owned by group 'bcs'
ls -l data/new-file.md
# Output: -rw-rw-r-- 1 gary bcs ... data/new-file.md
```

## Files Modified

### 1. Makefile (lines 26-41)
Updated `install` target to:
- Create SHAREDIR with mode 2775 and group `bcs`
- Install docs with mode 664 and group `bcs`
- Copy data/ with `cp -a` (preserve timestamps), then fix permissions
- Copy BCS/ index with proper group ownership

**Key changes:**
- Line 30: `install -d -m 2775 -g bcs $(SHAREDIR)`
- Lines 31-33: Added `-g bcs` flag to all install commands
- Line 35: Added permission fixes after `cp -a data`
- Line 37: Added permission fixes for BCS index

### 2. fix-permissions.sh (new script)
BCS-compliant helper script for quick permission fixes.

**Usage:**
```bash
# Fix repository only (no sudo needed if you're in bcs group)
./fix-permissions.sh

# Fix both repository and installed location
sudo ./fix-permissions.sh
```

**Features:**
- Validates `bcs` group exists
- Fixes repository permissions (can run as regular user)
- Fixes installed location (requires root)
- Color-coded output with status messages
- BCS-compliant structure (v1.0.0)

## Verification Commands

```bash
# Check group membership
getent group bcs

# Verify repository permissions
stat -c "%a %U:%G %n" /ai/scripts/Okusi/bash-coding-standard/data

# Verify installed permissions
stat -c "%a %U:%G %n" /usr/local/share/yatti/bash-coding-standard/data

# Test setgid inheritance
touch /ai/scripts/Okusi/bash-coding-standard/.test && \
  stat -c "%a %U:%G %n" /ai/scripts/Okusi/bash-coding-standard/.test && \
  rm /ai/scripts/Okusi/bash-coding-standard/.test

# Expected output: 664 username:bcs
```

## Maintenance

### After Git Pull/Clone
If permissions get reset after git operations:

```bash
./fix-permissions.sh
```

### After Installation
Permissions are automatically set correctly by the updated Makefile:

```bash
sudo make install
# or
sudo make PREFIX=/usr install
```

### Manual Permission Fix
If needed:

```bash
# Repository
sudo chgrp -R bcs /ai/scripts/Okusi/bash-coding-standard/
find /ai/scripts/Okusi/bash-coding-standard/ -type d -exec sudo chmod 2775 {} +
find /ai/scripts/Okusi/bash-coding-standard/ -type f -exec sudo chmod 664 {} +
find /ai/scripts/Okusi/bash-coding-standard/ -name "*.sh" -exec sudo chmod 775 {} +

# Installed location
sudo chgrp -R bcs /usr/local/share/yatti/bash-coding-standard/
sudo find /usr/local/share/yatti/bash-coding-standard/ -type d -exec chmod 2775 {} +
sudo find /usr/local/share/yatti/bash-coding-standard/ -type f -exec chmod 664 {} +
```

## Security Considerations

1. **Binary remains root-owned**: `/usr/local/bin/bash-coding-standard` is owned by root:root with 755 permissions (world-executable but not writable)

2. **Data directories are group-writable**: Only members of `bcs` group can modify repository and installed data files

3. **setgid does not affect security**: The setgid bit on directories only affects group ownership inheritance, not execution privileges

4. **Git ignores setgid**: Git does not track the setgid bit, so it must be reapplied after cloning/pulling

## Troubleshooting

### New files not owned by bcs group
**Cause:** Directory missing setgid bit
**Solution:** Run `./fix-permissions.sh`

### Permission denied when editing
**Cause:** User not in `bcs` group
**Solution:**
```bash
sudo usermod -aG bcs username
# Then log out and back in
```

### Installation doesn't set group ownership
**Cause:** Using old Makefile
**Solution:** Pull latest changes and reinstall:
```bash
git pull
sudo make uninstall
sudo make install
```

## References

- BCS Standard: `BASH-CODING-STANDARD.md`
- Makefile: Lines 26-41
- Helper script: `fix-permissions.sh`
- Group info: `getent group bcs`
