## String Trimming

**Use parameter expansion for whitespace trimming - faster than external commands.**

```bash
trim() {
  local v="$*"
  v="${v#"${v%%[![:blank:]]*}"}"
  echo -n "${v%"${v##*[![:blank:]]}"}"
}
```

**Ref:** BCS0412
