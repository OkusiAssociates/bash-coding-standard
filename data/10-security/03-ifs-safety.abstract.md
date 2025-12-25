## IFS Manipulation Safety

**Always protect IFS changes to prevent field splitting attacks and command injection.**

**Rationale:** Attackers manipulate inherited IFS values to exploit word splitting, bypass validation, or inject commands through unquoted expansions.

**Safe Patterns:**

```bash
# Set at script start
IFS=$' \t\n'
readonly IFS

# One-line scope (preferred)
IFS=',' read -ra fields <<< "$csv"

# Local scope in functions
local -- IFS
IFS=','
read -ra fields <<< "$csv"

# Subshell isolation
fields=( $(IFS=','; printf '%s\n' $csv) )

# Save/restore
saved_ifs="$IFS"
IFS=','
read -ra fields <<< "$csv"
IFS="$saved_ifs"
```

**Attack Example:**

```bash
#  Vulnerable - trusts inherited IFS
read -ra parts <<< "$user_input"
# Attacker: export IFS='/'; script splits on '/' not spaces

#  Protected
IFS=$' \t\n'
readonly IFS
read -ra parts <<< "$user_input"
```

**Anti-pattern:**

```bash
#  Wrong - global IFS change without restore
IFS=','
read -ra fields <<< "$data"
# All subsequent operations broken!
```

**Ref:** BCS1203
