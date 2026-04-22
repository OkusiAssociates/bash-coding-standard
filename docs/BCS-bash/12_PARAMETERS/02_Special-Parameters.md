<!-- SPDX-License-Identifier: GPL-3.0-or-later -->
### Special Parameters

The shell treats several parameters specially. These parameters may only be referenced; assignment to them is not allowed.

`*`  Expands to the positional parameters, starting from one. When not within double quotes, each positional parameter expands to a separate word subject to further word splitting and pathname expansion. When within double quotes, expands to a single word with the value of each parameter separated by the first character of IFS. That is, "$*" is equivalent to "$1c$2c...", where c is the first character of IFS. If IFS is unset, the parameters are separated by spaces. If IFS is null, the parameters are joined without separators.

`@`  Expands to the positional parameters, starting from one. In contexts where word splitting is performed, each positional parameter expands to a separate word; if not within double quotes, these words are subject to word splitting. In contexts where word splitting is not performed, expands to a single word with each positional parameter separated by a space. When within double quotes, each parameter expands to a separate word. That is, "$@" is equivalent to "$1" "$2" .... If the double-quoted expansion occurs within a word, the expansion of the first parameter is joined with the beginning part of the original word, and the expansion of the last parameter is joined with the last part of the original word. When there are no positional parameters, "$@" and $@ expand to nothing (they are removed).

`#`  Expands to the number of positional parameters in decimal.

`?`  Expands to the exit status of the most recently executed foreground pipeline.

`-`  Expands to the current option flags as specified upon invocation, by the set builtin, or those set by the shell itself (such as the -i option).

`$`  Expands to the process ID of the shell. In a subshell, expands to the process ID of the current shell, not the subshell.

`!`  Expands to the process ID of the job most recently placed into the background, whether executed as an asynchronous command or using the bg builtin.

`0`  Expands to the name of the shell or shell script, set at shell initialization. If bash is invoked with a file of commands, $0 is set to the name of that file. If bash is started with the -c option, $0 is set to the first argument after the string to be executed, if one is present. Otherwise, it is set to the filename used to invoke bash, as given by argument zero.
