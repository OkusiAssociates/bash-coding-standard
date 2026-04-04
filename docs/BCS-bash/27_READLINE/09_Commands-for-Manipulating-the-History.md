### Commands for Manipulating the History

accept-line (Newline, Return)
 Accept the line regardless of cursor position. If non-empty, add it to the history list according to the HISTCONTROL variable. If the line is a modified history line, restore it to its original state.

previous-history (C-p)
 Fetch the previous command from the history list, moving back in the list.

next-history (C-n)
 Fetch the next command from the history list, moving forward in the list.

beginning-of-history (M-<)
 Move to the first line in the history.

end-of-history (M->)
 Move to the end of the input history, that is, the line currently being entered.

operate-and-get-next (C-o)
 Accept the current line for execution and fetch the next line relative to the current line from the history for editing. A numeric argument specifies the history entry to use instead of the current line.

fetch-history
 With a numeric argument, fetch that entry from the history list and make it the current line. Without an argument, move back to the first entry in the history list.

reverse-search-history (C-r)
 Search backward starting at the current line and moving up through the history. Incremental search.

forward-search-history (C-s)
 Search forward starting at the current line and moving down through the history. Incremental search.

non-incremental-reverse-search-history (M-p)
 Search backward through the history starting at the current line using a non-incremental search for a user-supplied string.

non-incremental-forward-search-history (M-n)
 Search forward through the history using a non-incremental search for a user-supplied string.

history-search-forward
 Search forward through the history for the string of characters between the start of the current line and point. Non-incremental search.

history-search-backward
 Search backward through the history for the string of characters between the start of the current line and point. Non-incremental search.

history-substring-search-backward
 Search backward through the history for the string of characters between the start of the current line and point. The search string may match anywhere in a history line. Non-incremental search.

history-substring-search-forward
 Search forward through the history for the string of characters between the start of the current line and point. The search string may match anywhere in a history line. Non-incremental search.

yank-nth-arg (M-C-y)
 Insert the first argument to the previous command (usually the second word on the previous line) at point. With argument n, insert the nth word from the previous command (words begin with word 0). A negative argument inserts the nth word from the end of the previous command. Once n is computed, the argument is extracted as if the !n history expansion had been specified.

yank-last-arg (M-., M-_)
 Insert the last argument to the previous command (the last word of the previous history entry). With a numeric argument, behave exactly like yank-nth-arg. Successive calls move back through the history list, inserting the last word (or the word specified by the argument to the first call) of each line in turn. Any numeric argument supplied to successive calls determines the direction to move through the history. A negative argument switches direction (back or forward). The history expansion facilities extract the last word as if the !$ history expansion had been specified.

shell-expand-line (M-C-e)
 Expand the line as the shell does. Performs alias and history expansion as well as all shell word expansions.

history-expand-line (M-^)
 Perform history expansion on the current line.

magic-space
 Perform history expansion on the current line and insert a space.

alias-expand-line
 Perform alias expansion on the current line.

history-and-alias-expand-line
 Perform history and alias expansion on the current line.

insert-last-argument (M-., M-_)
 Synonym for yank-last-arg.

edit-and-execute-command (C-x C-e)
 Invoke an editor on the current command line and execute the result as shell commands. Bash attempts to invoke $VISUAL, $EDITOR, and emacs as the editor, in that order.
