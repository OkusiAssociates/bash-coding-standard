<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 10.11 Distribution and installation

How bash libraries are packaged and deployed. The unifying principle
is FHS compliance (BCS0104): libraries land in predictable
directories that scripts and the dynamic loader can find without
configuration.

- FHS layout: libraries in `/usr/share/PROJECT/lib/` (system-managed)
  or `/usr/local/share/PROJECT/lib/` (admin-managed).
- Per-user: `~/.local/share/PROJECT/lib/`.
- Discovery: scripts use FHS search-path resolution (BCS pattern,
  see BCS0104 for the canonical search order).
- Versioning: a `MYLIB_VERSION` constant inside the library *plus*
  a separate `VERSION` file at the install root, so package managers
  can read the version without sourcing the library.
- Packaging: deb, rpm, tarball, git submodule, or copy-into-tree;
  pick one and document it.
- Symlinks via `symlink -S` for PATH-exposed scripts.
- Pre-source vs source-on-demand trade-offs: pre-source for shared
  libraries used by many scripts (load cost amortised); source-on-
  demand for big optional features (load cost paid only when used).

### Makefile install-target example

A standard `make install` target encodes the FHS layout and the
correct file modes. The `PREFIX`/`DESTDIR` variables are package-
manager conventions: `DESTDIR` is set by deb/rpm builders to redirect
the install into a staging tree; `PREFIX` lets users override
`/usr/local`.

```makefile
# scenario: BCS-compliant Makefile install target for a bash library project.
# ── Makefile ─────────────────────────────────────────────────
PREFIX  ?= /usr/local
DESTDIR ?=

LIBDIR  := $(DESTDIR)$(PREFIX)/share/myapp/lib
BINDIR  := $(DESTDIR)$(PREFIX)/bin
DOCDIR  := $(DESTDIR)$(PREFIX)/share/doc/myapp
ETCDIR  := $(DESTDIR)/etc/myapp

LIBS    := lib/path_utils.sh lib/strings.sh lib/db.sh
SCRIPTS := bin/myapp
DOCS    := README.md LICENSE
VERSION := $(shell cat VERSION)

.PHONY: all install uninstall check

all:
	@printf 'myapp %s — run "make install" (PREFIX=%s)\n' '$(VERSION)' '$(PREFIX)'

install:
	install -d -m 0755 '$(LIBDIR)' '$(BINDIR)' '$(DOCDIR)' '$(ETCDIR)'
	install -m 0644 $(LIBS)    '$(LIBDIR)/'
	install -m 0755 $(SCRIPTS) '$(BINDIR)/'
	install -m 0644 $(DOCS)    '$(DOCDIR)/'
	install -m 0644 VERSION    '$(DOCDIR)/VERSION'           # (BCS0104)

uninstall:
	rm -rf '$(LIBDIR)' '$(DOCDIR)' '$(ETCDIR)'
	for s in $(notdir $(SCRIPTS)); do rm -f "$(BINDIR)/$$s"; done

check:
	shellcheck -x $(SCRIPTS) $(LIBS)
	bcscheck     $(SCRIPTS) $(LIBS)                          # (BCS1212)

#fin
```

A few notes on the conventions. `install -d` creates the directory
tree with the right modes in one step. Library files install with
`0644` (read-only for callers); scripts with `0755` (executable).
The `VERSION` file is duplicated at `$(DOCDIR)/VERSION` so package
managers and `dpkg-query`/`rpm -qV` can read it without sourcing
anything. `DESTDIR` is *prepended*, not embedded into `PREFIX` —
this is the deb/rpm convention; reversing them breaks staging
builds. The `check` target runs both static and BCS-policy
linting, so `make check` is the canonical pre-release gate.

For larger projects, a tiered Makefile (BCS bash-300 insight)
breaks `install` into per-component sub-targets — useful when a
project ships both a library and a daemon, or when a hardware-
specific component needs its own copy step. For most libraries the
flat target above is sufficient.

**See also**: §10.10 API design, §10.7 version negotiation (the
`VERSION` constant and the `VERSION` file), §10.6 public vs private
conventions (header documentation that pairs with the README in
`$(DOCDIR)`), BCS0104 (FHS compliance), BCS1212 (Makefile
installation), BCS0103 (script metadata).

#fin
