## STDOUT vs STDERR
- All error messages go to `STDERR`
- Place `>&2` at beginning for clarity

```bash
# Preferred
>&2 echo "[$(date -Ins)]: $*"

# Acceptable
echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: $*" >&2
```
