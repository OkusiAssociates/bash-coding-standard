### compopt
compopt [-o option] [-DEI] [+o option] [name]
 Modify completion options for each name according to the options, or for the currently-executing
 completion if no names are supplied.  If no options are given, display the completion options for each
 name or the current completion.  The possible values of option are those valid for the complete builtin
 described above.  The -D option indicates that other supplied options should apply to the ``default''
 command completion; that is, completion attempted on a command for which no completion has previously
 been defined.  The -E option indicates that other supplied options should apply to ``empty'' command
 completion; that is, completion attempted on a blank line.  The -I option indicates that other supplied
 options should apply to completion on the initial non-assignment word on the line, or after a command
 delimiter such as ; or |, which is usually command name completion.

 The return value is true unless an invalid option is supplied, an attempt is made to modify the options
 for a name for which no completion specification exists, or an output error occurs.

