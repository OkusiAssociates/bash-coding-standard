<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 24.5 The job table

Per-shell table of jobs.

- Each entry: job number, PID(s), state (Running, Stopped, Done), command text.
- Built when job control is on.
- Subshells start with empty job table.
- Garbage-collected: entries removed once status is reported.

#fin
