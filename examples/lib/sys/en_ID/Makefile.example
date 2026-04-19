# Makefile - Install en_ID locale
# BCS1212 compliant

PREFIX    ?= /usr
LOCALEDIR ?= $(PREFIX)/share/i18n/locales
CHARMAP   ?= UTF-8
DESTDIR   ?=

.PHONY: all install uninstall check test compile clean help

all: help

install:
	install -d $(DESTDIR)$(LOCALEDIR)
	install -m 644 localedata/en_ID $(DESTDIR)$(LOCALEDIR)/en_ID
	@if [ -z "$(DESTDIR)" ]; then \
	  localedef --charmap=$(CHARMAP) --inputfile=$(LOCALEDIR)/en_ID en_ID.$(CHARMAP); \
	  $(MAKE) --no-print-directory check; \
	fi

uninstall:
	rm -f $(DESTDIR)$(LOCALEDIR)/en_ID
	@if [ -z "$(DESTDIR)" ]; then \
	  localedef --delete-from-archive en_ID.$(CHARMAP) 2>/dev/null || true; \
	fi

check:
	@locale -a 2>/dev/null | grep -q en_ID \
	  && echo 'en_ID: OK' \
	  || echo 'en_ID: NOT FOUND (run locale -a to verify)'

test:
	./tests/test_en_ID.sh

compile:
	mkdir -p build
	localedef -f $(CHARMAP) -i localedata/en_ID ./build/en_ID.$(CHARMAP)

clean:
	rm -rf build

help:
	@echo 'Usage: make [target]'
	@echo ''
	@echo 'Targets:'
	@echo '  install     Install locale system-wide'
	@echo '  uninstall   Remove locale from system'
	@echo '  check       Verify locale is available'
	@echo '  test        Run test suite'
	@echo '  compile     Compile locale to build directory'
	@echo '  clean       Remove build artifacts'
	@echo '  help        Show this message'
	@echo ''
	@echo 'Install from GitHub:'
	@echo '  git clone https://github.com/Open-Technology-Foundation/en_ID.git'
	@echo '  cd en_ID && sudo make install'
