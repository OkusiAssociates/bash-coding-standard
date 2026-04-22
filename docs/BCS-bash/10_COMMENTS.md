<!-- SPDX-License-Identifier: GPL-3.0-or-later -->
## COMMENTS

In a non-interactive shell, or an interactive shell in which the interactive_comments option to the shopt
builtin is enabled (see SHELL BUILTIN COMMANDS below), a word beginning with # causes that word and all
remaining characters on that line to be ignored. An interactive shell without the interactive_comments option
enabled does not allow comments. The interactive_comments option is on by default in interactive shells.

