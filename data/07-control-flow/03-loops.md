### Loops
\`\`\`bash
# For loops with arrays
for spec in "${Specs[@]}"; do
  find_expr+=(-name "$spec" -o)
done

# While loops for argument parsing
while (($#)); do
  case $1 in
    # ... ;;
  esac
  shift
done

# Reading command output
readarray -t found_files < <(find ... 2>/dev/null || true)
\`\`\`
