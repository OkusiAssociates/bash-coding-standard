### Array Expansions

Always quote array expansions with double quotes:

```bash
# Quote array expansions
"${array[@]}"          # All elements as separate words
"${array[*]}"          # All elements as single word (space-separated)

# Array iteration
for item in "${items[@]}"; do
  process "$item"
done

# Function arguments from array
my_function "${args[@]}"
```
