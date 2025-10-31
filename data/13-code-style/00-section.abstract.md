# Code Style & Best Practices

**Comprehensive coding conventions for readable, maintainable Bash 5.2+ scripts organized by theme.**

## Core Standards

**Formatting**: 2-space indentation (never tabs), 100-char lines (URLs/paths excepted), consistent alignment.

**Comments**: Explain WHY (rationale, business logic), not WHAT (code shows). Focus on intent and non-obvious decisions.

**Visual Structure**: Blank lines separate logical sections; banner-style section markers: `# === Section Name ===`

## Language Practices

**Bash Idioms**: Use modern features (`[[ ]]`, `(())`, process substitution), prefer built-ins over externals.

**Patterns**: `"$var"` default → braces only when required; single quotes for static strings; `i+=1` not `((i++))`

## Development Standards

**ShellCheck**: Compulsory compliance; document disabled checks with rationale comments.

**Testing**: Validate all code paths; use `set -x` for debugging; trap ERR for diagnostics.

**Version Control**: Atomic commits; meaningful messages; `.gitignore` temporaries.

**Ref:** BCS1300
