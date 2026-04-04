### shopt

shopt [-pqsu] [-o] [optname ...]

Toggle settings controlling optional shell behavior. The settings are those listed here, or, with -o, those available via set -o. With no options or with -p, all settable options are displayed with their current state; if optnames are supplied, output is restricted to those options. The -p option formats output as reusable input.

-s  Enable (set) each optname.

-u  Disable (unset) each optname.

-q  Suppress normal output (quiet mode); the return status indicates whether the optname is set or unset. With multiple optnames, the return status is zero only if all are enabled.

-o  Restrict optname values to those defined for set -o.

If -s or -u is used with no optname arguments, shopt shows only those options which are set or unset, respectively. Unless otherwise noted, shopt options are disabled (unset) by default.

The return status when listing options is zero if all optnames are enabled, non-zero otherwise. When setting or unsetting options, the return status is zero unless an optname is not a valid shell option.

The list of shopt options:

assoc_expand_once
 Suppress multiple evaluation of associative array subscripts during arithmetic expression evaluation, while executing builtins that can perform variable assignments, and while executing builtins that perform array dereferencing.

autocd
 A command name that is the name of a directory is executed as if it were the argument to cd. Interactive shells only.

cdable_vars
 An argument to cd that is not a directory is assumed to be the name of a variable whose value is the directory to change to.

cdspell
 Minor errors in the spelling of a directory component in a cd command are corrected. The errors checked for are transposed characters, a missing character, and one character too many. If a correction is found, the corrected filename is printed and the command proceeds. Interactive shells only.

checkhash
 Bash checks that a command found in the hash table exists before trying to execute it. If a hashed command no longer exists, a normal path search is performed.

checkjobs
 Bash lists the status of any stopped and running jobs before exiting an interactive shell. If any jobs are running, the exit is deferred until a second exit is attempted without an intervening command (see JOB CONTROL). The shell always postpones exiting if any jobs are stopped.

checkwinsize
 Bash checks the window size after each external (non-builtin) command and, if necessary, updates the values of LINES and COLUMNS. Enabled by default.

cmdhist
 Bash attempts to save all lines of a multiple-line command in the same history entry, allowing easy re-editing of multi-line commands. Enabled by default, but only has an effect if command history is enabled (see HISTORY).

complete_fullquote
 Bash quotes all shell metacharacters in filenames and directory names when performing completion. If not set, bash removes metacharacters such as the dollar sign from the set of characters that will be quoted in completed filenames when these metacharacters appear in shell variable references in words to be completed. This means that dollar signs in variable names that expand to directories will not be quoted; however, any dollar signs appearing in filenames will not be quoted either. Active only when bash is using backslashes to quote completed filenames. Enabled by default.

direxpand
 Bash replaces directory names with the results of word expansion when performing filename completion, changing the contents of the readline editing buffer. If not set, bash attempts to preserve what the user typed.

dirspell
 Bash attempts spelling correction on directory names during word completion if the directory name initially supplied does not exist.

dotglob
 Include filenames beginning with a . in the results of pathname expansion. The filenames . and .. must always be matched explicitly, even if dotglob is set.

execfail
 A non-interactive shell will not exit if it cannot execute the file specified as an argument to exec. An interactive shell does not exit if exec fails.

expand_aliases
 Aliases are expanded as described in ALIASES. Enabled by default for interactive shells.

extdebug
 If set at shell invocation or in a shell startup file, the debugger profile is executed before the shell starts, identical to the --debugger option.

 If set after invocation, behavior intended for use by debuggers is enabled: 1) The -F option to declare displays the source file name and line number corresponding to each function name supplied as an argument. 2) If the command run by the DEBUG trap returns a non-zero value, the next command is skipped. 3) If the command run by the DEBUG trap returns a value of 2 and the shell is executing in a subroutine (a shell function or a script executed by . or source), the shell simulates a call to return. 4) BASH_ARGC and BASH_ARGV are updated as described in their variable definitions. 5) Function tracing is enabled: command substitution, shell functions, and subshells invoked with ( command ) inherit the DEBUG and RETURN traps. 6) Error tracing is enabled: command substitution, shell functions, and subshells invoked with ( command ) inherit the ERR trap.

extglob
 Enable the extended pattern matching features described in Pathname Expansion.

extquote
 $'string' and $"string" quoting is performed within ${parameter} expansions enclosed in double quotes. Enabled by default.

failglob
 Patterns which fail to match filenames during pathname expansion result in an expansion error.

force_fignore
 The suffixes specified by the FIGNORE shell variable cause words to be ignored when performing word completion even if the ignored words are the only possible completions. See FIGNORE in Shell Variables. Enabled by default.

globasciiranges
 Range expressions used in pattern matching bracket expressions (see Pattern Matching) behave as if in the traditional C locale when performing comparisons. The current locale's collating sequence is not taken into account, so b will not collate between A and B, and upper-case and lower-case ASCII characters will collate together.

globskipdots
 Pathname expansion will never match the filenames . and .., even if the pattern begins with a dot. Enabled by default.

globstar
 The pattern ** used in a pathname expansion context matches all files and zero or more directories and subdirectories. If the pattern is followed by a /, only directories and subdirectories match.

gnu_errfmt
 Shell error messages are written in the standard GNU error message format.

histappend
 The history list is appended to the file named by HISTFILE when the shell exits, rather than overwriting the file.

histreedit
 If readline is being used, a user is given the opportunity to re-edit a failed history substitution.

histverify
 If readline is being used, the results of history substitution are not immediately passed to the shell parser. Instead, the resulting line is loaded into the readline editing buffer, allowing further modification.

hostcomplete
 If readline is being used, bash attempts to perform hostname completion when a word containing a @ is being completed (see Completing in READLINE). Enabled by default.

huponexit
 Bash sends SIGHUP to all jobs when an interactive login shell exits.

inherit_errexit
 Command substitution inherits the value of the errexit option, instead of unsetting it in the subshell environment. Under strict-mode bash, this option should always be enabled.

interactive_comments
 Allow a word beginning with # to cause that word and all remaining characters on that line to be ignored in an interactive shell (see COMMENTS). Enabled by default.

lastpipe
 If job control is not active, the shell runs the last command of a pipeline not executed in the background in the current shell environment.

lithist
 If the cmdhist option is enabled, multi-line commands are saved to the history with embedded newlines rather than using semicolon separators where possible.

localvar_inherit
 Local variables inherit the value and attributes of a variable of the same name that exists at a previous scope before any new value is assigned. The nameref attribute is not inherited.

localvar_unset
 Calling unset on local variables in previous function scopes marks them so subsequent lookups find them unset until that function returns. This is identical to the behavior of unsetting local variables at the current function scope.

login_shell
 The shell sets this option if it is started as a login shell (see INVOCATION). The value may not be changed.

mailwarn
 If a file that bash is checking for mail has been accessed since the last time it was checked, the message "The mail in mailfile has been read" is displayed.

no_empty_cmd_completion
 If readline is being used, bash will not attempt to search PATH for possible completions when completion is attempted on an empty line.

nocaseglob
 Bash matches filenames in a case-insensitive fashion when performing pathname expansion (see Pathname Expansion).

nocasematch
 Bash matches patterns in a case-insensitive fashion when performing matching while executing case or [[ conditional commands, when performing pattern substitution word expansions, or when filtering possible completions as part of programmable completion.

noexpand_translation
 Bash encloses the translated results of $"..." quoting in single quotes instead of double quotes. If the string is not translated, this has no effect.

nullglob
 Patterns which match no files (see Pathname Expansion) expand to a null string, rather than themselves.

patsub_replacement
 Bash expands occurrences of & in the replacement string of pattern substitution to the text matched by the pattern, as described in Parameter Expansion. Enabled by default.

progcomp
 The programmable completion facilities (see Programmable Completion) are enabled. Enabled by default.

progcomp_alias
 If programmable completion is enabled, bash treats a command name that has no completions as a possible alias and attempts alias expansion. If it has an alias, bash attempts programmable completion using the command word resulting from the expanded alias.

promptvars
 Prompt strings undergo parameter expansion, command substitution, arithmetic expansion, and quote removal after being expanded as described in PROMPTING. Enabled by default.

restricted_shell
 The shell sets this option if it is started in restricted mode (see RESTRICTED SHELL). The value may not be changed. This is not reset when the startup files are executed, allowing the startup files to discover whether or not a shell is restricted.

shift_verbose
 The shift builtin prints an error message when the shift count exceeds the number of positional parameters.

sourcepath
 The . (source) builtin uses the value of PATH to find the directory containing the file supplied as an argument. Enabled by default.

varredir_close
 The shell automatically closes file descriptors assigned using the {varname} redirection syntax (see REDIRECTION) instead of leaving them open when the command completes.

xpg_echo
 The echo builtin expands backslash-escape sequences by default.
