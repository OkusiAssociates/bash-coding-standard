<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 3.2 Reserved words

A small set of identifiers that Bash recognises as syntax keywords when they appear in **command position**. Outside that position they are ordinary tokens. Quoting any character of a reserved word suppresses the recognition entirely — useful occasionally, surprising often.

The full list (Bash 5.2):

```
!  [[  ]]  {  }  case  coproc  do  done  elif  else  esac
fi  for  function  if  in  select  then  time  until  while
```

Recognition contexts (where a token may be parsed as a reserved word):

- Head of a command — `if true; then …`.
- Immediately after another reserved word that introduces a compound — `do`, `then`, `else`, `in`, etc.
- After a list separator — `;`, `&`, `&&`, `||`, newline.

Anywhere else, the same characters are literal. Quoting any character also suppresses recognition: `\if`, `'if'`, `"if"`, `i\f` are all the literal command name `if`. This is occasionally exploited to call an external program named the same as a keyword.

```bash
# scenario: reserved-word recognition vs literal context
if true; then echo if-branch; fi      # `if` recognised, `fi` recognised
# ⇒ if-branch
echo if then else fi                  # `if`, `then`, `else`, `fi` all literal — echo's args
# ⇒ if then else fi
```

```bash
# scenario: quoting suppresses keyword recognition
\if --help 2>&1 | head -1
# ⇒ bash: if: command not found
# (Bash looked up "if" on PATH because the backslash demoted it from keyword to command name)
"if" "[[" "}"                         # all three demoted; PATH lookups, all fail
```

Aliases interact with reserved words: aliases are expanded only after reserved-word recognition, so an alias named `if` is shadowed by the keyword and never fires. Reserved words always win over aliases (and over functions and over builtins) when in a recognition context.

`time` is the lone curiosity — it is a reserved word (so `time pipeline` works at any position where the grammar permits it), not a builtin. Use `command time` or `/usr/bin/time` to get the external GNU `time` (§19.3 explains the resulting differences).

The 1-element subset that BCS scripts touch most often: `function` is permitted but BCS0401 mandates the parameter-less `name() { … }` form, never `function name { … }`.

**See also**: §3.1 (tokenisation — how the parser decides "is this a reserved word here?"), §3.5–§3.6 (single and double quotes — what suppresses recognition), §3.10 (shell grammar productions that introduce these contexts), §4 (functions — `function` reserved word and BCS0401 form mandate).

#fin
