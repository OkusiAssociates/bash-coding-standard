## Environment Variable Best Practices

**Validate required environment variables at script startup using parameter expansion error syntax.**

**Rationale:** Fail-fast prevents runtime errors in production when critical configuration missing. Parameter expansion `${VAR:?message}` provides atomic check-and-error.

**Implementation:**
```bash
# Required (exit if unset)
: "${DATABASE_URL:?DATABASE_URL must be set}"

# Optional with default
: "${LOG_LEVEL:=INFO}"

# Bulk validation
declare -a REQUIRED=(DATABASE_URL API_KEY)
for var in "${REQUIRED[@]}"; do
  [[ -n "${!var:-}" ]] || die "Required: $var"
done
```

**Anti-patterns:**
- Checking environment variables deep in business logic ’ validate at startup
- Using `if [[ -z "$VAR" ]]` ’ prefer `${VAR:?error}` for required vars

**Ref:** BCS1404
