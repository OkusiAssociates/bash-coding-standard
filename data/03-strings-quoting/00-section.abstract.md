# Strings & Quoting

**Quote all strings: single quotes for literals, double quotes for expansion.**

## Rules

| Code | Rule |
|------|------|
| BCS0301 | **Quoting Fundamentals** - `'literal'` vs `"$expand"` |
| BCS0302 | **Command Substitution** - Always quote `"$(cmd)"` |
| BCS0303 | **Conditionals** - Quote vars in `[[ "$var" ]]` |
| BCS0304 | **Here Documents** - `<<'EOF'` literal, `<<EOF` expand |
| BCS0305 | **printf** - `printf '%s\n' "$var"` |
| BCS0306 | **Parameter Quoting** - `${param@Q}` for safe display |
| BCS0307 | **Anti-Patterns** - Avoid unquoted expansions |

## Core Pattern

```bash
readonly MSG='Static text'           # Single: literal
echo "Hello, ${USER}"                # Double: expansion
file_list="$(ls -1)"                 # Always quote $()
[[ -n "$var" ]] && echo "$var"       # Quote in conditionals
printf '%s\n' "$@"                   # Quote arguments
```

## Critical Anti-Patterns

```bash
# WRONG → RIGHT
echo $var           → echo "$var"
cmd=$(ls)           → cmd="$(ls)"
[ -n $var ]         → [[ -n "$var" ]]
```

## Key Rationale

1. **Unquoted variables cause word-splitting** - `$var` with spaces becomes multiple args
2. **Single quotes prevent injection** - No expansion = no code execution
3. **ShellCheck enforces** - SC2086 catches unquoted expansions

**Ref:** BCS0300
