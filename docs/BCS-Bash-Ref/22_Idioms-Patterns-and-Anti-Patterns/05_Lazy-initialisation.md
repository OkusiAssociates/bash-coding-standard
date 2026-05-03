<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 22.5 Lazy initialisation

Compute on first use.

```bash
get_config() {
  if [[ -z ${_CONFIG_LOADED:-} ]]; then
    source "$config_file"
    _CONFIG_LOADED=1
  fi
}
```

- Use a sentinel to track first invocation.
- Compute once, reuse.
- Watch for scope: `_CONFIG_LOADED` must be global.
- Use `declare -g` if setting from inside a function.

#fin
