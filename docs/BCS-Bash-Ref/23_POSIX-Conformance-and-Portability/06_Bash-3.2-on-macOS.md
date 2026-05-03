<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 23.6 Bash 3.2 on macOS

Apple ships bash 3.2 (2007). Macs have used `zsh` as default since macOS Catalina.

- macOS `/bin/bash` is 3.2 — no associative arrays, no `mapfile`, no namerefs.
- Users install bash 5 via Homebrew: `/opt/homebrew/bin/bash` or `/usr/local/bin/bash`.
- Scripts that target Mac users need to choose: support 3.2, or require Homebrew bash.
- Most modern scripts require 4.0+ or 5.0+.

#fin
