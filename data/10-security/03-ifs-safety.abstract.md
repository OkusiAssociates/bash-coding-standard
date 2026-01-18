## IFS Manipulation Safety

**Never trust inherited IFS. Always protect IFS changes to prevent field splitting attacks.**

**Rationale:** Attackers manipulate IFS in calling environment to exploit word splitting; unprotected IFS enables command injection; changes cause global side effects breaking subsequent operations.

**Safe Patterns:**

```bash
# Pattern 1: One-line assignment (preferred) - applies only to command
IFS=',' read -ra fields <<< "$csv_data"

# Pattern 2: Set at script start, make readonly
IFS=$' \t\n'; readonly IFS; export IFS

# Pattern 3: Local scope in functions
local -- IFS; IFS=','

# Pattern 4: Save/restore
saved_ifs="$IFS"; IFS=','; ...; IFS="$saved_ifs"

# Pattern 5: Subshell isolation
( IFS=','; read -ra fields <<< "$data" )
```

**Anti-patterns:**

```bash
# ✗ Modifying IFS without restore - breaks rest of script
IFS=','; read -ra fields <<< "$data"

# ✗ Trusting inherited IFS - vulnerable to manipulation
#!/bin/bash
read -ra parts <<< "$user_input"  # No IFS protection!
```

**Ref:** BCS1003
