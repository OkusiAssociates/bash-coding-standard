<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 22.9 Reading config files safely

Sourcing arbitrary files is a code-execution risk. Parse instead.

```bash
read_conf() {
  local conf_file=$1 line key value
  while IFS='=' read -r key value; do
    [[ $key == \#* || -z $key ]] && continue
    key=${key// /}
    value=${value%\"}
    value=${value#\"}
    declare -g -- "${key^^}=$value"
  done < "$conf_file"
}
```

- Strict regex-based parsing.
- Reject lines that don't match expected format.
- Whitelist allowed keys.
- Never `source` a config file you don't fully trust.

#fin
