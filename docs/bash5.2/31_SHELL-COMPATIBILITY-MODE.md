## SHELL COMPATIBILITY MODE

Bash-4.0 introduced the concept of a shell compatibility level, specified as a set of options to the shopt
builtin ( compat31, compat32, compat40, compat41, and so on).  There is only one current compatibility level
-- each option is mutually exclusive.  The compatibility level is intended to allow users to select behavior
from previous versions that is incompatible with newer versions while they migrate scripts to use current
features and behavior. It's intended to be a temporary solution.

This section does not mention behavior that is standard for a particular version (e.g., setting compat32 means
that quoting the rhs of the regexp matching operator quotes special regexp characters in the word, which is
default behavior in bash-3.2 and subsequent versions).

If a user enables, say, compat32, it may affect the behavior of other compatibility levels up to and including
the current compatibility level. The idea is that each compatibility level controls behavior that changed in
that version of bash, but that behavior may have been present in earlier versions.  For instance, the change
to use locale-based comparisons with the [[ command came in bash-4.1, and earlier versions used ASCII-based
comparisons, so enabling compat32 will enable ASCII-based comparisons as well.  That granularity may not be
sufficient for all uses, and as a result users should employ compatibility levels carefully.  Read the
documentation for a particular feature to find out the current behavior.

Bash-4.3 introduced a new shell variable: BASH_COMPAT.  The value assigned to this variable (a decimal version
number like 4.2, or an integer corresponding to the compatNN option, like 42) determines the compatibility
level.

Starting with bash-4.4, Bash has begun deprecating older compatibility levels.  Eventually, the options will
be removed in favor of BASH_COMPAT.

Bash-5.0 is the final version for which there will be an individual shopt option for the previous version.
Users should use BASH_COMPAT on bash-5.0 and later versions.

The following table describes the behavior changes controlled by each compatibility level setting.  The
compatNN tag is used as shorthand for setting the compatibility level to NN using one of the following
mechanisms.  For versions prior to bash-5.0, the compatibility level may be set using the corresponding
compatNN shopt option.  For bash-4.3 and later versions, the BASH_COMPAT variable is preferred, and it is
required for bash-5.1 and later versions.

compat31
 • quoting the rhs of the [[ command's regexp matching operator (=~) has no special effect

compat32
 • interrupting a command list such as "a ; b ; c" causes the execution of the next command in the
  list (in bash-4.0 and later versions, the shell acts as if it received the interrupt, so
  interrupting one command in a list aborts the execution of the entire list)

compat40
 • the < and > operators to the [[ command do not consider the current locale when comparing
  strings; they use ASCII ordering.  Bash versions prior to bash-4.1 use ASCII collation and
  strcmp(3); bash-4.1 and later use the current locale's collation sequence and strcoll(3).

compat41
 • in posix mode, time may be followed by options and still be recognized as a reserved word (this
  is POSIX interpretation 267)
 • in posix mode, the parser requires that an even number of single quotes occur in the word
  portion of a double-quoted parameter expansion and treats them specially, so that characters
  within the single quotes are considered quoted (this is POSIX interpretation 221)

compat42
 • the replacement string in double-quoted pattern substitution does not undergo quote removal, as
  it does in versions after bash-4.2
 • in posix mode, single quotes are considered special when expanding the word portion of a double-
  quoted parameter expansion and can be used to quote a closing brace or other special character
  (this is part of POSIX interpretation 221); in later versions, single quotes are not special
  within double-quoted word expansions

compat43
 • the shell does not print a warning message if an attempt is made to use a quoted compound
  assignment as an argument to declare (e.g., declare -a foo='(1 2)'). Later versions warn that
  this usage is deprecated
 • word expansion errors are considered non-fatal errors that cause the current command to fail,
  even in posix mode (the default behavior is to make them fatal errors that cause the shell to
  exit)
 • when executing a shell function, the loop state (while/until/etc.) is not reset, so break or
  continue in that function will break or continue loops in the calling context. Bash-4.4 and
  later reset the loop state to prevent this

compat44
 • the shell sets up the values used by BASH_ARGV and BASH_ARGC so they can expand to the shell's
  positional parameters even if extended debugging mode is not enabled
 • a subshell inherits loops from its parent context, so break or continue will cause the subshell
  to exit.  Bash-5.0 and later reset the loop state to prevent the exit
 • variable assignments preceding builtins like export and readonly that set attributes continue to
  affect variables with the same name in the calling environment even if the shell is not in posix
  mode

compat50
 • Bash-5.1 changed the way $RANDOM is generated to introduce slightly more randomness. If the
  shell compatibility level is set to 50 or lower, it reverts to the method from bash-5.0 and
  previous versions, so seeding the random number generator by assigning a value to RANDOM will
  produce the same sequence as in bash-5.0
 • If the command hash table is empty, bash versions prior to bash-5.1 printed an informational
  message to that effect, even when producing output that can be reused as input. Bash-5.1
  suppresses that message when the -l option is supplied.

compat51
 • The unset builtin treats attempts to unset array subscripts @ and * differently depending on
  whether the array is indexed or associative, and differently than in previous versions.

