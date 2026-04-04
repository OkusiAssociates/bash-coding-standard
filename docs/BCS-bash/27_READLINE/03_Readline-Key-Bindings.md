### Readline Key Bindings

The syntax for controlling key bindings in the inputrc file is simple. All that is required is the name of the command or the text of a macro and a key sequence to which it should be bound. The name may be specified in one of two ways: as a symbolic key name, possibly with Meta- or Control- prefixes, or as a key sequence.

When using the form keyname:function-name or macro, keyname is the name of a key spelled out in English. For example:

 Control-u: universal-argument
 Meta-Rubout: backward-kill-word
 Control-o: "> output"

In this example, C-u is bound to universal-argument, M-DEL is bound to backward-kill-word, and C-o is bound to run the macro on the right hand side (inserting the text "> output" into the line).

In the second form, "keyseq":function-name or macro, keyseq differs from keyname in that strings denoting an entire key sequence may be specified within double quotes. Some GNU Emacs style key escapes can be used, as in the following example, but the symbolic character names are not recognized.

 "\C-u": universal-argument
 "\C-x\C-r": re-read-init-file
 "\e[11~": "Function Key 1"

In this example, C-u is again bound to universal-argument. C-x C-r is bound to re-read-init-file, and ESC [ 1 1 ~ is bound to insert the text "Function Key 1".

The full set of GNU Emacs style escape sequences is

 \C-  control prefix
 \M-  meta prefix
 \e an escape character
 \\ backslash
 \" literal "
 \' literal '

In addition to the GNU Emacs style escape sequences, a second set of backslash escapes is available:

 \a alert (bell)
 \b backspace
 \d delete
 \f form feed
 \n newline
 \r carriage return
 \t horizontal tab
 \v vertical tab
 \nnn the eight-bit character whose value is the octal value nnn (one to three digits)
 \xHH the eight-bit character whose value is the hexadecimal value HH (one or two hex digits)

When entering the text of a macro, single or double quotes must be used to indicate a macro definition. Unquoted text is assumed to be a function name. In the macro body, the backslash escapes described here are expanded. Backslash quotes any other character in the macro text, including " and '.

Bash allows the current readline key bindings to be displayed or modified with the bind builtin. The editing mode may be switched during interactive use by using the -o option to the set builtin.
