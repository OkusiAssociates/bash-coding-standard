# BCS Group-Based Access Control Setup

## Overview

The BCS repository now uses group-based access control to enable collaborative development. All files and directories should be owned by the `bcs` group (GID 8088), with setgid bits ensuring new files automatically inherit group ownership.

## Quick Check

Verify your repository has correct group ownership:

```bash
# Check repository group ownership
stat -c "%G" /ai/scripts/Okusi/bash-coding-standard/

# Expected output: bcs
# If you see "sysadmin" or another group, run: ./fix-permissions.sh
```

**Note:** Git does not track group ownership, so newly cloned repositories will need `./fix-permissions.sh` run once to establish correct group ownership.

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

## Current Repository State

⚠ **IMPORTANT**: The repository at `/ai/scripts/Okusi/bash-coding-standard/` may currently have group ownership `sysadmin:sysadmin` rather than the intended `bcs` group. This is expected behavior because:

1. **Git does not track group ownership** - Only file permissions are tracked
2. **The installed location DOES have correct ownership** - The Makefile install target correctly sets `bcs` group ownership when installing to `/usr/local/share/yatti/bash-coding-standard/`
3. **Repository ownership must be fixed manually** after cloning or when collaborating

**To fix repository group ownership:**
```bash
cd /ai/scripts/Okusi/bash-coding-standard/
./fix-permissions.sh
```

**Verification:**
```bash
# Should output "bcs" after running fix-permissions.sh
stat -c "%G" /ai/scripts/Okusi/bash-coding-standard/
```

This is a **one-time setup step** required on each system where the repository is cloned for collaborative development.

## Setgid Behavior

The setgid bit (2000) on directories ensures:
- New files created in a directory inherit the directory's **group ownership**
- New subdirectories inherit the setgid bit
- Collaborative editing works seamlessly **when the directory group is `bcs`**

**Important:** Setgid inheritance only works when the parent directory itself is owned by the `bcs` group. If the directory is owned by `sysadmin:sysadmin` with setgid, new files will be owned by `sysadmin` group.

**Example (after running fix-permissions.sh):**
```bash
# User 'gary' creates a file in data/ (where directory group is bcs)
touch /ai/scripts/Okusi/bash-coding-standard/data/new-file.md

# File is automatically owned by group 'bcs'
ls -l data/new-file.md
# Output: -rw-rw-r-- 1 gary bcs ... data/new-file.md
```

**Before running fix-permissions.sh:**
```bash
# If directory is owned by sysadmin:sysadmin with setgid
# New files will be: -rw-rw-r-- 1 gary sysadmin ... (NOT bcs)
```

## Files Modified

### 1. Makefile (install target)
Updated `install:` target (line 144+) to:
- Create SHAREDIR with mode 2775 and group `bcs`
- Copy data/ with `cp -a` (preserve timestamps), then fix permissions and group
- Copy lib/ with proper group ownership and permissions
- Copy BCS/ index with proper group ownership

**Key changes in install target:**
- `install -d -m 2775 -g bcs $(SHAREDIR)`
- `chgrp -R bcs` and permission fixes after `cp -a data`
- `chgrp -R bcs` and permission fixes after `cp -a lib`
- `chgrp -R bcs` and permission fixes for BCS index

**Note:** These changes ensure the installed location at `/usr/local/share/yatti/bash-coding-standard/` has correct group ownership, even though the source repository may not.

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

## Git and Permission Tracking

**Important limitation:** Git does **not** track or restore:
- ✗ Group ownership (e.g., `bcs` vs `sysadmin`)
- ✗ Setgid bits (the `2` in `2775`)
- ✗ User ownership beyond permission bits

**What Git tracks:**
- ✓ Basic permission bits (755, 644, etc.)
- ✓ Executable flag
- ✓ File content

**Implications:**

1. **After `git clone`**: Repository will have default group ownership (usually user's primary group)
2. **After `git pull`**: Group ownership remains unchanged (git doesn't modify it)
3. **Manual fix required**: Run `./fix-permissions.sh` after cloning to establish correct group ownership
4. **One-time per system**: Once fixed, group ownership persists across git operations

**Workflow for new developers:**
```bash
# Clone repository
git clone <repository-url>
cd bash-coding-standard

# Fix permissions for collaboration (one-time setup)
./fix-permissions.sh

# Verify
stat -c "%G" .
# Should output: bcs
```

**Note:** The installed location (`/usr/local/share/yatti/...`) does not have this limitation because the Makefile explicitly sets correct ownership during installation.

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
**Cause:** Directory missing setgid bit OR directory group is wrong
**Solution:** Run `./fix-permissions.sh`

### Permission denied when editing
**Cause:** User not in `bcs` group
**Solution:**
```bash
sudo usermod -aG bcs username
# Then log out and back in
```

### Repository still wrong group after running fix-permissions.sh
**Cause:** Script requires proper permissions to change group ownership
**Solution:**
```bash
# If you're not in the bcs group yet, use sudo
sudo ./fix-permissions.sh

# Or ensure you're in the bcs group and have write access
groups | grep bcs  # Verify membership
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
- Makefile: install target (line 144+)
- Helper script: `fix-permissions.sh`
- Group info: `getent group bcs`
