### echo
echo [-neE] [arg ...]

Output the args, separated by spaces, followed by a newline. The return status is 0 unless a write error occurs. echo does not interpret -- to mean the end of options.

-n  Suppress the trailing newline.

-e  Enable interpretation of backslash-escaped characters.

-E  Disable interpretation of escape characters, even on systems where they are interpreted by default.

The xpg_echo shell option may be used to dynamically determine whether echo expands escape characters by default.

When -e is active, echo interprets the following escape sequences:

 \a  alert (bell)
 \b  backspace
 \c  suppress further output
 \e  an escape character
 \E  an escape character
 \f  form feed
 \n  new line
 \r  carriage return
 \t  horizontal tab
 \v  vertical tab
 \\  backslash
 \0nnn  the eight-bit character whose value is the octal value nnn (zero to three octal digits)
 \xHH  the eight-bit character whose value is the hexadecimal value HH (one or two hex digits)
 \uHHHH  the Unicode (ISO/IEC 10646) character whose value is the hexadecimal value HHHH (one to four hex digits)
 \UHHHHHHHH  the Unicode (ISO/IEC 10646) character whose value is the hexadecimal value HHHHHHHH (one to eight hex digits)
