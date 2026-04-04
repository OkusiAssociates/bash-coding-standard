## HISTORY

When the -o history option to the set builtin is enabled, the shell provides access to the command history,
the list of commands previously typed.  The value of the HISTSIZE variable is used as the number of commands
to save in a history list.  The text of the last HISTSIZE commands (default 500) is saved.  The shell stores
each command in the history list prior to parameter and variable expansion (see EXPANSION above) but after
history expansion is performed, subject to the values of the shell variables HISTIGNORE and HISTCONTROL.

On startup, the history is initialized from the file named by the variable HISTFILE (default ~/.bash_history).
The file named by the value of HISTFILE is truncated, if necessary, to contain no more than the number of
lines specified by the value of HISTFILESIZE.  If HISTFILESIZE is unset, or set to null, a non-numeric value,
or a numeric value less than zero, the history file is not truncated.  When the history file is read, lines
beginning with the history comment character followed immediately by a digit are interpreted as timestamps for
the following history line.  These timestamps are optionally displayed depending on the value of the
HISTTIMEFORMAT variable. When a shell with history enabled exits, the last $HISTSIZE lines are copied from
the history list to $HISTFILE.  If the histappend shell option is enabled (see the description of shopt under
SHELL BUILTIN COMMANDS below), the lines are appended to the history file, otherwise the history file is
overwritten.  If HISTFILE is unset, or if the history file is unwritable, the history is not saved.  If the
HISTTIMEFORMAT variable is set, time stamps are written to the history file, marked with the history comment
character, so they may be preserved across shell sessions.  This uses the history comment character to
distinguish timestamps from other history lines. After saving the history, the history file is truncated to
contain no more than HISTFILESIZE lines. If HISTFILESIZE is unset, or set to null, a non-numeric value, or a
numeric value less than zero, the history file is not truncated.

The builtin command fc (see SHELL BUILTIN COMMANDS below) may be used to list or edit and re-execute a portion
of the history list.  The history builtin may be used to display or modify the history list and manipulate the
history file.  When using command-line editing, search commands are available in each editing mode that
provide access to the history list.

The shell allows control over which commands are saved on the history list.  The HISTCONTROL and HISTIGNORE
variables may be set to cause the shell to save only a subset of the commands entered.  The cmdhist shell
option, if enabled, causes the shell to attempt to save each line of a multi-line command in the same history
entry, adding semicolons where necessary to preserve syntactic correctness.  The lithist shell option causes
the shell to save the command with embedded newlines instead of semicolons.  See the description of the shopt
builtin below under SHELL BUILTIN COMMANDS for information on setting and unsetting shell options.

