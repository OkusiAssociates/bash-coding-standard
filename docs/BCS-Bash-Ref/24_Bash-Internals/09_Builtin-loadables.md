<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 24.9 Builtin loadables

Bash supports loading additional builtins from shared objects at
runtime. The mechanism turns a `.so` file with the right symbols into a
new builtin command, indistinguishable from the ones compiled into bash
itself: same dispatch path, same speed, no fork/exec cost. The bash
distribution ships ~30 stock loadables in `examples/loadables/`; many
distros package these and install them under `/usr/lib/bash/` (Debian,
Ubuntu) or `/usr/local/lib/bash/` (Homebrew, source builds).

Use cases:

- replacing a hot-path external (`sleep`, `mkdir`, `realpath`, `head`,
  `tee`) with a fork-free builtin;
- exposing a syscall bash does not normally provide (`mkfifo`, `head`,
  `print`);
- one-off performance-critical operations where the per-fork cost
  dominates the actual work.

### Loading a stock loadable

`enable -f /path/to/builtin.so name` registers the loadable as a
builtin called `name`. After that, `name args…` runs through the
builtin dispatch path with no fork.

```bash
# scenario: replace the `sleep` external with the loadable on Ubuntu
enable -f /usr/lib/bash/sleep sleep
# Now `sleep 0.1` is a builtin call — no /bin/sleep fork+exec.

# Same for mkdir:
enable -f /usr/lib/bash/mkdir mkdir
mkdir -p /tmp/builtin-demo

# Same for realpath:
enable -f /usr/lib/bash/realpath realpath
realpath /etc/hosts
```

`enable -d name` removes the loadable; `enable -f -d /path/to/foo.so
name` is the explicit unload form. `enable -p` lists every builtin
currently enabled, marking external loadables with their path. `enable
-n name` disables a builtin without removing it (useful in defensive
testing — "ensure the script works even if `sleep` is the external").

The performance gap matters most in tight loops. A microbench on a
modern Linux box: 10 000 iterations of the external `sleep 0` runs in
~3 s (almost entirely fork/exec); 10 000 iterations of the loadable
`sleep 0` runs in ~0.05 s. For scripts that sleep on every iteration
of a polling loop, the loadable shaves real time off real workloads.

### Where the .so files live

Distribution-dependent. Common paths on a typical Linux install:

- **Debian / Ubuntu**: `/usr/lib/bash/` (`bash-builtins` package)
- **Fedora / RHEL**: `/usr/lib64/bash/` or none (compile from
  `bash-source`)
- **macOS Homebrew**: `$(brew --prefix)/lib/bash/`
- **Source build**: `/usr/local/lib/bash/`

`pkg-config --variable=loadablesdir bash` returns the canonical path
when bash is built with pkg-config metadata.

### Writing your own

A loadable is C source compiled with bash's `builtins.h` interface and
linked against `libbash`. The bash source tree's `examples/loadables/`
directory contains 30+ examples ranging from trivial (`hello.c`) to
useful (`mkfifo.c`, `seq.c`). The compile invocation is approximately:

```bash
gcc -fPIC -shared -o myhello.so \
  -I/usr/include/bash -I/usr/include/bash/builtins -I/usr/include/bash/include \
  myhello.c
```

The build is sufficiently fragile across bash-versions and distros that
the practical advice is: **use the stock loadables**, and if you need
something custom, factor it as an external program rather than as a
loadable. The loadable interface is not a stable ABI, and a script that
depends on a custom loadable becomes binary-coupled to a specific bash
version.

### `--enable-loadable-builtins`

Some bash builds (particularly Alpine's BusyBox-derived environments
and some hardened distros) ship without loadable-builtin support. The
`./configure --enable-loadable-builtins` flag at build time controls
this. `enable -f` returns "dynamic loading not available" when the
support is missing.

**See also**: §24.10 (reading the bash source) for `examples/loadables/`
in the upstream tree; §22.14 (mock-friendly subprocess wrapper) for the
contrasting "swap out an external" idiom that does not require
loadables; BCS1002 (PATH security) for the discussion of why builtin
dispatch is preferable on the security axis as well as the performance
axis.

#fin
