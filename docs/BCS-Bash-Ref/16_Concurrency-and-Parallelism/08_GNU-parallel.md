<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 16.8 GNU parallel

Richer parallel-execution tool than `xargs -P` (§16.7). Heavyweight
external dependency; in return, line-buffered output, per-job logs,
resumable runs, and remote execution (BCS1102).

### Form register

- `parallel cmd ::: arg1 arg2 …` — explicit args after the `:::`
  separator.
- `parallel cmd :::: file` — args from `file` (one per line).
- `parallel cmd ::: a b ::: 1 2` — Cartesian product (`a 1`, `a 2`,
  `b 1`, `b 2`).
- `parallel -j N` — concurrency cap (default: number of CPU cores).
- `parallel --joblog FILE` — append per-job records to FILE.
- `parallel --resume --joblog FILE` — pick up where a previous run
  with the same joblog stopped.
- `parallel --line-buffer` — never split output mid-line.

### `:::` separator example

```bash
# scenario: process every file in two directories, three workers
parallel -j 3 'gzip -k {}' ::: data/*.csv archive/*.csv

# scenario: build a Cartesian product — every host crossed with every action
parallel -j 8 'ssh {1} sudo {2}' ::: ok1 ok2 ok3 ::: 'apt update' 'systemctl status nginx'
```

- `:::` introduces a fixed argument list inline; `::::` reads from a
  file. Multiple `:::` introduce additional dimensions to the
  Cartesian product.
- `{1}`, `{2}`, … reference the Nth input source. `{}` is shorthand
  for `{1}`.
- `{.}` strips the extension; `{/}` keeps only basename; `{//}` only
  dirname.

### Joblog and resume

```bash
# scenario: long-running batch, resume on interruption
parallel --joblog /tmp/build.joblog -j 4 'build_one {}' ::: target_*

# if interrupted (Ctrl-C, kill, system crash):
parallel --resume --joblog /tmp/build.joblog -j 4 'build_one {}' ::: target_*
# only the unfinished targets re-run
```

### Citation

GNU parallel asks scripts that use it to cite the tool in publications:

```text
O. Tange (2018): GNU Parallel 2018, March 2018, https://doi.org/10.5281/zenodo.1146014
```

For long-running production scripts, suppress the citation banner
once with `parallel --citation` (interactive); the banner does not
appear in non-TTY runs by default. See `man parallel` for the full
discussion.

### When to choose `parallel` over `xargs -P`

- Need line-buffered output (`--line-buffer`) — common when piping
  multiple workers' stdout to one log.
- Need resumability (`--joblog --resume`) — important for hour-scale
  batches.
- Need remote execution (`-S host1,host2`) — parallel can SSH out.
- Need a Cartesian product without writing a nested loop.

For the simple "one input → one command" case, `xargs -P` is lighter
and almost always installed.

### See also

- §16.7 — `xargs -P` for the simple case
- §16.5 — hand-rolled fan-out without external deps
- BCS1102 (parallel execution)

#fin
