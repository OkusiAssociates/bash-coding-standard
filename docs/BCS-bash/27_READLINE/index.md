<!-- SPDX-License-Identifier: GPL-3.0-or-later -->
## READLINE

This is the library that handles reading input when using an interactive shell, unless the --noediting option
is given at shell invocation.  Line editing is also used when using the -e option to the read builtin.  By
default, the line editing commands are similar to those of Emacs.  A vi-style line editing interface is also
available.  Line editing can be enabled at any time using the -o emacs or -o vi options to the set builtin
(see SHELL BUILTIN COMMANDS below).  To turn off line editing after the shell is running, use the +o emacs or
+o vi options to the set builtin.

---
- [Readline Notation](01_Readline-Notation.md)
- [Readline Initialization](02_Readline-Initialization.md)
- [Readline Key Bindings](03_Readline-Key-Bindings.md)
- [Readline Variables](04_Readline-Variables.md)
- [Readline Conditional Constructs](05_Readline-Conditional-Constructs.md)
- [Searching](06_Searching.md)
- [Readline Command Names](07_Readline-Command-Names.md)
- [Commands for Moving](08_Commands-for-Moving.md)
- [Commands for Manipulating the History](09_Commands-for-Manipulating-the-History.md)
- [Commands for Changing Text](10_Commands-for-Changing-Text.md)
- [Killing and Yanking](11_Killing-and-Yanking.md)
- [Numeric Arguments](12_Numeric-Arguments.md)
- [Completing](13_Completing.md)
- [Keyboard Macros](14_Keyboard-Macros.md)
- [Miscellaneous](15_Miscellaneous.md)
- [Programmable Completion](16_Programmable-Completion.md)
