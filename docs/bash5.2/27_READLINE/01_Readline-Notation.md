### Readline Notation

In this section, the Emacs-style notation is used to denote keystrokes.  Control keys are denoted by C-key,
e.g., C-n means Control-N.  Similarly, meta keys are denoted by M-key, so M-x means Meta-X.  (On keyboards
without a meta key, M-x means ESC x, i.e., press the Escape key then the x key.  This makes ESC the meta
prefix.  The combination M-C-x means ESC-Control-x, or press the Escape key then hold the Control key while
pressing the x key.)

Readline commands may be given numeric arguments, which normally act as a repeat count.  Sometimes, however,
it is the sign of the argument that is significant.  Passing a negative argument to a command that acts in the
forward direction (e.g., kill-line) causes that command to act in a backward direction.  Commands whose
behavior with arguments deviates from this are noted below.

When a command is described as killing text, the text deleted is saved for possible future retrieval
(yanking).  The killed text is saved in a kill ring.  Consecutive kills cause the text to be accumulated into
one unit, which can be yanked all at once.  Commands which do not kill text separate the chunks of text on the
kill ring.

