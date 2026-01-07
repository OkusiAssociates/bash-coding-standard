# Security Considerations - Rulets
## General Principles
- [BCS1000] Security practices cover five essential areas: SUID/SGID prohibition, PATH security, IFS safety, eval avoidance, and input sanitization - these prevent privilege escalation, command injection, and path traversal attacks.
## SUID/SGID Prohibition
- [BCS1001] Never use SUID or SGID bits on Bash scripts under any circumstances - this is a critical security prohibition with no exceptions: `chmod u+s script.sh` is catastrophically dangerous.
- [BCS1001] Use sudo with configured permissions instead of SUID: `sudo /usr/local/bin/myscript.sh` or configure `/etc/sudoers.d/myapp` for specific commands.
- [BCS1001] SUID scripts are vulnerable to IFS exploitation, PATH manipulation, library injection via `LD_PRELOAD`, shell expansion attacks, and TOCTOU race conditions.
- [BCS1001] For elevated privileges, use sudo, capabilities (`setcap`), compiled setuid wrappers, PolicyKit (`pkexec`), or systemd services - never SUID shell scripts.
- [BCS1001] Find SUID/SGID scripts on your system with: `find / -type f \( -perm -4000 -o -perm -2000 \) -exec file {} \; | grep -i script`
## PATH Security
- [BCS1002] Always secure PATH at script start to prevent command hijacking: `readonly -- PATH='/usr/local/bin:/usr/bin:/bin'; export PATH`
- [BCS1002] Never include current directory (`.`), empty elements (`::`, leading/trailing `:`), `/tmp`, or user home directories in PATH.
- [BCS1002] Validate inherited PATH if not locking it down: check for `\.`, `^:`, `::`, `:$`, and `/tmp` patterns with `[[ "$PATH" =~ pattern ]]`.
- [BCS1002] For maximum security, use absolute paths for critical commands: `/bin/tar`, `/bin/rm`, `/usr/bin/systemctl`.
- [BCS1002] Verify critical commands resolve to expected locations: `command -v tar | grep -q '^/bin/tar$' || die 1 'Security: tar not from /bin/tar'`
- [BCS1002] Place PATH setting in first few lines after `set -euo pipefail` - commands executed before PATH is set use inherited (potentially malicious) PATH.
## IFS Safety
- [BCS1003] Never trust inherited IFS values - always set IFS explicitly at script start: `IFS=$' \t\n'; readonly IFS; export IFS`
- [BCS1003] Use subshell isolation for IFS changes: `( IFS=','; read -ra fields <<< "$data" )` - IFS automatically reverts when subshell exits.
- [BCS1003] Use one-line IFS assignment for single commands: `IFS=',' read -ra fields <<< "$csv_data"` - IFS resets after the command.
- [BCS1003] Use `local -- IFS` in functions to scope IFS changes to that function only.
- [BCS1003] Always save and restore IFS if modifying globally: `saved_ifs="$IFS"; IFS=','; ...; IFS="$saved_ifs"` - ensure restoration in error cases too.
- [BCS1003] For null-delimited input (e.g., `find -print0`), use: `while IFS= read -r -d '' file; do ...; done < <(find . -print0)`
## Eval Command Avoidance
- [BCS1004] Never use `eval` with untrusted input - avoid `eval` entirely unless absolutely necessary; almost every use case has a safer alternative.
- [BCS1004] Use arrays for dynamic command construction instead of eval: `cmd=(find "$path" -name "$pattern"); "${cmd[@]}"`
- [BCS1004] Use indirect expansion for variable references instead of eval: `echo "${!var_name}"` not `eval "echo \$$var_name"`
- [BCS1004] Use `printf -v` for dynamic variable assignment: `printf -v "$var_name" '%s' "$value"` not `eval "$var_name='$value'"`
- [BCS1004] Use associative arrays for dynamic data: `declare -A data; data["$key"]="$value"` not `eval "var_$key='$value'"`
- [BCS1004] Use case statements or array lookup for function dispatch: `case "$action" in start) start_fn ;; esac` not `eval "${action}_function"`
- [BCS1004] If eval seems necessary for parsing key=value pairs, use: `IFS='=' read -r key value <<< "$line"` then validate key before `declare -g "$key=$value"`
## Input Sanitization
- [BCS1005] Always validate and sanitize user input before use - never trust input even if it "looks safe"; use whitelist over blacklist approach.
- [BCS1005] Sanitize filenames by removing `..` and `/`, allowing only `[a-zA-Z0-9._-]+`, rejecting hidden files and names over 255 chars.
- [BCS1005] Validate integers with regex: `[[ "$input" =~ ^-?[0-9]+$ ]] || die 22 "Invalid integer: $input"` - check for leading zeros if octal interpretation is a concern.
- [BCS1005] Validate paths are within allowed directories using realpath: `real_path=$(realpath -e -- "$path"); [[ "$real_path" == "$allowed_dir"* ]] || die`
- [BCS1005] Validate against whitelists for choices: iterate valid options and match, or use associative array with `-v` test.
- [BCS1005] Always use `--` separator before file arguments to prevent option injection: `rm -- "$user_file"` not `rm "$user_file"`
- [BCS1005] Never pass user input directly to shell commands - validate first, use case statements for command whitelisting.
- [BCS1005] Validate early, fail securely with clear errors, and run with minimum necessary permissions.
## Temporary File Handling
- [BCS1006] Always use `mktemp` to create temporary files and directories - never hard-code temp file paths like `/tmp/myapp_temp.txt`.
- [BCS1006] Always set up cleanup trap immediately after creating temp resources: `temp_file=$(mktemp) || die 1 'Failed'; trap 'rm -f "$temp_file"' EXIT`
- [BCS1006] Check mktemp success explicitly: `temp_file=$(mktemp) || die 1 'Failed to create temp file'` - never assume success.
- [BCS1006] Use `-d` flag for temp directories and `-rf` for cleanup: `temp_dir=$(mktemp -d); trap 'rm -rf "$temp_dir"' EXIT`
- [BCS1006] Use custom templates for recognizable temp files: `mktemp /tmp/"$SCRIPT_NAME".XXXXXX` (minimum 3 X's required).
- [BCS1006] For multiple temp files, use array and cleanup function: `declare -a TEMP_FILES=(); cleanup() { for f in "${TEMP_FILES[@]}"; do rm -f "$f"; done }; trap cleanup EXIT`
- [BCS1006] Never use PID in filename (`/tmp/app_$$`), never create temp manually with `touch`/`chmod`, never change permissions to world-writable.
- [BCS1006] Default mktemp permissions are secure (0600 files, 0700 directories) - verify if handling sensitive data: `stat -c %a "$temp_file"`
- [BCS1006] Multiple trap statements overwrite each other - use single trap with combined cleanup or cleanup function for all resources.
- [BCS1006] Add `--keep-temp` option for debugging: check flag in cleanup function and skip deletion if set, printing preserved file paths.
