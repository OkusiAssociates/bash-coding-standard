### Script Metadata
```bash
VERSION='1.0.0'
SCRIPT_PATH=$(readlink -en -- "$0") # Full path to script
SCRIPT_DIR=${SCRIPT_PATH%/*}        # Script directory
SCRIPT_NAME=${SCRIPT_PATH##*/}      # Script basename
readonly -- VERSION SCRIPT_PATH SCRIPT_DIR SCRIPT_NAME
```
