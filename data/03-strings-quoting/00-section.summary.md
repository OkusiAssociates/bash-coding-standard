# Strings & Quoting

Quoting rules prevent word-splitting errors and clarify code intent. **Single quotes** for static strings, **double quotes** when variable expansion is needed.

**7 Rules:**

1. **Quoting Fundamentals** (BCS0301) - Static vs. dynamic strings
2. **Command Substitution** (BCS0302) - Quoting `$(...)` results
3. **Quoting in Conditionals** (BCS0303) - Variable quoting in `[[ ]]`
4. **Here Documents** (BCS0304) - Delimiter quoting for heredocs
5. **printf Patterns** (BCS0305) - Format string and argument quoting
6. **Parameter Quoting** (BCS0306) - Using `${param@Q}` for safe display
7. **Anti-Patterns** (BCS0307) - Common quoting mistakes to avoid

**Key principle:** Single quotes = literal text; double quotes = variable expansion needed.
