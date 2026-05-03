<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 16.3 `wait $pid` for specific child

Capture per-child exit status.

```bash
sleep 1 & pid1=$!
sleep 2 & pid2=$!
wait $pid1; rc1=$?
wait $pid2; rc2=$?
```

- After waiting, status accessible via `$?` or saved variable.
- `wait` on a PID that's already been reaped returns its remembered status (bash keeps a small cache).
- Order doesn't matter for capturing — wait blocks until that child exits.

#fin
