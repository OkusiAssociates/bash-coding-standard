### Numeric Arguments

digit-argument (M-0, M-1, ..., M--)
 Add this digit to the argument already accumulating, or start a new argument.  M-- starts a negative
 argument.
universal-argument
 This is another way to specify an argument.  If this command is followed by one or more digits,
 optionally with a leading minus sign, those digits define the argument.  If the command is followed by
 digits, executing universal-argument again ends the numeric argument, but is otherwise ignored.  As a
 special case, if this command is immediately followed by a character that is neither a digit nor minus
 sign, the argument count for the next command is multiplied by four.  The argument count is initially
 one, so executing this function the first time makes the argument count four, a second time makes the
 argument count sixteen, and so on.

