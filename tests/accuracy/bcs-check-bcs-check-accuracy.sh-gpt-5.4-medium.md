bcs: ◉ Backend 'openai' inferred from model 'gpt-5.4'
bcs: ◉ Checking '/ai/scripts/Okusi/BCS/tests/accuracy/bcs-check-accuracy.sh' against BCS (backend=openai)...
bcs: ◉ bcs check --model 'gpt-5.4' --effort 'medium' --strict 'off' '/ai/scripts/Okusi/BCS/tests/accuracy/bcs-check-accuracy.sh'
Here are the actual BCS deviations in the provided script.

### 1) BCS0301 — WARNING — line 80
**What is wrong:**  
A static string is double-quoted:

```bash
>&2 echo "bcs check --model $model --effort $effort ${script@Q} &>${output_to@Q}"
```

Under BCS0301, double quotes should be used only when shell expansion is needed. This line does contain expansions, so the quoting itself is valid, but it also uses `echo` for a status message and embeds a large literal string in one double-quoted argument. This is more of a style issue than a correctness problem.

**How to fix it:**  
Prefer `printf` for structured status output, or separate literal and variable parts more clearly. For example:

```bash
>&2 printf 'bcs check --model %s --effort %s %q &>%q\n' "$model" "$effort" "$script" "$output_to"
```

---

### 2) BCS0702 — WARNING — lines 80, 82
**What is wrong:**  
Status messages are sent to stderr correctly, but by using raw `echo` directly rather than messaging functions. This is not incorrect, but it deviates from the standard messaging pattern in BCS0702/BCS0705 for status output.

**How to fix it:**  
Use a minimal messaging helper, or at least `printf` to stderr consistently. For example:

```bash
>&2 printf '%s: %s\n' "$SCRIPT_NAME" "bcs check --model $model --effort $effort ${script@Q} &>${output_to@Q}"
>&2 printf '%s: %s\n' "$SCRIPT_NAME" "    ${output_to@Q} already exists; skipping"
```

---

### 3) BCS0801 — WARNING — lines 35–63
**What is wrong:**  
Argument handling does not use the standard BCS parsing pattern:

```bash
if (($#)); then
  if [[ $1 == @(-V|--version) ]]; then
  ...
```

This script only accepts zero or one control argument, so the logic is simple and works, but it deviates from the recommended `while (($#)); do case $1 in ... esac; shift; done` structure.

**How to fix it:**  
Use the standard parser form even for simple option handling, e.g.:

```bash
while (($#)); do case $1 in
  -V|--version) printf '%s %s\n' "$SCRIPT_NAME" "$VERSION"; exit 0 ;;
  -h|--help)    cat <<HELP
...
HELP
                exit 0 ;;
  -*)           >&2 printf '%s: ✗ %s\n' "$SCRIPT_NAME" "Invalid argument ${1@Q}"; exit 22 ;;
  *)            >&2 printf '%s: ✗ %s\n' "$SCRIPT_NAME" "Invalid argument ${1@Q}"; exit 22 ;;
esac; shift; done
```

---

### 4) BCS0602 — WARNING — lines 59–60
**What is wrong:**  
Invalid argument handling exits with code `1`:

```bash
>&2 printf '%s: ✗ %s\n' "$SCRIPT_NAME" "Invalid argument ${1@Q}"
exit 1
```

BCS0602 recommends `22` for invalid arguments and `2` for usage/argument errors. Using `1` is not unsafe, but it is a deviation from the standard exit-code scheme.

**How to fix it:**  
Use the recommended exit code:

```bash
exit 22
```

or possibly `exit 2` if you want to classify it as a general usage error.

---

### 5) BCS0403 — WARNING — lines 35–93
**What is wrong:**  
The script has no `main()` and runs top-level logic directly. BCS0108/BCS0403 say `main()` is generally used for scripts over about 200 lines, so this is not mandatory here, but this script is large enough in behavior and structure that a `main()` would improve organization.

**How to fix it:**  
Wrap the executable logic in `main()` and call it at the end:

```bash
main() {
  ...
}

main "$@"
#fin
```

---

## Summary

| BCS Code | Severity | Line(s) | Description |
|---|---|---:|---|
| BCS0301 | WARNING | 80 | Status output uses a large double-quoted mixed literal/expanded string; clearer `printf` formatting is preferred. |
| BCS0702 | WARNING | 80, 82 | Status messages go to stderr correctly but use raw `echo` instead of a standard messaging pattern. |
| BCS0801 | WARNING | 35–63 | Argument parsing deviates from the standard `while/case/shift` BCS pattern. |
| BCS0602 | WARNING | 59–60 | Invalid argument exits with code `1` instead of recommended `22` or `2`. |
| BCS0403 | WARNING | 35–93 | Script executes top-level logic directly instead of using `main()`; acceptable but non-standard. |
bcs: ◉ Tokens: in=20710 out=1118
bcs: ◉ Elapsed: 18s
