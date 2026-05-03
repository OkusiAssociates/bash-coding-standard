<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 19.13 When Bash is the wrong tool

Bash has limits. Recognise them.

- Numerical computation: use Python/Julia/Octave.
- Complex string parsing (JSON, XML, YAML): use `jq`/`yq`/`xmllint`.
- Tight loops with millions of iterations: use Python or compiled.
- True parallelism: use a real language or GNU parallel.
- Large data structures: use a real language.
- Long-running daemons with state: consider Go, Python, or systemd-managed.
- The "if this script is over 500 lines, consider rewriting it" heuristic.

#fin
