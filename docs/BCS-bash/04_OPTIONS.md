## OPTIONS

All single-character shell options documented in the description of the set builtin, including -o, can be used as options when the shell is invoked. In addition, bash interprets the following options at invocation:

-c Commands are read from the first non-option argument command_string. If there are arguments after the command_string, the first is assigned to $0 and the rest become positional parameters. The assignment to $0 sets the name of the shell, used in warning and error messages.

-i The shell is interactive.

-l Make bash act as if invoked as a login shell (see INVOCATION).

-r The shell becomes restricted (see RESTRICTED SHELL).

-s If present, or if no arguments remain after option processing, commands are read from standard input. This allows positional parameters to be set when invoking an interactive shell or reading input through a pipe.

-v Print shell input lines as they are read.

-x Print commands and their arguments as they are executed.

-D A list of all double-quoted strings preceded by $ is printed on standard output. These are strings subject to language translation when the current locale is not C or POSIX. Implies -n; no commands are executed.

[-+]O [shopt_option]
 shopt_option is one of the shell options accepted by the shopt builtin. If shopt_option is present, -O sets the value of that option; +O unsets it. If shopt_option is not supplied, the names and values of shell options accepted by shopt are printed on standard output. If the invocation option is +O, the output is displayed in a format that may be reused as input.

-- Signals the end of options and disables further option processing. Any arguments after -- are treated as filenames and arguments. An argument of - is equivalent to --.

Bash also interprets a number of multi-character options. These must appear on the command line before the single-character options to be recognized.

--debugger
 Arrange for the debugger profile to be executed before the shell starts. Turns on extended debugging mode (see the extdebug option to shopt).

--dump-po-strings
 Equivalent to -D, but the output is in GNU gettext po (portable object) file format.

--dump-strings
 Equivalent to -D.

--help
 Display a usage message on standard output and exit successfully.

--init-file file
--rcfile file
 Execute commands from file instead of the system-wide initialization file /etc/bash.bashrc and the standard personal initialization file ~/.bashrc if the shell is interactive (see INVOCATION).

--login
 Equivalent to -l.

--noediting
 Do not use the GNU readline library to read command lines when the shell is interactive.

--noprofile
 Do not read the system-wide startup file /etc/profile or any of the personal initialization files ~/.bash_profile, ~/.bash_login, or ~/.profile. By default, bash reads these files when invoked as a login shell (see INVOCATION).

--norc
 Do not read and execute the system-wide initialization file /etc/bash.bashrc and the personal initialization file ~/.bashrc if the shell is interactive.

--restricted
 The shell becomes restricted (see RESTRICTED SHELL).

--verbose
 Equivalent to -v.

--version
 Show version information for this instance of bash on standard output and exit successfully.

