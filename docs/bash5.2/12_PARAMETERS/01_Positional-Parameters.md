### Positional Parameters

A positional parameter is a parameter denoted by one or more digits, other than the single digit 0.
Positional parameters are assigned from the shell's arguments when it is invoked, and may be reassigned using
the set builtin command. Positional parameters may not be assigned to with assignment statements.  The
positional parameters are temporarily replaced when a shell function is executed (see FUNCTIONS below).

When a positional parameter consisting of more than a single digit is expanded, it must be enclosed in braces
(see EXPANSION below).

