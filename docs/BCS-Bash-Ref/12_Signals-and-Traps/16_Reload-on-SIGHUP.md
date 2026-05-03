<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 12.16 Reload-on-SIGHUP

Long-lived daemons conventionally treat SIGHUP as a "reload your
configuration" request. The kernel does not enforce this — SIGHUP's
default action is termination — but `nginx`, `apache`, `sshd`, and
most well-behaved daemons honour it. A bash daemon should follow suit.

```bash
# scenario: minimal SIGHUP-reload (naive — see race below)
reload_config() {
  source -- "$config_file"
  info 'config reloaded'
}
trap reload_config HUP
```

This works for trivial cases but has a race: SIGHUP is asynchronous
and bash dispatches handlers between simple commands. If the signal
arrives partway through a critical section that depends on the *old*
config, the handler reloads under the section's feet and produces a
torn read. The fix is the **flag-and-defer** pattern.

### Flag-and-defer for race-free reload

The handler does the smallest possible work — set a flag — and the
main loop checks the flag at safe points and performs the actual
reload there. Between safe points, the running command sees a
consistent config; reloads happen between iterations, never inside one.

```bash
# scenario: race-free SIGHUP reload via flag-and-defer
#!/usr/bin/env bash
set -euo pipefail; shopt -s inherit_errexit shift_verbose extglob nullglob

declare -i RELOAD_REQUESTED=0
declare -- config_file=/etc/myd/myd.conf

handle_hup() { RELOAD_REQUESTED=1; }       # async-safe: one assignment
trap handle_hup HUP

reload_config() {
  source -- "$config_file"                 # may take time, may fail
  info 'config reloaded'
  RELOAD_REQUESTED=0
}

# Initial load.
source -- "$config_file"

# Main loop — check the flag at safe boundaries, never mid-work.
while :; do
  if (( RELOAD_REQUESTED )); then
    reload_config || warn 'reload failed; keeping previous config'
  fi

  # … one unit of work using the loaded config …
  do_one_iteration

  sleep "${POLL_INTERVAL:-5}" &            # interruptible sleep
  wait $! || true                          # SIGHUP wakes wait, returns
done
```

Key points:

1. The handler does **one** thing — assign to an integer. This is the
   bash analogue of "async-signal-safe" (§12.11). Anything more (file
   I/O, sourcing, logging) risks running concurrently with itself if a
   second SIGHUP arrives.
2. The main loop polls the flag at the top of each iteration. The
   reload happens *between* units of work, not inside one.
3. `sleep N &; wait $!` rather than bare `sleep N`: the `wait` form is
   interruptible by a signal, so SIGHUP wakes the daemon immediately
   instead of forcing it to live out the full sleep before noticing.
4. A failed reload is logged but does not abort the daemon; the
   previous (still-loaded) config remains in effect. This is the
   standard contract for SIGHUP — *try* to reload, don't die trying.

For systemd-managed daemons, wire `ExecReload=/bin/kill -HUP
$MAINPID` in the unit file; the bash logic above is unchanged. Reload
should rebuild *configuration* state only (log paths, DB params); it
should **not** rebind sockets or lockfiles. If a change requires that,
log "restart required" and exit cleanly so a supervisor relaunches.

**See also**: §12.5 (`trap` builtin), §12.6 (pseudo-signals), §12.11
(signal-safe code), §12.12 (idempotent cleanup), §14.7 (logging
discipline), BCS0110 (cleanup and traps), BCS0603 (trap handling),
BCS0111 (configuration file loading).

#fin
