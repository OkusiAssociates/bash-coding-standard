### Readline Initialization

Readline is customized by putting commands in an initialization file (the inputrc file). The filename is taken from the value of the INPUTRC variable. If that variable is unset, the default is ~/.inputrc. If that file does not exist or cannot be read, the ultimate default is /etc/inputrc. When a program that uses the readline library starts up, the initialization file is read, and key bindings and variables are set.

Only a few basic constructs are allowed in the readline initialization file. Blank lines are ignored. Lines beginning with # are comments. Lines beginning with $ indicate conditional constructs. Other lines denote key bindings and variable settings.

The default key-bindings may be changed with an inputrc file. Other programs that use this library may add their own commands and bindings.

For example, placing

 M-Control-u: universal-argument
or
 C-Meta-u: universal-argument

into the inputrc would make M-C-u execute the readline command universal-argument.

The following symbolic character names are recognized: RUBOUT, DEL, ESC, LFD, NEWLINE, RET, RETURN, SPC, SPACE, and TAB.

In addition to command names, readline allows keys to be bound to a string that is inserted when the key is pressed (a macro).
