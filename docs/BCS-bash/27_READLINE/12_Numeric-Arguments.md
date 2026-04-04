### Numeric Arguments

digit-argument (M-0, M-1, ..., M--)
 Add this digit to the argument already accumulating, or start a new argument. M-- starts a negative argument.

universal-argument
 Another way to specify an argument. If followed by one or more digits, optionally with a leading minus sign, those digits define the argument. If followed by digits, executing universal-argument again ends the numeric argument but is otherwise ignored. As a special case, if immediately followed by a character that is neither a digit nor minus sign, the argument count for the next command is multiplied by four. The argument count is initially one, so executing this function the first time makes the argument count four, a second time makes it sixteen, and so on.
