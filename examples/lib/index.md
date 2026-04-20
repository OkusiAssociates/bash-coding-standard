# BCS Bash Library and Reference Codebases

The following codebases use highly optimized patterns that should be referred to, and where necessary, incorporated into generated code.

```
    ../lib/
    ├── file
    │   ├── cln
    │   │   ├── cln
    │   │   ├── cln.1
    │   │   ├── cln.bash_completion
    │   │   └── tests
    │   │       ├── run-all-tests.sh
    │   │       ├── test-cli-options.sh
    │   │       ├── test-deletion.sh
    │   │       ├── test-edge-cases.sh
    │   │       ├── test-file-patterns.sh
    │   │       └── test-helpers.sh
    │   ├── dux
    │   │   ├── dir-sizes -> dux
    │   │   ├── dux
    │   │   ├── dux.1
    │   │   ├── dux.bash_completion
    │   │   ├── install.sh
    │   │   └── tests
    │   │       ├── run-tests.sh
    │   │       ├── test-arguments.sh
    │   │       ├── test-basic.sh
    │   │       ├── test-edge-cases.sh
    │   │       ├── test-exit-codes.sh
    │   │       ├── test-helpers.sh
    │   │       ├── test-install.sh
    │   │       └── test-output.sh
    │   ├── ls.types
    │   │   ├── ls.types
    │   │   ├── test_ls.types.bats
    │   │   └── types.conf
    │   ├── md2ansi
    │   │   ├── display-ansi-palette
    │   │   ├── md
    │   │   ├── md2ansi
    │   │   ├── md2ansi.1
    │   │   ├── md2ansi.bash -> md2ansi
    │   │   ├── md2ansi.bash_completion
    │   │   ├── md-link-extract
    │   │   ├── mdview
    │   │   ├── mdview.conf
    │   │   ├── rewrite-md-links.lua
    │   │   ├── test
    │   │   │   ├── run_tests
    │   │   │   ├── test_basic.sh
    │   │   │   ├── test_code.sh
    │   │   │   ├── test_edge_cases.sh
    │   │   │   ├── test_footnotes.sh
    │   │   │   ├── test_gaps.sh
    │   │   │   ├── test_mdview.sh
    │   │   │   ├── test_options.sh
    │   │   │   ├── test_security.sh
    │   │   │   ├── test_tables.sh
    │   │   │   └── test_wrapping.sh
    │   │   └── themes
    │   │       ├── github-dark.css
    │   │       ├── github-dark.theme
    │   │       ├── github-light.css
    │   │       └── github-light.theme
    │   ├── symlink
    │   │   ├── symlink
    │   │   ├── symlink.1
    │   │   ├── symlink.bash_completion
    │   │   ├── test-harness
    │   │   ├── test-helpers
    │   │   └── test-symlink
    │   └── which
    │       ├── legacy-which
    │       │   ├── which.debianutils
    │       │   ├── which.debianutils-core22
    │       │   ├── which.nodejs
    │       │   └── which.snap-core
    │       ├── tests
    │       │   ├── benchmark-ci.sh
    │       │   ├── benchmark.sh
    │       │   ├── test_compat.sh
    │       │   ├── test_which_posix.sh
    │       │   └── test_which.sh
    │       ├── which
    │       ├── which.1
    │       └── which.sh
    ├── index.md
    ├── math
    │   └── hr2int
    │       ├── hr2int -> hr2int.bash
    │       ├── hr2int.bash
    │       └── int2hr -> hr2int.bash
    ├── mk-index.sh
    ├── str
    │   ├── post_slug
    │   │   ├── docs
    │   │   ├── post_slug.bash
    │   │   ├── post_slug.js
    │   │   ├── post_slug.php
    │   │   ├── post_slug.py
    │   │   ├── pyproject.toml
    │   │   ├── slugify -> post_slug.bash
    │   │   ├── slugify-files
    │   │   ├── test_files
    │   │   │   ├── Barnes & Noble's Books.pdf
    │   │   │   ├── Hello World\!.txt
    │   │   │   ├── ñoño's café €5.50.html
    │   │   │   ├── Test_File-Already-Slugged.doc
    │   │   │   └── Very Long File Name That Should Be Truncated Because It Is Way Too Long For Most Systems.md
    │   │   ├── unittests
    │   │   │   ├── datasets
    │   │   │   │   ├── booktitles.txt
    │   │   │   │   ├── edge_cases.txt
    │   │   │   │   ├── headlines.txt
    │   │   │   │   └── products.txt
    │   │   │   ├── test_post_slug.py
    │   │   │   └── validate_slug_scripts
    │   │   ├── update_version.sh
    │   │   ├── VERSION
    │   │   └── _version.py
    │   ├── remblanks
    │   │   └── remblanks
    │   └── trim
    │       ├── generate-inc.sh
    │       ├── ltrim.bash
    │       ├── rtrim.bash
    │       ├── squeeze.bash
    │       ├── test
    │       │   ├── benchmark-squeeze.sh
    │       │   ├── benchmark-stream-processing.sh
    │       │   ├── benchmark-trim-vs-trimv.sh
    │       │   ├── fixtures
    │       │   │   ├── expected
    │       │   │   │   ├── empty_trim.txt
    │       │   │   │   ├── multiline_ltrim.txt
    │       │   │   │   ├── multiline_rtrim.txt
    │       │   │   │   ├── multiline_trimall.txt
    │       │   │   │   ├── multiline_trim.txt
    │       │   │   │   └── whitespace_trim.txt
    │       │   │   └── input
    │       │   │       ├── empty.txt
    │       │   │       ├── escape_sequences.txt
    │       │   │       ├── multiline.txt
    │       │   │       ├── tabs_and_spaces.txt
    │       │   │       └── whitespace.txt
    │       │   ├── integration
    │       │   │   ├── test-complex-pipelines.sh
    │       │   │   ├── test-pipes.sh
    │       │   │   └── test-sourced.sh
    │       │   ├── run-tests.sh
    │       │   ├── security
    │       │   │   └── test-injection.sh
    │       │   ├── stress
    │       │   │   └── test-large-inputs.sh
    │       │   ├── test_trimv_pipe.sh
    │       │   ├── unit
    │       │   │   ├── test-binary-safety.sh
    │       │   │   ├── test-concurrent.sh
    │       │   │   ├── test-error-handling.sh
    │       │   │   ├── test-line-endings.sh
    │       │   │   ├── test-locale.sh
    │       │   │   ├── test-ltrim.sh
    │       │   │   ├── test-null-byte.sh
    │       │   │   ├── test-rtrim.sh
    │       │   │   ├── test-sigpipe.sh
    │       │   │   ├── test-squeeze.sh
    │       │   │   ├── test-trimall.sh
    │       │   │   ├── test-trim.sh
    │       │   │   ├── test-trimv-advanced.sh
    │       │   │   ├── test-trimv.sh
    │       │   │   └── test-unicode.sh
    │       │   └── utils.sh
    │       ├── trim.1
    │       ├── trimall.bash
    │       ├── trim.bash
    │       ├── trim.bash_completion
    │       ├── trim.inc.sh
    │       └── trimv.bash
    ├── sys
    │   ├── bitwiddle
    │   │   ├── bitwiddle
    │   │   └── obfuscate
    │   │       ├── obs-common.sh
    │   │       ├── obs-receive.sh
    │   │       └── obs-test.sh
    │   ├── en_ID
    │   │   ├── ensure-persistence.sh
    │   │   ├── install-arch.sh
    │   │   ├── install-fedora.sh
    │   │   ├── install-ubuntu.sh
    │   │   ├── localedata
    │   │   │   └── en_ID
    │   │   └── tests
    │   │       └── test_en_ID.sh
    │   ├── get-chassis
    │   │   ├── get-chassis
    │   │   └── get-chassis.1
    │   ├── get_mac
    │   │   └── get-mac
    │   ├── get_pubkey
    │   │   ├── get-pubkey
    │   │   └── is-authorized-pubkey
    │   ├── shlock
    │   │   ├── install.sh
    │   │   ├── shlock
    │   │   ├── shlock.1
    │   │   ├── shlock.1.md
    │   │   ├── shlock.bash_completion
    │   │   └── tests
    │   │       ├── run_tests.sh
    │   │       ├── test_basic.sh
    │   │       ├── test_concurrent.sh
    │   │       ├── test_edge_cases.sh
    │   │       ├── test_errors.sh
    │   │       ├── test_stale_locks.sh
    │   │       ├── test_steal.sh
    │   │       └── test_wait_timeout.sh
    │   └── stopwords.bash
    │       ├── install.sh
    │       ├── nltk_data
    │       │   └── tokenizers
    │       │       └── punkt
    │       ├── stopwords
    │       └── tests
    │           ├── benchmark_readme.sh
    │           ├── benchmark.sh
    │           ├── functional_tests.sh
    │           └── stopwords_python.py
    └── time
        ├── elapsed_time
        │   ├── elapsed_time
        │   └── elapsed_time.py
        └── spacetime
            ├── spacetime
            ├── spacetime.php
            └── spacetime.py
    
    51 directories, 181 files

```

---

- [bitwiddle](/ai/scripts/Okusi/BCS/examples/lib/sys/bitwiddle) - bitwiddle 1.0.0 - Apply bitwise operations (OR, AND, XOR) to each byte of a string.
  > Usage: bitwiddle [OPTIONS] STRING OPERATION OPERAND
  >   STRING     Input string to process (use "-" for stdin).
  >   OPERATION  Bitwise operation: or, and, xor (case-insensitive).
  >   OPERAND    Integer operand for the bitwise operation.
  > (source: /ai/scripts/Okusi/BCS/examples/lib/sys/bitwiddle/bitwiddle [symlink])
- [cln](/usr/local/bin) - cln 1.1.0 - Search for and delete junk/trash/rubbish files.
  > Recursively removes all temporary/junk files.
  > The following filespecs are removed by default:
  >   ( *~ ~* .~* .*~ DEADJOE dead.letter wget-log* *.tmp )
  > Config files (first found wins):
  > (source: /usr/local/bin/cln [makefile])
  > (manpage: man -l /usr/local/share/man/man1/cln.1)
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
- [md2ansi](/usr/local/bin) - md2ansi 1.0.1 - Convert Markdown to ANSI-colored terminal output
  > A zero-dependency Bash implementation that renders markdown files with color
  > and style directly in your terminal.
  > Usage: md2ansi [OPTIONS] [file1.md [file2.md ...]]
  >        cat README.md | md2ansi
  > (source: /usr/local/bin/md2ansi [makefile])
  > (manpage: man -l /usr/local/share/man/man1/md2ansi.1.gz)
- [md-link-extract](/usr/local/bin) - Usage: md-link-extract file [file...]
  > Extract links from text/markdown files
  > (source: /usr/local/bin/md-link-extract [makefile])
- [mdview](/usr/local/bin) - mdview 1.0.1 — Markdown viewer using pandoc with theme support
  > Usage: mdview [OPTIONS] <file>
  > Options:
  >   -t, --theme NAME         Theme name (default: github-dark)
  >   -s, --window-size WxH    Browser window size (default: 960x1080)
  > (source: /usr/local/bin/mdview [makefile])
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
- [which](/usr/local/bin) - which 2.0 - Locate executables in PATH
  > Usage: which [OPTIONS] [--] command ...
  > Options:
  >   -a, --all        Print all matches, not just first
  >   -c, --canonical  Resolve symlinks via realpath
  > (source: /usr/local/bin/which [makefile])
  > (manpage: man -l /usr/local/share/man/man1/which.1)
