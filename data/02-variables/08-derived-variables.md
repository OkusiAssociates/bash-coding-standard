### Derived Variables

Variables computed from other variables should be grouped together with comments explaining their derivation:

```bash
# Default values
declare -- PREFIX=/usr/local
declare -- CONFIG_NAME=myapp

# Derived paths - computed from PREFIX
declare -- BIN_DIR="$PREFIX"/bin
declare -- LIB_DIR="$PREFIX"/lib
declare -- CONFIG_FILE="$HOME"/."$CONFIG_NAME"rc

# Special case: hardcoded for system-wide access
# PROFILE_DIR intentionally uses /etc regardless of PREFIX to ensure
# system-wide profile integration for all user sessions
declare -- PROFILE_DIR=/etc/profile.d

# Derived from environment with fallback
declare -- LOG_DIR="${XDG_STATE_HOME:-$HOME/.local/state}"/myapp
```

**Important:** When base variables can change during argument parsing, remember to update derived variables:

```bash
main() {
  # Parse arguments
  while (($#)); do
    case $1 in
      --prefix) noarg "$@"; shift
                PREFIX="$1"
                # Update all derived paths when PREFIX changes
                BIN_DIR="$PREFIX"/bin
                LIB_DIR="$PREFIX"/lib
                DOC_DIR="$PREFIX"/share/doc
                ;;
    esac
    shift
  done

  # Rest of main logic
}
```

**Guidelines:**
- Group derived variables with section comment (e.g., `# Derived paths`)
- Document special cases or hardcoded values with inline comments
- Update derived variables when base variables change (especially in argument parsing)
- Declare derived variables immediately after their dependencies when practical
