# Security Considerations - Rulets
## SUID/SGID Prohibition
- [BCS1201] Never use SUID (Set User ID) or SGID (Set Group ID) bits on Bash scripts under any circumstances; this is a critical security prohibition with no exceptions.
- [BCS1201] Use `sudo` with configured permissions instead of SUID bits: configure `/etc/sudoers` for specific commands and users.
- [BCS1201] SUID/SGID on shell scripts enables multiple attack vectors: IFS exploitation, PATH manipulation via interpreter resolution, library injection through `LD_PRELOAD`, shell expansion exploits, and TOCTOU race conditions.
- [BCS1201] The kernel executes the interpreter with SUID privileges before the script's security measures take effect, allowing attackers to inject malicious code during this window.
- [BCS1201] Find and audit all SUID/SGID scripts on your system: `find / -type f \( -perm -4000 -o -perm -2000 \) -exec file {} \; | grep -i script` should return nothing.
- [BCS1201] Use compiled C wrapper programs with SUID if elevated privileges are absolutely required, never SUID shell scripts.
## PATH Security
- [BCS1202] Lock down PATH immediately at script start to prevent command substitution attacks: `readonly PATH='/usr/local/bin:/usr/bin:/bin'; export PATH`.
- [BCS1202] Never include current directory (`.`), empty elements (`::` or leading/trailing `:`), `/tmp`, or user home directories in PATH.
- [BCS1202] Validate inherited PATH if you cannot set it: reject paths containing `.`, empty elements, `/tmp`, or starting with `/home`.
- [BCS1202] Use absolute command paths for maximum security and defense in depth: `/bin/tar`, `/usr/bin/systemctl`, `/bin/rm`.
- [BCS1202] Place PATH setting in first few lines after `set -euo pipefail`, before any commands execute.
- [BCS1202] Verify critical commands are from expected locations: `[[ "$(command -v tar)" == "/bin/tar" ]] || die 1 "Security: tar not from expected location"`.
## IFS Safety
- [BCS1203] Set IFS to known-safe value at script start and make it readonly to prevent field splitting attacks: `IFS=$' \t\n'; readonly IFS; export IFS`.
- [BCS1203] Use one-line IFS assignment for single commands to automatically restore IFS: `IFS=',' read -ra fields <<< "$csv_data"`.
- [BCS1203] Isolate IFS changes with subshells to prevent global side effects: `( IFS=','; read -ra fields <<< "$data"; process "${fields[@]}" )`.
- [BCS1203] Use `local -- IFS` in functions to scope IFS changes to function lifetime only.
- [BCS1203] Always save and restore IFS when modifying globally: `saved_ifs="$IFS"; IFS=','; ...; IFS="$saved_ifs"`.
- [BCS1203] Never trust inherited IFS values; attackers can manipulate IFS in the calling environment to exploit field splitting.
## Eval Command Prohibition
- [BCS1204] Never use `eval` with untrusted input; avoid `eval` entirely unless absolutely necessary, and seek alternatives first.
- [BCS1204] Use arrays for dynamic command construction instead of eval: `cmd=(find "$path" -name "*.txt"); "${cmd[@]}"`.
- [BCS1204] Use indirect expansion for variable references instead of eval: `echo "${!var_name}"` not `eval "echo \\$$var_name"`.
- [BCS1204] Use associative arrays for dynamic data instead of eval: `declare -A data; data[$key]=$value` not `eval "${key}=$value"`.
- [BCS1204] Use case statements or array lookups for function dispatch instead of eval: `case "$action" in start) start_func ;; esac`.
- [BCS1204] `eval` executes arbitrary code with full script privileges and performs expansion twice, enabling complete system compromise through code injection.
- [BCS1204] Use `printf -v "$var_name" '%s' "$value"` for safe variable assignment instead of `eval "$var_name='$value'"`.
## Input Sanitization
- [BCS1205] Always validate and sanitize user input to prevent injection attacks, directory traversal, and security vulnerabilities; fail early by rejecting invalid input before processing.
- [BCS1205] Sanitize filenames by removing directory traversal attempts (`..`, `/`) and allowing only safe characters: `[[ "$name" =~ ^[a-zA-Z0-9._-]+$ ]] || die 22 "Invalid filename"`.
- [BCS1205] Validate numeric input with regex before use: `[[ "$input" =~ ^[0-9]+$ ]] || die 22 "Invalid positive integer"` and check ranges where applicable.
- [BCS1205] Validate paths are within allowed directories using realpath: `real_path=$(realpath -e -- "$input"); [[ "$real_path" == "$allowed_dir"* ]] || die 5 "Path outside allowed directory"`.
- [BCS1205] Use whitelist validation (define what IS allowed) over blacklist validation (define what isn't allowed); blacklists are always incomplete and bypassable.
- [BCS1205] Always use `--` separator in commands to prevent option injection: `rm -- "$user_file"` not `rm "$user_file"` (prevents `--delete-all` attacks).
- [BCS1205] Never pass user input directly to shell commands or use eval with user input; use case statements to whitelist allowed commands.
- [BCS1205] Validate input type, format, range, and length; check for leading zeros in numbers, credentials in URLs, dangerous characters in filenames.
