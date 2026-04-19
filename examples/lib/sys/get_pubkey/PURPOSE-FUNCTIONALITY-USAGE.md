# get_pubkey — SSH Public Key Utilities

## Purpose

A pair of small Bash utilities for retrieving and validating SSH public keys. Part of the `/ai/scripts/lib/` shared library collection. Intended for use by other scripts that need SSH key operations — e.g., identity verification, key-based authentication workflows, or remote provisioning.

## Scripts

### `get-pubkey`

Prints the current user's first available SSH public key, checking in preference order: `ed25519` → `ecdsa` → `rsa`.

- **Function**: `get_pubkey()`
- **Exit 0**: Key found and printed to stdout
- **Exit 1**: No readable public key found
- **Dual-mode**: Sourceable as a library (`source get-pubkey`) or executable directly

### `is-authorized-pubkey`

Checks whether a given public key exists in an `authorized_keys` file. Extracts the key blob (type + base64) from the input and performs a `grep` match.

- **Function**: `is_authorized_pubkey(payload)`
- **Input**: A string containing a public key (optionally prefixed with a MAC header separated by `|`)
- **Exit 0**: Key found in authorized_keys
- **Exit 1**: Key not found, or authorized_keys unreadable
- **Configurable**: `AUTHORIZED_KEYS_FILE` env var (default: `~/.ssh/authorized_keys`)
- **Dual-mode**: Sourceable or executable

## Usage

```bash
# Direct — check if current user's key is authorized
is-authorized-pubkey "$(get-pubkey)"

# With custom authorized_keys (e.g., root's)
AUTHORIZED_KEYS_FILE=/root/.ssh/authorized_keys sudo is-authorized-pubkey "$(get-pubkey)"

# As a library
source get-pubkey
source is-authorized-pubkey
key=$(get_pubkey) && is_authorized_pubkey "$key"
```

## Structure

| File                  | Description                              |
|-----------------------|------------------------------------------|
| `get-pubkey`          | Retrieve current user's SSH public key   |
| `is-authorized-pubkey`| Verify key exists in authorized_keys     |
| `.symlink`            | Installs both scripts to `/usr/local/bin`|

## Dependencies

- Bash 5.2+
- `grep` (for authorized_keys matching)
- Standard SSH key files in `~/.ssh/`

## Notes

- Both scripts use the BCS dual-mode pattern: `declare -fx` exports the function, and the `BASH_SOURCE` guard separates library mode from script mode.
- Key matching uses the base64 blob only (ignores comments), which is the correct way to match SSH keys regardless of trailing comment differences.
- The `is-authorized-pubkey` input format supports a `mac|pubkey` payload convention, stripping the MAC prefix before matching.
