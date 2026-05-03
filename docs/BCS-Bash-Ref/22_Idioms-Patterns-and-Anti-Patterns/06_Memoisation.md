<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 22.6 Memoisation

Cache function results.

```bash
declare -A _MEMO_CACHE

memoised_compute() {
  local key=$1
  if [[ -z ${_MEMO_CACHE[$key]+set} ]]; then
    _MEMO_CACHE[$key]=$(expensive_compute "$key")
  fi
  printf '%s\n' "${_MEMO_CACHE[$key]}"
}
```

- Associative array as cache.
- Test for key existence with `[[ -z ${arr[k]+set} ]]` to distinguish "unset" from "set to empty".
- Cache invalidation strategy: TTL, manual flush, or none.

#fin
