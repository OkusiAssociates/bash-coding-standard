# Security Considerations - Rulets
## Overview
- [BCS1000] This section establishes security-first practices covering SUID/SGID prohibition, PATH security, IFS safety, eval avoidance, input sanitization, and temporary file handling to prevent privilege escalation, command injection, and other attack vectors.
## SUID/SGID Prohibition
- [BCS1001] Never use SUID (`chmod u+s`) or SGID (`chmod g+s`) bits on Bash scripts; this is a critical security prohibition with no exceptions.
- [BCS1001] SUID/SGID shell scripts are vulnerable to IFS exploitation, PATH manipulation, library injection (`LD_PRELOAD`), shell expansion attacks, and race conditions.
- [BCS1001] Use `sudo` with configured `/etc/sudoers.d/` permissions instead of SUID: `username ALL=(root) NOPASSWD: /usr/local/bin/myscript.sh`.
- [BCS1001] For compiled programs requiring specific privileges, use capabilities: `setcap cap_net_bind_service=+ep /usr/local/bin/myserver`.
- [BCS1001] When elevated script execution is absolutely required, use a compiled C setuid wrapper that sanitizes environment (`unsetenv("LD_PRELOAD"); unsetenv("IFS"); setenv("PATH", "/usr/bin:/bin", 1)`) before calling the script.
- [BCS1001] Audit systems regularly for SUID/SGID scripts: `find / -type f \( -perm -4000 -o -perm -2000 \) -exec file {} \; | grep -i script`.
## PATH Security
- [BCS1002] Always set PATH explicitly at script start using `readonly PATH='/usr/local/bin:/usr/bin:/bin'; export PATH`.
- [BCS1002] Never include current directory (`.`), empty elements (`::`, leading `:`, trailing `:`), `/tmp`, or user home directories in PATH.
- [BCS1002] Validate PATH before use if you must accept inherited environment: `[[ "$PATH" =~ \. ]] && die 1 'PATH contains current directory'`.
- [BCS1002] For maximum security in critical scripts, use absolute paths for commands: `/bin/tar`, `/bin/rm`, `/usr/bin/systemctl`.
- [BCS1002] Verify critical commands resolve to expected locations: `command -v tar | grep -q '^/bin/tar$' || die 1 'Security: tar not from /bin/tar'`.
- [BCS1002] Check that no directories in PATH are world-writable: `find $(echo "$PATH" | tr ':' ' ') -maxdepth 0 -type d -writable 2>/dev/null`.
## IFS Safety
- [BCS1003] Never trust inherited IFS; set explicitly at script start: `IFS=$' \t\n'; readonly IFS; export IFS`.
- [BCS1003] Use subshell isolation for IFS changes: `( IFS=','; read -ra fields <<< "$data" )`.
- [BCS1003] Use one-line IFS assignment for single commands where IFS applies only to that command: `IFS=',' read -ra fields <<< "$csv_data"`.
- [BCS1003] Use `local -- IFS` in functions to scope IFS changes to that function: `local -- IFS; IFS=','`.
- [BCS1003] When manually saving/restoring IFS, always restore even on error: `saved_ifs="$IFS"; IFS=','; ...; IFS="$saved_ifs"`.
- [BCS1003] For reading files while preserving content exactly, use: `while IFS= read -r line; do ...; done < file.txt`.
- [BCS1003] For null-delimited input (e.g., `find -print0`), use: `while IFS= read -r -d '' file; do ...; done < <(find . -print0)`.
## Eval Command Avoidance
- [BCS1004] Never use `eval` with untrusted input; avoid `eval` entirely unless absolutely necessary.
- [BCS1004] Use arrays for dynamic command construction: `declare -a cmd=(find "$path" -type f); "${cmd[@]}"`.
- [BCS1004] Use indirect expansion instead of eval for variable references: `echo "${!var_name}"`.
- [BCS1004] Use `printf -v` for dynamic variable assignment: `printf -v "$var_name" '%s' "$value"`.
- [BCS1004] Use associative arrays for dynamic data: `declare -A data; data["$key"]="$value"; echo "${data[$key]}"`.
- [BCS1004] Use case statements or associative arrays for function dispatch instead of eval: `case "$action" in start) start_function ;; esac`.
- [BCS1004] For arithmetic with user input, validate strictly first: `[[ "$expr" =~ ^[0-9+\-*/\ ()]+$ ]] && result=$((expr))`.
## Input Sanitization
- [BCS1005] Always validate and sanitize user input before use; fail early with clear error messages.
- [BCS1005] Use whitelist validation (define what IS allowed) rather than blacklist (what isn't): `[[ "$name" =~ ^[a-zA-Z0-9._-]+$ ]] || die 22 'Invalid filename'`.
- [BCS1005] Sanitize filenames by removing directory traversal and restricting characters: `name="${name//\.\./}"; name="${name//\//}"; [[ "$name" =~ ^[a-zA-Z0-9._-]+$ ]]`.
- [BCS1005] Validate paths are within allowed directories using realpath: `real_path=$(realpath -e -- "$input"); [[ "$real_path" == "$allowed_dir"* ]] || die 5 'Path outside allowed directory'`.
- [BCS1005] Validate integers with regex: `[[ "$input" =~ ^-?[0-9]+$ ]] || die 22 "Invalid integer: $input"`.
- [BCS1005] Validate against whitelists using array lookup: `for choice in "${valid_choices[@]}"; do [[ "$input" == "$choice" ]] && return 0; done; die 22 'Invalid choice'`.
- [BCS1005] Always use `--` separator before file arguments to prevent option injection: `rm -- "$user_file"`.
- [BCS1005] Never pass user input directly to shell commands without validation; use case statements for command selection.
## Temporary File Handling
- [BCS1006] Always use `mktemp` to create temporary files and directories; never hard-code temp file paths like `/tmp/myapp.txt`.
- [BCS1006] Always set up cleanup trap immediately after creating temp files: `temp_file=$(mktemp) || die 1 'Failed to create temp file'; trap 'rm -f "$temp_file"' EXIT`.
- [BCS1006] For temp directories, use `mktemp -d` and `rm -rf` in cleanup: `temp_dir=$(mktemp -d); trap 'rm -rf "$temp_dir"' EXIT`.
- [BCS1006] Check mktemp success before using temp file: `temp_file=$(mktemp) || die 1 'Failed to create temp file'`.
- [BCS1006] Use custom templates for recognizable temp files: `temp_file=$(mktemp /tmp/"$SCRIPT_NAME".XXXXXX)`.
- [BCS1006] For multiple temp files, use array and cleanup function: `declare -a TEMP_FILES=(); cleanup() { for f in "${TEMP_FILES[@]}"; do rm -f "$f"; done }; trap cleanup EXIT`.
- [BCS1006] Make temp file variables readonly after assignment to prevent accidental modification: `readonly -- temp_file`.
- [BCS1006] Default mktemp permissions are secure (0600 for files, 0700 for directories); don't weaken them.
- [BCS1006] Add `--keep-temp` option for debugging: `((KEEP_TEMP)) && info "Keeping temp files" && return` in cleanup function.
- [BCS1006] Handle signals for cleanup: `trap cleanup EXIT SIGINT SIGTERM`.
