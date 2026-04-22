<!-- SPDX-License-Identifier: GPL-3.0-or-later -->
### Commands for Changing Text

end-of-file (usually C-d)
 The character indicating end-of-file as set by stty. If read when there are no characters on the line and point is at the beginning of the line, readline interprets it as end of input and returns EOF.

delete-char (C-d)
 Delete the character at point. If bound to the same character as the tty EOF character (as C-d commonly is), see end-of-file for the effects.

backward-delete-char (Rubout)
 Delete the character behind the cursor. When given a numeric argument, save the deleted text on the kill ring.

forward-backward-delete-char
 Delete the character under the cursor, unless the cursor is at the end of the line, in which case delete the character behind the cursor.

quoted-insert (C-q, C-v)
 Add the next character typed to the line verbatim. This is how to insert characters like C-q.

tab-insert (C-v TAB)
 Insert a tab character.

self-insert (a, b, A, 1, !, ...)
 Insert the character typed.

transpose-chars (C-t)
 Drag the character before point forward over the character at point, moving point forward as well. If point is at the end of the line, transpose the two characters before point. Negative arguments have no effect.

transpose-words (M-t)
 Drag the word before point past the word after point, moving point over that word as well. If point is at the end of the line, transpose the last two words on the line.

upcase-word (M-u)
 Uppercase the current or following word. With a negative argument, uppercase the previous word without moving point.

downcase-word (M-l)
 Lowercase the current or following word. With a negative argument, lowercase the previous word without moving point.

capitalize-word (M-c)
 Capitalize the current or following word. With a negative argument, capitalize the previous word without moving point.

overwrite-mode
 Toggle overwrite mode. With an explicit positive numeric argument, switch to overwrite mode. With an explicit non-positive numeric argument, switch to insert mode. Affects only emacs mode; vi mode handles overwrite differently. Each call to readline() starts in insert mode. In overwrite mode, characters bound to self-insert replace the text at point rather than pushing text to the right. Characters bound to backward-delete-char replace the character before point with a space. Unbound by default.
