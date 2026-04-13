---
description: Run shellcheck on a Bash script and apply BCS-compliant fixes for each warning
argument-hint: <file>
allowed-tools: ["Bash", "Read", "Edit"]
---

# Fix ShellCheck Warnings

Run `shellcheck -x` against **$ARGUMENTS** and fix each warning using the BCS-compliant
remediation pattern for that SC code.

If `$ARGUMENTS` is empty, ask the user which file to fix.

## Procedure

1. **Baseline**
   ```bash
   shellcheck -x "$ARGUMENTS"
   ```
   Record every warning. Group by SC code.

2. **Remediate** each group using the canonical BCS fix (see mapping below). Touch only
   lines flagged by shellcheck; do not drive-by refactor neighbouring code.

3. **Verify** the full pipeline is clean:
   ```bash
   bash -n "$ARGUMENTS"         # syntax sanity check
   shellcheck -x "$ARGUMENTS"   # must report zero warnings
   bcscheck "$ARGUMENTS"        # must not regress BCS compliance
   ```

4. **Report** every change: SC code, `file:line`, before/after snippet, verification status.

## Canonical SC → BCS Remediation

| SC Code | Meaning                                      |
|---------|----------------------------------------------|
| SC2155  | Declare and assign separately                |
| SC2086  | Double-quote to prevent globbing/splitting   |
| SC2046  | Quote command substitution                   |
| SC2164  | Check `cd` failure (add die-guard)           |
| SC2181  | Check exit code directly, not via `$?`       |
| SC1091  | File not found for source                    |
| SC2034  | Variable appears unused                      |
| SC2317  | Command appears unreachable                  |
| SC2004  | `$` on arithmetic variables is unnecessary   |
| SC2068  | Quote array expansions                       |

Canonical fix patterns:

```bash
# SC2155 -- split declare + assign so the exit code is visible
declare -r FOO
FOO=$(some_command)

# SC2086 -- quote to block globbing and word splitting
echo "$var"

# SC2046 -- quote the command substitution
echo "$(command)"

# SC2164 -- guard cd with a BCS die-handler
cd "$dir" || die 5 "cd failed ${dir@Q}"

# SC2181 -- check the command directly
if cmd; then
  ...
fi

# SC1091 -- tell shellcheck where to find the sourced file
# shellcheck source=path/to/file.sh
source "$path"

# SC2034 -- remove, or disable with a one-line reason
# shellcheck disable=SC2034 # consumed by parent shell via export
declare -r VAR=...

# SC2317 -- remove dead code, or disable with a reason
# shellcheck disable=SC2317 # reached via trap EXIT
cleanup() { ...; }

# SC2004 -- drop the $ inside (( ))
((count += 1))

# SC2068 -- quote array expansions
printf '%s\n' "${files[@]}"
```

## Disable Rules (BCS1204)

- Every `# shellcheck disable=SC####` MUST carry a one-line reason comment.
- Scope disables to the specific line, block, or function -- never blanket-disable at the
  top of the file.
- Prefer fixing the root cause over disabling.

## Rules

**Always do:**
- Fix every occurrence of a given SC code in one pass.
- Verify with both `shellcheck -x` AND `bcscheck` before reporting done.
- Preserve the file's existing style (indentation, quoting preference).

**Never do:**
- Introduce changes unrelated to the reported SC codes.
- Use `((i++))` or `((++i))` (forbidden by BCS0505); use `i+=1` with `declare -i`.
- Skip the `bcscheck` verification step -- SC fixes can regress BCS compliance.
