---
description: Scaffold a new BCS-compliant Bash script using the bcs template generator
argument-hint: <type> <name> [description]
allowed-tools: ["Bash"]
---

# Scaffold a BCS Script

Generate a new Bash 5.2+ script from the BCS template generator.

## Arguments

- **type**: `minimal` | `basic` | `complete` | `library`
- **name**: script name (also used for placeholder expansion and as the output filename)
- **description** (optional): one-line description for the header comment

If any required argument is missing, ask the user -- do not guess.

## Template Reference

| Type       | Size       | Use when                                                       |
|------------|------------|----------------------------------------------------------------|
| `minimal`  | ~15 lines  | One-off utilities, glue scripts, smoke tests                   |
| `basic`    | ~25 lines  | Standard scripts with metadata + strict mode (DEFAULT)         |
| `complete` | ~112 lines | Full CLI tools: argument parsing, messaging, colour, help text |
| `library`  | ~39 lines  | Sourceable files with dual-purpose source fence                |

When in doubt, prefer the smaller template -- users can always move up.

## Procedure

1. **Generate**
   ```bash
   bcs template -t <type> -n <name> -d '<description>' -o <name> -x
   ```

2. **Verify**
   ```bash
   bash -n <name>
   shellcheck -x <name>
   bcscheck <name>
   ```
   If any step fails, stop and report. A freshly scaffolded file that fails verification
   indicates a bug in the generator, not a user problem.

3. **Report**
   - Path created
   - Template type used
   - The first edits the user should make (e.g. "fill in `main()` starting at line NN")

## Defaults

- Output path: current directory, filename matching `<name>`
- Executable: yes (`-x`)
- Version: `1.0.0`
- Type when unspecified: `basic`

## Rules

**Always do:**
- Use `bcs template`. Never hand-roll the template body.
- Verify with `bash -n`, `shellcheck -x`, AND `bcscheck` before reporting success.

**Never do:**
- Overwrite an existing file without `-f` AND explicit user confirmation.
- Edit the template body after generation -- the user fills in the business logic.
- Invent a description on the user's behalf.
