### Readline Conditional Constructs

Readline implements a facility similar in spirit to the conditional compilation features of the C preprocessor
which allows key bindings and variable settings to be performed as the result of tests.  There are four parser
directives used.

$if  The $if construct allows bindings to be made based on the editing mode, the terminal being used, or the
 application using readline.  The text of the test, after any comparison operator,
  extends to the end of the line; unless otherwise noted, no characters are required to isolate it.

 mode The mode= form of the $if directive is used to test whether readline is in emacs or vi mode.
  This may be used in conjunction with the set keymap command, for instance, to set bindings in
  the emacs-standard and emacs-ctlx keymaps only if readline is starting out in emacs mode.

 term The term= form may be used to include terminal-specific key bindings, perhaps to bind the key
  sequences output by the terminal's function keys.  The word on the right side of the = is tested
  against both the full name of the terminal and the portion of the terminal name before the first
  -. This allows sun to match both sun and sun-cmd, for instance.

 version
  The version test may be used to perform comparisons against specific readline versions.  The
  version expands to the current readline version.  The set of comparison operators includes =,
  (and ==), !=, <=, >=, <, and >.  The version number supplied on the right side of the operator
  consists of a major version number, an optional decimal point, and an optional minor version
  (e.g., 7.1). If the minor version is omitted, it is assumed to be 0.  The operator may be
  separated from the string version and from the version number argument by whitespace.

 application
  The application construct is used to include application-specific settings.  Each program using
  the readline library sets the application name, and an initialization file can test for a
  particular value.  This could be used to bind key sequences to functions useful for a specific
  program.  For instance, the following command adds a key sequence that quotes the current or
  previous word in bash:

  $if Bash
  # Quote the current or previous word
  "\C-xq": "\eb\"\ef\""
  $endif

 variable
  The variable construct provides simple equality tests for readline variables and values.  The
  permitted comparison operators are =, ==, and !=.  The variable name must be separated from the
  comparison operator by whitespace; the operator may be separated from the value on the right
  hand side by whitespace.  Both string and boolean variables may be tested. Boolean variables
  must be tested against the values on and off.

$endif This command, as seen in the previous example, terminates an $if command.

$else  Commands in this branch of the $if directive are executed if the test fails.

$include
 This directive takes a single filename as an argument and reads commands and bindings from that file.
 For example, the following directive would read /etc/inputrc:

 $include  /etc/inputrc

