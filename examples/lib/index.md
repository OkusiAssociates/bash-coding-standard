# BCS Bash Library and Reference Codebases

The following codebases use highly optimized patterns that should be referred to, and where necessary, incorporated into generated code.

- [bitwiddle](/ai/scripts/Okusi/BCS/examples/lib/sys/bitwiddle) - bitwiddle 1.0.0 - Apply bitwise operations (OR, AND, XOR) to each byte of a string.
  > Usage: bitwiddle [OPTIONS] STRING OPERATION OPERAND
  >   STRING     Input string to process (use "-" for stdin).
  >   OPERATION  Bitwise operation: or, and, xor (case-insensitive).
  >   OPERAND    Integer operand for the bitwise operation.
  > (source: /ai/scripts/Okusi/BCS/examples/lib/sys/bitwiddle/bitwiddle [symlink])
- [elapsed_time](/usr/local/bin) - elapsed_time 1.1.0 - Return time duration as human-readable string
  > Use $EPOCHREALTIME to return micro-second resolution time duration
  > as human-readable string.
  > Use $EPOCHTIME or $SECONDS to return second resolution time duration
  > as human-readable string.
  > (source: /usr/local/bin/elapsed_time [makefile])
- [get-mac](/ai/scripts/Okusi/BCS/examples/lib/sys/get_mac) - get-mac 1.0.0 - Get MAC address for machine
  > When sourced, also includes function is_approved_mac
  > from list in file /etc/network/approved_macs
  > Usage: get-mac [-h] [-V]
  > Print the MAC address of the primary network interface.
  > (source: /ai/scripts/Okusi/BCS/examples/lib/sys/get_mac/get-mac [symlink])
- [get-pubkey](/ai/scripts/Okusi/BCS/examples/lib/sys/get_pubkey) - get-pubkey 1.0.0 - print the current user's SSH public key
  > Usage: get-pubkey [-h] [-V] [USER]
  > Print the first available SSH public key for USER (default: current user).
  > Key types are checked in order: ed25519, ecdsa, rsa.
  > Can also be sourced as a library:
  > (source: /ai/scripts/Okusi/BCS/examples/lib/sys/get_pubkey/get-pubkey [symlink])
- [hr2int](/ai/scripts/Okusi/BCS/examples/lib/math/hr2int) - hr2int 1.0.0 - convert human-readable numbers to integers
  > Usage: hr2int NUMBER[SUFFIX] [NUMBER[SUFFIX]]...
  > Converts each NUMBER to a plain integer. The SUFFIX, if present,
  > determines the conversion base:
  >   Lowercase (b,k,m,g,t,p)   IEC binary  (powers of 1024)
  > (source: /ai/scripts/Okusi/BCS/examples/lib/math/hr2int/hr2int.bash [symlink])
- [int2hr](/ai/scripts/Okusi/BCS/examples/lib/math/hr2int) - int2hr 1.0.0 - convert integers to human-readable numbers
  > Usage: int2hr NUMBER [FORMAT] [NUMBER [FORMAT]]...
  > Converts each NUMBER to a human-readable form. FORMAT is optional
  > and controls the base and suffix case:
  >   si    SI decimal  (base 1000), uppercase suffix  [default]
  > (source: /ai/scripts/Okusi/BCS/examples/lib/math/hr2int/hr2int.bash [symlink])
- [is-authorized-pubkey](/ai/scripts/Okusi/BCS/examples/lib/sys/get_pubkey) - is-authorized-pubkey 1.0.0 - check if a public key is in authorized_keys
  > Usage: is-authorized-pubkey [-h] [-V] PUBKEY
  > Check whether PUBKEY exists in the authorized_keys file.
  > Matches on the key blob (type + base64), ignoring comments.
  > Input may include a mac|pubkey prefix, which is stripped before matching.
  > (source: /ai/scripts/Okusi/BCS/examples/lib/sys/get_pubkey/is-authorized-pubkey [symlink])
- [ls.types](/usr/local/bin) - ls.types 1.1.0 -- List script files by shebang or extension via symlink dispatch
  > Usage: ls.types [OPTIONS]
  >        <symlink>   [OPTIONS] [DIR...]
  > ls.types is a dispatcher. Invoke via a symlink (e.g. ls.bash, ls.python)
  > to list files of that type. Direct invocation supports management only.
  > (source: /usr/local/bin/ls.types [makefile])
  > (manpage: man -l /usr/local/share/man/man1/ls.types.1)
- [shlock](/usr/local/bin) - shlock 2.0.0 - file-based locking system with stale lock detection
  > Usage: shlock [OPTIONS] [LOCKNAME] -- COMMAND [ARGS...]
  > Runs COMMAND while holding an exclusive flock-based lock. Prevents multiple
  > instances of the same operation from running concurrently, with automatic
  > stale-lock cleanup for crashed holders.
  > (source: /usr/local/bin/shlock [makefile])
  > (manpage: man -l /usr/local/share/man/man1/shlock.1)
- [spacetime](/ai/scripts/Okusi/BCS/examples/lib/time/spacetime) - spacetime 1.1.0 - Format and display current time with template support
  > Usage: spacetime [template]
  > Without arguments: Returns formatted time as
  >   "DayOfWeek YYYY-MM-DD HH:MM:SS TZ Timezone"
  > With template: Returns custom format using placeholders
  > (source: /ai/scripts/Okusi/BCS/examples/lib/time/spacetime/spacetime [symlink])
- [symlink](/usr/local/bin) - symlink 1.4.0 - Create symlinks in /usr/local/bin for executables
  > Requires root privileges (auto-elevates via sudo).
  > USAGE:
  >   symlink [OPTIONS] scriptpath...     Direct linking
  >   symlink -S [OPTIONS] [startpath]    Scan for .symlink files (depth ≤5)
  > (source: /usr/local/bin/symlink [makefile])
  > (manpage: man -l /usr/local/share/man/man1/symlink.1)
