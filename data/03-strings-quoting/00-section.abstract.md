# Strings & Quoting

**Single quotes for static strings; double quotes when variable expansion needed.**

**7 Rules:** Quoting Fundamentals (BCS0301) | Command Substitution (BCS0302) | Conditionals (BCS0303) | Here Documents (BCS0304) | printf Patterns (BCS0305) | Parameter Quoting (BCS0306) | Anti-Patterns (BCS0307)

```bash
info 'Static message'           # Single quotes - no variables
info "Processing $file"         # Double quotes - expansion needed
```

**Ref:** BCS0300
