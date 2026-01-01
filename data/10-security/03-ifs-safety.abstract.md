## IFS Manipulation Safety

**Never trust inherited IFS; always protect IFS changes to prevent field splitting attacks.**

**Why:** Attackers manipulate IFS to exploit word splitting �' command injection, privilege escalation, bypass validation.

**Safe Patterns:**

```bash
# Pattern 1: One-line (preferred for single commands)
IFS=',' read -ra fields <<< "$csv_data"

# Pattern 2: Local IFS in function
local -- IFS; IFS=','
read -ra fields <<< "$data"

# Pattern 3: Script start protection
IFS=$' \t\n'; readonly IFS; export IFS
```

**Anti-patterns:**

```bash
# ✗ Global modification without restore
IFS=','
read -ra fields <<< "$data"
# IFS stays ',' for rest of script!

# ✗ Trusting inherited IFS
#!/bin/bash
read -ra parts <<< "$input"  # Attacker controls IFS!
```

**Key Rules:**
- Set `IFS=$' \t\n'; readonly IFS` at script start
- Use `IFS='x' read` for single operations (auto-resets)
- Use `local -- IFS` in functions for scoped changes
- Use subshells `( IFS=','; ... )` for isolation

**Ref:** BCS1003
