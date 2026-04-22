<!-- SPDX-License-Identifier: GPL-3.0-or-later -->
## HISTORY EXPANSION

The shell supports a history expansion feature that is similar to the history expansion in csh.  This section
describes what syntax features are available.  This feature is enabled by default for interactive shells, and
can be disabled using the +H option to the set builtin command (see SHELL BUILTIN COMMANDS below).  Non-
interactive shells do not perform history expansion by default.

History expansions introduce words from the history list into the input stream, making it easy to repeat
commands, insert the arguments to a previous command into the current input line, or fix errors in previous
commands quickly.

History expansion is performed immediately after a complete line is read, before the shell breaks it into
words, and is performed on each line individually without taking quoting on previous lines into account. It
takes place in two parts.  The first is to determine which line from the history list to use during
substitution.  The second is to select portions of that line for inclusion into the current one. The line
selected from the history is the event, and the portions of that line that are acted upon are words.  Various
modifiers are available to manipulate the selected words.  The line is broken into words in the same fashion
as when reading input, so that several metacharacter-separated words surrounded by quotes are considered one
word.  History expansions are introduced by the appearance of the history expansion character, which is ! by
default. Only backslash (\) and single quotes can quote the history expansion character, but the history
expansion character is also treated as quoted if it immediately precedes the closing double quote in a double-
quoted string.

Several characters inhibit history expansion if found immediately following the history expansion character,
even if it is unquoted: space, tab, newline, carriage return, and =.  If the extglob shell option is enabled,
( will also inhibit expansion.

Several shell options settable with the shopt builtin may be used to tailor the behavior of history expansion.
If the histverify shell option is enabled (see the description of the shopt builtin below), and readline is
being used, history substitutions are not immediately passed to the shell parser.  Instead, the expanded line
is reloaded into the readline editing buffer for further modification.  If readline is being used, and the
histreedit shell option is enabled, a failed history substitution will be reloaded into the readline editing
buffer for correction.  The -p option to the history builtin command may be used to see what a history
expansion will do before using it.  The -s option to the history builtin may be used to add commands to the
end of the history list without actually executing them, so that they are available for subsequent recall.

The shell allows control of the various characters used by the history expansion mechanism (see the
description of histchars above under Shell Variables).  The shell uses the history comment character to mark
history timestamps when writing the history file.

---
- [Event Designators](01_Event-Designators.md)
- [Word Designators](02_Word-Designators.md)
- [Modifiers](03_Modifiers.md)
