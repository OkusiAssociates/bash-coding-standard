<!-- SPDX-License-Identifier: GPL-3.0-or-later -->
### Readline Notation

In this section, Emacs-style notation denotes keystrokes. Control keys are written C-key, e.g., C-n means Control-N. Meta keys are written M-key, so M-x means Meta-X. On keyboards without a meta key, M-x means ESC x (press Escape then x), making ESC the meta prefix. The combination M-C-x means ESC-Control-x, or press Escape then hold Control while pressing x.

Readline commands may be given numeric arguments, which normally act as a repeat count. Sometimes the sign of the argument is what matters. Passing a negative argument to a command that acts in the forward direction (e.g., kill-line) causes it to act backward. Commands whose behavior with arguments deviates from this are noted individually.

When a command is described as killing text, the deleted text is saved for possible future retrieval (yanking). Killed text is saved in a kill ring. Consecutive kills accumulate text into one unit, which can be yanked all at once. Commands that do not kill text separate the chunks on the kill ring.
