### Array Declaration and Usage
\`\`\`bash
# Indexed arrays
declare -a DELETE_FILES=('*~' '~*' '.~*')
local -a Paths=()

# Adding elements
Paths+=("$1")
add_specs+=("$spec")

# Array iteration
for path in "${Paths[@]}"; do
  process "$path"
done

# Array length
((${#Paths[@]})) || Paths=('.')

# Reading into array
IFS=',' read -ra ADD_SPECS <<< "$1"
readarray -t found_files < <(command)

# Unset last array element
unset 'find_expr[${#find_expr[@]}-1]'
\`\`\`
