### compopt
compopt [-o option] [-DEI] [+o option] [name]

Modify completion options for each name according to the options, or for the currently-executing completion if no names are supplied. If no options are given, display the completion options for each name or the current completion. The possible values of option are those valid for the complete builtin.

-D  Apply other supplied options to default command completion, i.e., completion attempted on a command for which no completion has previously been defined.

-E  Apply other supplied options to empty command completion, i.e., completion attempted on a blank line.

-I  Apply other supplied options to completion on the initial non-assignment word on the line, or after a command delimiter such as ; or |, which is usually command name completion.

Returns true unless an invalid option is supplied, an attempt is made to modify options for a name with no completion specification, or an output error occurs.
