### Word Designators

Word designators are used to select desired words from the event.  A : separates the event specification from
the word designator.  It may be omitted if the word designator begins with a ^, $, *, -, or %.  Words are
numbered from the beginning of the line, with the first word being denoted by 0 (zero).  Words are inserted
into the current line separated by single spaces.

0 (zero)
 The zeroth word.  For the shell, this is the command word.
n  The nth word.
^  The first argument.  That is, word 1.
$  The last word.  This is usually the last argument, but will expand to the zeroth word if there is only
 one word in the line.
%  The first word matched by the most recent `?string?' search, if the search string begins with a
 character that is part of a word.
x-y  A range of words; `-y' abbreviates `0-y'.
*  All of the words but the zeroth.  This is a synonym for `1-$'.  It is not an error to use * if there is
 just one word in the event; the empty string is returned in that case.
x* Abbreviates x-$.
x- Abbreviates x-$ like x*, but omits the last word. If x is missing, it defaults to 0.

If a word designator is supplied without an event specification, the previous command is used as the event.

