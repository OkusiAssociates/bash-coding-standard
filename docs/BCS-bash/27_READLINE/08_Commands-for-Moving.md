### Commands for Moving

beginning-of-line (C-a)
 Move to the start of the current line.

end-of-line (C-e)
 Move to the end of the line.

forward-char (C-f)
 Move forward one character.

backward-char (C-b)
 Move back one character.

forward-word (M-f)
 Move forward to the end of the next word. Words are composed of alphanumeric characters (letters and digits).

backward-word (M-b)
 Move back to the start of the current or previous word. Words are composed of alphanumeric characters (letters and digits).

shell-forward-word
 Move forward to the end of the next word. Words are delimited by non-quoted shell metacharacters.

shell-backward-word
 Move back to the start of the current or previous word. Words are delimited by non-quoted shell metacharacters.

previous-screen-line
 Move point to the same physical screen column on the previous physical screen line. No effect if the current readline line does not span more than one physical line or if point is not greater than the prompt length plus the screen width.

next-screen-line
 Move point to the same physical screen column on the next physical screen line. No effect if the current readline line does not span more than one physical line or if the line length is not greater than the prompt length plus the screen width.

clear-display (M-C-l)
 Clear the screen and, if possible, the terminal scrollback buffer, then redraw the current line at the top of the screen.

clear-screen (C-l)
 Clear the screen, then redraw the current line at the top of the screen. With an argument, refresh the current line without clearing the screen.

redraw-current-line
 Refresh the current line.
