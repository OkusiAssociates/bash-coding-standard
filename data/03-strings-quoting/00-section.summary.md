# Strings & Quoting

Core quoting rules preventing word-splitting errors: **single quotes** for static strings, **double quotes** for variable expansion.

**7 Rules:**

1. **Quoting Fundamentals** (BCS0301) - Static vs. dynamic strings
2. **Command Substitution** (BCS0302) - Quoting `$(...)` results
3. **Quoting in Conditionals** (BCS0303) - Variable quoting in `[[ ]]`
4. **Here Documents** (BCS0304) - Delimiter quoting for heredocs
5. **printf Patterns** (BCS0305) - Format string and argument quoting
6. **Parameter Quoting** (BCS0306) - `${param@Q}` for safe display
7. **Anti-Patterns** (BCS0307) - Common quoting mistakes

**Key principle:** Single quotes = "literal text"; double quotes = "expansion needed."
