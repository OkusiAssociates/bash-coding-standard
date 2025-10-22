# Security Considerations - Rulets

## SUID/SGID Prohibition

- [BCS1201] Never use SUID (`chmod u+s`) or SGID (`chmod g+s`) bits on Bash scripts under any circumstances - catastrophically dangerous due to IFS exploitation, PATH manipulation, library injection, shell expansion exploits, race conditions, and interpreter vulnerabilities.
- [BCS1201] Use `sudo` with configured `/etc/sudoers` permissions instead of SUID scripts: `username ALL=(root) NOPASSWD: /usr/local/bin/script.sh`.
- [BCS1201] For compiled programs needing specific privileges, use capabilities (`setcap cap_net_bind_service=+ep`) instead of full SUID root.
- [BCS1201] If elevated privileges are absolutely required for a script, use a SUID wrapper written in C that validates input, sanitizes environment, and executes the script safely.
- [BCS1201] Audit systems regularly for SUID/SGID scripts: `find / -type f \( -perm -4000 -o -perm -2000 \) -exec file {} \; | grep -i script` should return nothing.

## PATH Security

- [BCS1202] Always lock down PATH at script start to prevent command hijacking: `readonly PATH='/usr/local/bin:/usr/bin:/bin'; export PATH`.
- [BCS1202] Set secure PATH immediately after `set -euo pipefail` - never trust inherited PATH from caller's environment.
- [BCS1202] Never include current directory (`.`), empty elements (`::` or leading/trailing `:`), `/tmp`, or user home directories in PATH.
- [BCS1202] Use absolute paths for critical commands as defense in depth: `/bin/tar`, `/usr/bin/systemctl`, `/bin/rm`.
- [BCS1202] Validate inherited PATH if you cannot set it: check for `.`, empty elements, `/tmp`, or writable directories using regex tests.
- [BCS1202] Verify critical commands resolve to expected locations: `[[ "$(command -v tar)" == "/bin/tar" ]] || die 1 "Security: tar not from /bin/tar"`.
- [BCS1202] Always use `--` separator before file arguments to prevent option injection: `rm -- "$user_file"` not `rm "$user_file"`.

## IFS Manipulation Safety

- [BCS1203] Set IFS explicitly to known-safe value at script start and make readonly: `IFS=$' \t\n'; readonly IFS; export IFS`.
- [BCS1203] Use one-line IFS assignment for single commands (safest pattern): `IFS=',' read -ra fields <<< "$csv_data"` - IFS automatically resets after the command.
- [BCS1203] Isolate IFS changes in subshells: `( IFS=','; read -ra fields <<< "$data"; process "${fields[@]}" )` - change cannot leak.
- [BCS1203] Use `local -- IFS` in functions to scope changes: declare IFS local before modifying, automatic restoration on function return.
- [BCS1203] Always save and restore if modifying IFS: `saved_ifs="$IFS"; IFS=','; read -ra fields <<< "$data"; IFS="$saved_ifs"`.
- [BCS1203] Never trust inherited IFS - attacker can manipulate it in calling environment to exploit field splitting and enable command injection.

## Eval Command Prohibition

- [BCS1204] Never use `eval` with any user input - enables complete command injection and system compromise with no sandboxing.
- [BCS1204] Avoid `eval` entirely even with trusted input - better alternatives exist for all common use cases using arrays, indirect expansion, or proper data structures.
- [BCS1204] Use arrays for dynamic command construction: `cmd=(find "$path" -type f); [[ -n "$pattern" ]] && cmd+=(-name "$pattern"); "${cmd[@]}"`.
- [BCS1204] Use indirect expansion for variable references: `echo "${!var_name}"` not `eval "echo \\$$var_name"`.
- [BCS1204] Use associative arrays for dynamic data: `declare -A data; data[$key]=$value; echo "${data[$key]}"` not `eval "$key='$value'"`.
- [BCS1204] Use case statements or associative arrays for function dispatch: `case "$action" in start) start_function ;;` not `eval "${action}_function"`.
- [BCS1204] Use `printf -v` for dynamic variable assignment: `printf -v "$var_name" '%s' "$value"` not `eval "$var_name='$value'"`.
- [BCS1204] Even sanitized input can contain metacharacters that enable injection through eval's double-expansion behavior.

## Input Sanitization

- [BCS1205] Always validate and sanitize user input before use - never trust it even if it "looks safe".
- [BCS1205] Use whitelist validation (define what IS allowed) not blacklist (define what isn't) - blacklists are always incomplete and bypassable.
- [BCS1205] Validate filenames to prevent directory traversal: remove all `..` and `/`, allow only `[a-zA-Z0-9._-]+`, reject leading dots and excessive length.
- [BCS1205] Validate integers with regex: `[[ "$input" =~ ^-?[0-9]+$ ]]` for signed, `[[ "$input" =~ ^[0-9]+$ ]]` for unsigned, reject leading zeros.
- [BCS1205] Validate paths stay within allowed directory: `real_path=$(realpath -e -- "$input_path"); [[ "$real_path" == "$allowed_dir"* ]] || die 5 "Path outside allowed directory"`.
- [BCS1205] Always use `--` separator in commands to prevent option injection: `rm -- "$user_file"` prevents `-rf` being interpreted as option.
- [BCS1205] Validate against whitelist for choice inputs: iterate allowed values, reject if no match: `for choice in "${valid[@]}"; do [[ "$input" == "$choice" ]] && return 0; done; die 22 "Invalid"`.
- [BCS1205] Validate early before any processing - fail securely with clear error messages on invalid input.
- [BCS1205] Check input type, format, range, and length constraints - comprehensive validation prevents injection and logic errors.
