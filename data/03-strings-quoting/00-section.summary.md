# Strings & Quoting

Core principle: **single quotes** for static strings, **double quotes** when variable expansion is needed.

**7 Rules:**

1. **Quoting Fundamentals** (BCS0301) - Core rules for static vs. dynamic strings
2. **Command Substitution** (BCS0302) - Quoting `$(...)` results
3. **Quoting in Conditionals** (BCS0303) - Variable quoting in `[[ ]]`
4. **Here Documents** (BCS0304) - Delimiter quoting for heredocs
5. **printf Patterns** (BCS0305) - Format string and argument quoting
6. **Parameter Quoting** (BCS0306) - Using `${param@Q}` for safe display
7. **Anti-Patterns** (BCS0307) - Common quoting mistakes to avoid

Single quotes signal "literal text"; double quotes signal "variable expansion needed."
