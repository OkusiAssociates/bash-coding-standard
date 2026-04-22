<!-- SPDX-License-Identifier: GPL-3.0-or-later -->
### history

history [n]
history -c
history -d offset
history -d start-end
history -anrw [filename]
history -p arg [arg ...]
history -s arg [arg ...]

With no options, display the command history list with line numbers. Lines listed with a * have been modified. An argument of n lists only the last n lines. If HISTTIMEFORMAT is set and not null, it is used as a strftime(3) format string to display the time stamp associated with each displayed history entry. No intervening blank is printed between the formatted time stamp and the history line. If filename is supplied, it is used as the history file; otherwise the value of HISTFILE is used.

-c  Clear the history list by deleting all entries.

-d offset  Delete the history entry at position offset. If offset is negative, it is interpreted relative to one greater than the last history position, so negative indices count back from the end, and an index of -1 refers to the current history -d command.

-d start-end  Delete the range of history entries between positions start and end, inclusive. Positive and negative values for start and end are interpreted the same way as for -d offset.

-a  Append the new history lines (entered since the beginning of the current bash session but not already appended) to the history file.

-n  Read the history lines not already read from the history file into the current history list. These are lines appended to the history file since the beginning of the current bash session.

-r  Read the contents of the history file and append them to the current history list.

-w  Write the current history list to the history file, overwriting its contents.

-p  Perform history substitution on the following args and display the result on standard output. Does not store the results in the history list. Each arg must be quoted to disable normal history expansion.

-s  Store the args in the history list as a single entry. The last command in the history list is removed before the args are added.

If HISTTIMEFORMAT is set, the time stamp information associated with each history entry is written to the history file, marked with the history comment character. When the history file is read, lines beginning with the history comment character followed immediately by a digit are interpreted as timestamps for the following history entry.

Returns 0 unless an invalid option is encountered, an error occurs while reading or writing the history file, an invalid offset or range is supplied to -d, or the history expansion supplied to -p fails.
