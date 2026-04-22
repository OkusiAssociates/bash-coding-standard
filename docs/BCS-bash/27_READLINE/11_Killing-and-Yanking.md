<!-- SPDX-License-Identifier: GPL-3.0-or-later -->
### Killing and Yanking

kill-line (C-k)
 Kill the text from point to the end of the line.

backward-kill-line (C-x Rubout)
 Kill backward to the beginning of the line.

unix-line-discard (C-u)
 Kill backward from point to the beginning of the line. The killed text is saved on the kill ring.

kill-whole-line
 Kill all characters on the current line regardless of point position.

kill-word (M-d)
 Kill from point to the end of the current word, or if between words, to the end of the next word. Word boundaries match those used by forward-word.

backward-kill-word (M-Rubout)
 Kill the word behind point. Word boundaries match those used by backward-word.

shell-kill-word
 Kill from point to the end of the current word, or if between words, to the end of the next word. Word boundaries match those used by shell-forward-word.

shell-backward-kill-word
 Kill the word behind point. Word boundaries match those used by shell-backward-word.

unix-word-rubout (C-w)
 Kill the word behind point, using whitespace as a word boundary. The killed text is saved on the kill ring.

unix-filename-rubout
 Kill the word behind point, using whitespace and the slash character as word boundaries. The killed text is saved on the kill ring.

delete-horizontal-space (M-\)
 Delete all spaces and tabs around point.

kill-region
 Kill the text in the current region.

copy-region-as-kill
 Copy the text in the region to the kill buffer.

copy-backward-word
 Copy the word before point to the kill buffer. Word boundaries match those of backward-word.

copy-forward-word
 Copy the word following point to the kill buffer. Word boundaries match those of forward-word.

yank (C-y)
 Yank the top of the kill ring into the buffer at point.

yank-pop (M-y)
 Rotate the kill ring and yank the new top. Only works following yank or yank-pop.
