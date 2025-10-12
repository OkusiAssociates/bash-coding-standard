### Arithmetic Operations
\`\`\`bash
# Always declare integer variables explicitly
declare -i i j result

# Increment operations - avoid ++ due to return value issues
i+=1              # ✓ **Preferred** for declared integers
((i+=1))          # ✓ Always returns 0 (success)
((++i))           # Returns value AFTER increment (safe)
((i++))           # DANGEROUS: Returns value BEFORE increment
                  # If i=0, returns 0 (falsey), triggers set -e
                  # Example: i=0; ((i++)) && echo "never prints"

# Arithmetic expressions
((result = x * y + z))
j=$((i * 2 + 5))

# Arithmetic conditionals
if ((i < j)); then
  echo 'i is less than j'
fi

# Short-form evaluation
((x > y)) && echo 'x is greater'
\`\`\`
