### Here Documents

A here-document redirects the shell to read input from the current source until a line containing only delimiter (with no trailing blanks) is seen. All lines read up to that point become the standard input (or file descriptor n if n is specified) for a command.

The format is:

 [n]<<[-]word
 here-document
 delimiter

No parameter expansion, command substitution, arithmetic expansion, or pathname expansion is performed on word. If any part of word is quoted, the delimiter is the result of quote removal on word, and lines in the here-document are not expanded. If word is unquoted, all lines of the here-document are subjected to parameter expansion, command substitution, and arithmetic expansion, the character sequence \<newline> is ignored, and \ must be used to quote the characters \, $, and `.

If the redirection operator is <<-, all leading tab characters are stripped from input lines and the line containing delimiter. This allows here-documents within shell scripts to be indented naturally.
