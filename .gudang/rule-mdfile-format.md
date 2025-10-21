# Rule Markdown File Format Specification

This document defines the comprehensive format for rule markdown files in the `data/` directory of the bash-coding-standard repository. Follow this format to ensure consistency, clarity, and pedagogical effectiveness for both human programmers and AI assistants.

---

## System Prompt for Creating Rule Files

You are creating a rule documentation file for the Bash Coding Standard. Your goal is to make the rule **crystal clear** to both human programmers and AI assistants. Every rule must explain not just WHAT to do, but WHY it matters.

### Core Principles

1. **Pedagogical Intent**: Teach the concept, don't just state the rule
2. **Dual Audience**: Write for both humans and AI assistants
3. **Show, Don't Just Tell**: Use examples extensively
4. **Explain the WHY**: Always include rationale for rules
5. **Anticipate Mistakes**: Show common anti-patterns
6. **Be Complete**: Cover edge cases, gotchas, and special situations
7. **Be Precise**: Use exact terminology and syntax
8. **Be Practical**: Include real-world usage patterns

---

## Required File Structure

Every rule file MUST follow this structure:

### 1. Title (Required)
```markdown
### Rule Name
```

**Requirements:**
- Use level 3 header (`###`)
- Descriptive, action-oriented name (e.g., "Array Declaration and Usage", "Exit on Error")
- Title case for important words
- Matches the concept being taught

### 2. Opening Statement (Required)
```markdown
**Brief description or bold statement of the rule.**
```

**Requirements:**
- One or two sentences maximum
- States the core rule or principle
- Often in bold for emphasis
- Can be an imperative statement ("Always use...", "Never do...")

### 3. Basic Example (Required)
```markdown
```bash
# Simple example showing the rule
declare -a array=()
array+=("element")
```
```

**Requirements:**
- Use fenced code blocks with `bash` language marker
- Show the simplest, clearest example first
- Include inline comments explaining what each line does
- Demonstrate correct usage only (anti-patterns come later)

### 4. Rationale Section (Strongly Recommended)
```markdown
**Rationale:**
- **Point 1**: Explanation of first reason
- **Point 2**: Explanation of second reason
- **Point 3**: Explanation of third reason
```

**Requirements:**
- Explain WHY the rule exists
- Use bullet points with bold labels
- Focus on: Performance, Safety, Clarity, Reliability, Maintainability
- Provide technical reasons, not just "it's better"
- 3-7 bullet points typically sufficient

### 5. Detailed Sections (Required for Complex Topics)

Break complex topics into subsections with bold headers:

```markdown
**Specific aspect of the rule:**

```bash
# Example demonstrating this aspect
code_here
```

Explanation paragraph.
```

**Requirements:**
- Use bold (`**text**`) for subsection headers
- Each subsection focuses on one specific aspect
- Include code example for each subsection
- Follow with explanation paragraph
- Logical progression from simple to complex

### 6. Comparison Tables (When Applicable)

Use tables to compare options, operators, or alternatives:

```markdown
| Feature | Option A | Option B |
|---------|----------|----------|
| Speed | Fast | Slow |
| Safety | High | Low |
```

**Requirements:**
- Use for comparing multiple approaches
- Use for listing operators with meanings
- Use for showing feature matrices
- Keep columns concise (max 80 chars per cell)
- Always include header row

### 7. Anti-Patterns Section (Strongly Recommended)
```markdown
**Anti-patterns to avoid:**

```bash
# ✗ Wrong - description of what's wrong
bad_code_here

# ✓ Correct - description of what's right
good_code_here

# ✗ Wrong - another anti-pattern
more_bad_code

# ✓ Correct - correct approach
correct_code
```
```

**Requirements:**
- Use `✗` marker (U+2717) for wrong examples
- Use `✓` marker (U+2713) for correct examples
- Always pair wrong with correct
- Explain in comments WHY it's wrong/right
- Show at least 3-5 anti-patterns
- Make the mistakes realistic and common

### 8. Edge Cases and Gotchas (When Applicable)
```markdown
**Edge cases / Common gotchas:**

```bash
# Gotcha: Description of the trap
code_demonstrating_gotcha

# Solution: How to avoid it
correct_approach
```
```

**Requirements:**
- Highlight non-obvious behavior
- Show where even experienced programmers make mistakes
- Explain the surprising or counterintuitive behavior
- Always provide the solution

### 9. Practical Examples (Recommended)
```markdown
**Complete example / Real-world usage:**

```bash
#!/usr/bin/env bash
# Full working example showing the rule in context
complete_script_here
```
```

**Requirements:**
- Show rule in realistic context
- Include full script structure if illustrative
- Demonstrate integration with other practices
- Comment thoroughly

### 10. Summary (Optional but Recommended)
```markdown
**Summary:**
- **Key point 1**: Brief restatement
- **Key point 2**: Brief restatement
- **Key point 3**: Brief restatement
```

or

```markdown
**Key principle:** One-sentence summary of the core rule.
```

**Requirements:**
- Distill the rule to essential points
- Quick reference for readers who skim
- 3-7 bullet points or single principle statement

---

## Formatting Conventions

### Code Blocks

**Bash code blocks:**
```markdown
```bash
# Always use the bash language marker
code_here
```
```

**Requirements:**
- Always use `bash` language marker
- Include comments explaining non-obvious code
- Use proper indentation (2 spaces)
- Show complete, working code when possible

### Inline Code

Use backticks for inline code references:
- Variable names: `` `$variable` ``
- Commands: `` `declare` ``
- Options: `` `-e` ``
- File names: `` `script.sh` ``

### Emphasis

**Bold** for:
- Subsection headers within a rule
- Key terms when first introduced
- Emphasis on critical points
- Labels in bullet points

*Italics* for:
- Rarely used in rule files
- Only for subtle emphasis if needed

### Lists

**Unordered lists:**
```markdown
- **Label**: Explanation
- **Label**: Explanation
```

**Ordered lists:**
```markdown
1. First step
2. Second step
3. Third step
```

Use ordered lists for sequential steps, unordered for non-sequential points.

### Check Marks and X Marks

**Standard symbols:**
- ✓ (U+2713) - Correct pattern
- ✗ (U+2717) - Incorrect pattern

**Usage:**
```markdown
# ✓ Correct - explanation
good_code

# ✗ Wrong - explanation
bad_code
```

Always include comment explaining why.

### Escaped Characters

In markdown files that will be processed, escape backticks in code blocks:
```markdown
\`\`\`bash
code here
\`\`\`
```

This is necessary when the file is read by scripts that might interpret the backticks.

---

## Content Guidelines

### Explaining Rationale

**Good rationale (specific and technical):**
```markdown
**Rationale:**
- **Performance**: Builtins are 10-100x faster (no process creation)
- **Safety**: No word splitting or glob expansion on variables
- **Clarity**: Signals to readers that variable is an array
```

**Poor rationale (vague and non-technical):**
```markdown
**Rationale:**
- It's better
- More reliable
- Recommended approach
```

### Writing Anti-Patterns

**Good anti-pattern (shows real mistake with clear explanation):**
```bash
# ✗ Wrong - unquoted variable breaks with spaces
for file in ${files[@]}; do

# ✓ Correct - quoted expansion preserves spacing
for file in "${files[@]}"; do
```

**Poor anti-pattern (contrived or unclear):**
```bash
# ✗ Bad
code

# ✓ Good
different_code
```

### Providing Examples

**Good example (complete, working, realistic):**
```bash
# Validate required file exists and is readable
validate_file() {
  local file=$1
  [[ -f "$file" ]] || die 2 "File not found: $file"
  [[ -r "$file" ]] || die 5 "Cannot read file: $file"
}
```

**Poor example (incomplete or trivial):**
```bash
# Check file
check_file() {
  [[ -f "$file" ]]
}
```

### Demonstrating Edge Cases

**Good edge case (shows surprising behavior):**
```bash
# Edge case: i=0 with post-increment triggers set -e exit!
i=0
((i++))  # Returns 0 (false), script exits with set -e
echo "Never reached"  # This line never executes
```

**Poor edge case (obvious or not helpful):**
```bash
# Edge case: variable might be empty
[[ -n "$var" ]]
```

---

## Examples of Well-Formatted Sections

### Example 1: Simple Rule

```markdown
### Variable Expansion Guidelines

**General Rule:** Always quote variables with `"$var"` as the default form. Only use braces `"${var}"` when syntactically necessary.

```bash
# ✓ Correct - simple form
echo "$path"

# ✗ Wrong - unnecessary braces
echo "${path}"
```

**Rationale:**
- **Clarity**: Braces add visual noise without value when not required
- **Readability**: Using braces only when necessary makes necessary cases stand out
- **Convention**: Matches common practice in modern bash scripts

**When braces are required:**

1. **Parameter expansion operations:**
```bash
"${var##*/}"      # Remove longest prefix pattern
"${var:-default}" # Default value
```

2. **Variable concatenation:**
```bash
"${var1}${var2}"  # Join variables with no separator
```

**Anti-patterns to avoid:**

```bash
# ✗ Wrong - braces not needed
echo "${PREFIX}/bin"

# ✓ Correct - separator makes braces unnecessary
echo "$PREFIX/bin"
```
```

### Example 2: Complex Rule with Multiple Subsections

```markdown
### Array Declaration and Usage

**Always use explicit array declaration and quoted expansion.**

**Declaring arrays:**

```bash
# Indexed arrays (explicitly declared)
declare -a files=()
local -a paths=()
```

**Rationale for explicit declaration:**
- **Clarity**: Signals to readers that variable is an array
- **Type safety**: Prevents accidental scalar assignment
- **Scope control**: Use `local -a` in functions to prevent global pollution

**Array iteration:**

```bash
# ✓ Correct - quoted expansion
for file in "${files[@]}"; do
  process "$file"
done

# ✗ Wrong - unquoted breaks with spaces
for file in ${files[@]}; do
  process "$file"
done
```

**Array length:**

```bash
# Get number of elements
count=${#array[@]}

# Check if empty
((${#array[@]} > 0)) && process_array
```

**Anti-patterns to avoid:**

```bash
# ✗ Wrong - unquoted array expansion
rm ${files[@]}

# ✓ Correct - quoted expansion
rm "${files[@]}"
```

**Summary:**
- Always declare arrays explicitly with `declare -a`
- Always quote array expansions: `"${array[@]}"`
- Use `${#array[@]}` for array length
```

---

## Quality Checklist

Before finalizing a rule file, verify:

- [ ] Title is descriptive and clear (level 3 header)
- [ ] Opening statement is bold and concise
- [ ] At least one basic code example is provided
- [ ] Rationale section explains WHY (3+ reasons)
- [ ] Code examples use `bash` language marker
- [ ] Anti-patterns section shows wrong vs correct (3+ pairs)
- [ ] All code is syntactically correct
- [ ] Examples are realistic and practical
- [ ] Comments explain non-obvious code
- [ ] Edge cases and gotchas are highlighted (if applicable)
- [ ] Tables are used for comparisons (if applicable)
- [ ] Summary captures key points (if included)
- [ ] Formatting is consistent (✓/✗ markers, bold headers)
- [ ] No vague statements ("it's better", "recommended")
- [ ] Technical explanations are specific and detailed
- [ ] File teaches the concept, not just states it

---

## File Naming Conventions

Files should be named:
```
NN-descriptive-name.md
```

Where:
- `NN` is a two-digit number for sort order (01, 02, 03...)
- `descriptive-name` uses kebab-case
- `.md` extension

Examples:
- `01-exit-on-error.md`
- `02-exit-codes.md`
- `03-trap-handling.md`

---

## Length Guidelines

**Minimum viable rule file:**
- ~50-100 lines
- Title, opening, example, rationale, 1-2 anti-patterns

**Typical rule file:**
- ~100-200 lines
- All required sections plus edge cases and practical examples

**Complex rule file:**
- ~200-400 lines
- Multiple subsections, comprehensive examples, tables, extensive anti-patterns
- Examples: arrays, conditionals, argument parsing, trap handling

**Do not artificially inflate file length**, but ensure completeness. A simple rule can be short; a complex rule needs detail.

---

## Special Considerations

### For Core Safety Rules

Rules related to safety (set -e, input sanitization, security) should be extra thorough:
- Emphasize consequences of not following the rule
- Show multiple examples of what can go wrong
- Provide comprehensive anti-patterns
- Include security considerations

### For Performance Rules

Rules about performance should include:
- Specific performance comparisons (e.g., "10-100x faster")
- Examples showing the performance difference
- Explanation of why the performance difference exists

### For Syntax Rules

Rules about syntax and style should include:
- Exact syntax requirements
- Multiple variations and when to use each
- Edge cases where syntax behaves unexpectedly

### For Integration Rules

Rules that integrate with other rules should:
- Reference related rules (e.g., "Used with `set -e` from Section 8")
- Show how rules work together
- Demonstrate complete working examples

---

## Maintenance Notes

When updating an existing rule file:

1. **Preserve existing examples** unless they're wrong
2. **Add rationale** if missing
3. **Expand anti-patterns** if insufficient
4. **Add edge cases** if discovered
5. **Update for new bash versions** if applicable
6. **Keep pedagogical intent** - don't just add content, improve understanding

The goal is always to make the rule **clearer, more complete, and more practical**, not just longer.

---

## Meta: This Document

This document itself serves as an example of clear technical documentation:
- Structured with clear hierarchy
- Uses examples extensively
- Explains the "why" behind format requirements
- Provides checklists and guidelines
- Anticipates questions and edge cases

Apply these same principles when creating rule files.

#fin
