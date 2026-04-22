<!-- SPDX-License-Identifier: GPL-3.0-or-later -->
### set

set [-abefhkmnptuvxBCEHPT] [-o option-name] [--] [-] [arg ...]
set [+abefhkmnptuvxBCEHPT] [+o option-name] [--] [-] [arg ...]

Without options, display the name and value of each shell variable in a format that can be reused as input for setting or resetting the currently-set variables. Read-only variables cannot be reset. The output is sorted according to the current locale.

When options are specified, they set or unset shell attributes. Any arguments remaining after option processing are treated as values for the positional parameters and are assigned, in order, to $1, $2, ... $n.

-a  Mark each variable or function that is created or modified for export to the environment of subsequent commands.

-b  Report the status of terminated background jobs immediately, rather than before the next primary prompt. Effective only when job control is enabled.

-e  Exit immediately if a pipeline (which may consist of a single simple command), a list, or a compound command (see SHELL GRAMMAR) exits with a non-zero status. The shell does not exit if the command that fails is part of the command list immediately following a while or until keyword, part of the test following the if or elif reserved words, part of any command executed in a && or || list except the command following the final && or ||, any command in a pipeline but the last, or if the command's return value is being inverted with !. If a compound command other than a subshell returns a non-zero status because a command failed while -e was being ignored, the shell does not exit. A trap on ERR, if set, is executed before the shell exits. This option applies to the shell environment and each subshell environment separately (see COMMAND EXECUTION ENVIRONMENT), and may cause subshells to exit before executing all the commands in the subshell.

If a compound command or shell function executes in a context where -e is being ignored, none of the commands executed within the compound command or function body are affected by the -e setting, even if -e is set and a command returns a failure status. If a compound command or shell function sets -e while executing in a context where -e is ignored, that setting has no effect until the compound command or the command containing the function call completes.

Assumed always enabled under strict mode (set -euo pipefail).

-f  Disable pathname expansion.

-h  Remember the location of commands as they are looked up for execution. Enabled by default.

-k  Place all arguments in the form of assignment statements in the environment for a command, not just those that precede the command name.

-m  Monitor mode. Job control is enabled. On by default for interactive shells on systems that support it (see JOB CONTROL). All processes run in a separate process group. When a background job completes, the shell prints a line containing its exit status.

-n  Read commands but do not execute them; useful for checking a shell script for syntax errors. Ignored by interactive shells.

-o option-name
The option-name can be one of the following:

allexport  Same as -a.

braceexpand  Same as -B.

emacs  Use an emacs-style command line editing interface. Enabled by default when the shell is interactive, unless started with --noediting. Also affects the editing interface used for read -e.

errexit  Same as -e.

errtrace  Same as -E.

functrace  Same as -T.

hashall  Same as -h.

histexpand  Same as -H.

history  Enable command history (see HISTORY). On by default in interactive shells.

ignoreeof  Equivalent to executing IGNOREEOF=10 (see Shell Variables).

keyword  Same as -k.

monitor  Same as -m.

noclobber  Same as -C.

noexec  Same as -n.

noglob  Same as -f.

nolog  Currently ignored.

notify  Same as -b.

nounset  Same as -u.

onecmd  Same as -t.

physical  Same as -P.

pipefail  If set, the return value of a pipeline is the value of the last (rightmost) command to exit with a non-zero status, or zero if all commands exit successfully. Disabled by default. Assumed always enabled under strict mode (set -euo pipefail).

privileged  Same as -p.

verbose  Same as -v.

vi  Use a vi-style command line editing interface. Also affects the editing interface used for read -e.

xtrace  Same as -x.

If -o is supplied with no option-name, the values of the current options are printed. If +o is supplied with no option-name, a series of set commands to recreate the current option settings is displayed on standard output.

-p  Turn on privileged mode. In this mode, the $ENV and $BASH_ENV files are not processed, shell functions are not inherited from the environment, and the SHELLOPTS, BASHOPTS, CDPATH, and GLOBIGNORE variables, if they appear in the environment, are ignored. If the shell is started with the effective user (group) id not equal to the real user (group) id and -p is not supplied, these actions are taken and the effective user id is set to the real user id. If -p is supplied at startup, the effective user id is not reset. Turning this option off causes the effective user and group ids to be set to the real user and group ids.

-r  Enable restricted shell mode. Cannot be unset once set.

-t  Exit after reading and executing one command.

-u  Treat unset variables and parameters other than the special parameters @ and *, or array variables subscripted with @ or *, as an error when performing parameter expansion. If expansion is attempted on an unset variable or parameter, the shell prints an error message and, if not interactive, exits with a non-zero status. Assumed always enabled under strict mode (set -euo pipefail).

-v  Print shell input lines as they are read.

-x  After expanding each simple command, for command, case command, select command, or arithmetic for command, display the expanded value of PS4 followed by the command and its expanded arguments or associated word list.

-B  The shell performs brace expansion (see Brace Expansion). On by default.

-C  Prevent bash from overwriting an existing file with the >, >&, and <> redirection operators. This may be overridden by using >| instead of >.

-E  If set, any trap on ERR is inherited by shell functions, command substitutions, and commands executed in a subshell environment. The ERR trap is normally not inherited in such cases.

-H  Enable ! style history substitution. On by default when the shell is interactive.

-P  If set, the shell does not resolve symbolic links when executing commands such as cd that change the current working directory, using the physical directory structure instead. By default, bash follows the logical chain of directories when performing commands that change the current directory.

-T  If set, any traps on DEBUG and RETURN are inherited by shell functions, command substitutions, and commands executed in a subshell environment. The DEBUG and RETURN traps are normally not inherited in such cases.

--  If no arguments follow, the positional parameters are unset. Otherwise, the positional parameters are set to the args, even if some begin with -.

`-`  Signal the end of options, causing all remaining args to be assigned to the positional parameters. The -x and -v options are turned off. If there are no args, the positional parameters remain unchanged.

Options are off by default unless otherwise noted. Using + rather than - causes these options to be turned off. The options can also be specified as arguments to an invocation of the shell. The current set of options may be found in $-. The return status is always true unless an invalid option is encountered.
