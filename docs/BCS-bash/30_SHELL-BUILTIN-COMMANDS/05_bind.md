### bind
bind [-m keymap] [-lpsvPSVX]
bind [-m keymap] [-q function] [-u function] [-r keyseq]
bind [-m keymap] -f filename
bind [-m keymap] -x keyseq:shell-command
bind [-m keymap] keyseq:function-name
bind [-m keymap] keyseq:readline-command
bind readline-command-line

Display current readline key and function bindings, bind a key sequence to a readline function or macro, or set a readline variable. Each non-option argument is a command as it would appear in a readline initialization file such as .inputrc, but each binding or command must be passed as a separate argument; e.g., '"\C-x\C-r": re-read-init-file'.

-m keymap  Use keymap as the keymap to be affected by subsequent bindings. Acceptable names are emacs, emacs-standard, emacs-meta, emacs-ctlx, vi, vi-move, vi-command, and vi-insert. vi is equivalent to vi-command (vi-move is also a synonym); emacs is equivalent to emacs-standard.

-l  List the names of all readline functions.

-p  Display readline function names and bindings in a format that can be re-read.

-P  List current readline function names and bindings.

-s  Display readline key sequences bound to macros and the strings they output in a format that can be re-read.

-S  Display readline key sequences bound to macros and the strings they output.

-v  Display readline variable names and values in a format that can be re-read.

-V  List current readline variable names and values.

-f filename  Read key bindings from filename.

-q function  Query which keys invoke the named function.

-u function  Unbind all keys bound to the named function.

-r keyseq  Remove any current binding for keyseq.

-x keyseq:shell-command  Execute shell-command whenever keyseq is entered. When shell-command is executed, the shell sets READLINE_LINE to the contents of the readline line buffer and READLINE_POINT and READLINE_MARK to the current insertion point and saved insertion point (the mark), respectively. The shell assigns any numeric argument the user supplied to READLINE_ARGUMENT. If there was no argument, that variable is not set. If the executed command changes the value of READLINE_LINE, READLINE_POINT, or READLINE_MARK, the new values are reflected in the editing state.

-X  List all key sequences bound to shell commands and the associated commands in a format that can be reused as input.

The return value is 0 unless an unrecognized option is given or an error occurred.
