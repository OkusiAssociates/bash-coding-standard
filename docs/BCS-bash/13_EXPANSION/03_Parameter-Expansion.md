<!-- SPDX-License-Identifier: GPL-3.0-or-later -->
### Parameter Expansion

The $ character introduces parameter expansion, command substitution, or arithmetic expansion. The parameter name or symbol to be expanded may be enclosed in braces, which are optional but protect the variable from characters immediately following it that could be interpreted as part of the name.

When braces are used, the matching ending brace is the first } not escaped by a backslash or within a quoted string, and not within an embedded arithmetic expansion, command substitution, or parameter expansion.

${parameter}
 The value of parameter is substituted. Braces are required when parameter is a positional parameter with more than one digit, or when parameter is followed by a character that is not to be interpreted as part of its name. The parameter is a shell parameter (see PARAMETERS) or an array reference (see Arrays).

If the first character of parameter is an exclamation point (!) and parameter is not a nameref, it introduces a level of indirection. Bash uses the value formed by expanding the rest of parameter as the new parameter; this value is then expanded and used in the rest of the expansion rather than the expansion of the original parameter. This is known as indirect expansion. The value is subject to tilde expansion, parameter expansion, command substitution, and arithmetic expansion.

If parameter is a nameref, this expands to the name of the parameter referenced by parameter instead of performing the complete indirect expansion. The exceptions are the expansions of ${!prefix*} and ${!name[@]}. The exclamation point must immediately follow the left brace to introduce indirection.

In each of the cases that follow, word is subject to tilde expansion, parameter expansion, command substitution, and arithmetic expansion.

When not performing substring expansion, using the forms documented here (e.g., :-), bash tests for a parameter that is unset or null. Omitting the colon results in a test only for a parameter that is unset.

${parameter:-word}
 Use Default Values. If parameter is unset or null, the expansion of word is substituted. Otherwise the value of parameter is substituted.

${parameter:=word}
 Assign Default Values. If parameter is unset or null, the expansion of word is assigned to parameter and the value of parameter is then substituted. Positional parameters and special parameters may not be assigned to in this way.

${parameter:?word}
 Display Error if Null or Unset. If parameter is null or unset, the expansion of word (or a default message if word is not present) is written to standard error and the shell exits if it is not interactive. Otherwise the value of parameter is substituted.

${parameter:+word}
 Use Alternate Value. If parameter is null or unset, nothing is substituted. Otherwise the expansion of word is substituted.

${parameter:offset}
${parameter:offset:length}
 Substring Expansion. Expands to up to length characters of the value of parameter starting at the character specified by offset. If parameter is @ or *, an indexed array subscripted by @ or *, or an associative array name, the results differ as described in the paragraphs that follow. If length is omitted, expands to the substring from offset to the end of the value. Both length and offset are arithmetic expressions (see ARITHMETIC EVALUATION).

 If offset evaluates to a number less than zero, the value is used as an offset in characters from the end of the value of parameter. If length evaluates to a number less than zero, it is interpreted as an offset from the end of the value rather than a character count, and the expansion is the characters between the two offsets. A negative offset must be separated from the colon by at least one space to avoid being confused with the :- expansion.

 If parameter is @ or *, the result is length positional parameters beginning at offset. A negative offset is taken relative to one greater than the greatest positional parameter, so an offset of -1 evaluates to the last positional parameter. It is an expansion error if length evaluates to a number less than zero.

 If parameter is an indexed array name subscripted by @ or *, the result is the length members of the array beginning with ${parameter[offset]}. A negative offset is taken relative to one greater than the maximum index of the specified array. It is an expansion error if length evaluates to a number less than zero.

 Substring expansion applied to an associative array produces undefined results.

 Substring indexing is zero-based unless the positional parameters are used, in which case indexing starts at 1 by default. If offset is 0 and the positional parameters are used, $0 is prefixed to the list.

${!prefix*}
${!prefix@}
 Names matching prefix. Expands to the names of variables whose names begin with prefix, separated by the first character of IFS. When @ is used and the expansion appears within double quotes, each variable name expands to a separate word.

${!name[@]}
${!name[*]}
 List of array keys. If name is an array variable, expands to the list of array indices (keys) assigned in name. If name is not an array, expands to 0 if name is set and null otherwise. When @ is used and the expansion appears within double quotes, each key expands to a separate word.

${#parameter}
 Parameter length. Substitutes the length in characters of the value of parameter. If parameter is * or @, the value substituted is the number of positional parameters. If parameter is an array name subscripted by * or @, the value substituted is the number of elements in the array. If parameter is an indexed array name subscripted by a negative number, that number is interpreted as relative to one greater than the maximum index of parameter, so negative indices count back from the end of the array and an index of -1 references the last element.

${parameter#word}
${parameter##word}
 Remove matching prefix pattern. The word is expanded to produce a pattern as in pathname expansion and matched against the expanded value of parameter using the rules in Pattern Matching. If the pattern matches the beginning of the value of parameter, the result is the expanded value with the shortest matching pattern (the # case) or the longest matching pattern (the ## case) deleted. If parameter is @ or *, the pattern removal operation is applied to each positional parameter in turn and the expansion is the resultant list. If parameter is an array variable subscripted with @ or *, the operation is applied to each member of the array in turn and the expansion is the resultant list.

${parameter%word}
${parameter%%word}
 Remove matching suffix pattern. The word is expanded to produce a pattern as in pathname expansion and matched against the expanded value of parameter using the rules in Pattern Matching. If the pattern matches a trailing portion of the expanded value of parameter, the result is the expanded value with the shortest matching pattern (the % case) or the longest matching pattern (the %% case) deleted. If parameter is @ or *, the pattern removal operation is applied to each positional parameter in turn and the expansion is the resultant list. If parameter is an array variable subscripted with @ or *, the operation is applied to each member of the array in turn and the expansion is the resultant list.

${parameter/pattern/string}
${parameter//pattern/string}
${parameter/#pattern/string}
${parameter/%pattern/string}
 Pattern substitution. The pattern is expanded to produce a pattern as in pathname expansion. Parameter is expanded and the longest match of pattern against its value is replaced with string. The string undergoes tilde expansion, parameter and variable expansion, arithmetic expansion, command and process substitution, and quote removal. The match is performed using the rules in Pattern Matching.

 In the first form, only the first match is replaced. If there are two slashes separating parameter and pattern (the second form), all matches of pattern are replaced with string. If pattern is preceded by # (the third form), it must match at the beginning of the expanded value of parameter. If pattern is preceded by % (the fourth form), it must match at the end of the expanded value of parameter. If the expansion of string is null, matches of pattern are deleted. If string is null, matches of pattern are deleted and the / following pattern may be omitted.

 If the patsub_replacement shell option is enabled using shopt, any unquoted instances of & in string are replaced with the matching portion of pattern.

 Quoting any part of string inhibits replacement in the expansion of the quoted portion, including replacement strings stored in shell variables. Backslash escapes & in string; the backslash is removed to permit a literal & in the replacement string. Backslash can also escape a backslash; \\ results in a literal backslash in the replacement. Take care if string is double-quoted to avoid unwanted interactions between the backslash and double-quoting, since backslash has special meaning within double quotes. Pattern substitution performs the check for unquoted & after expanding string, so quote any occurrences of & intended as literal characters in the replacement and leave unquoted any instances of & intended for substitution.

 If the nocasematch shell option is enabled, the match is performed without regard to case. If parameter is @ or *, the substitution operation is applied to each positional parameter in turn and the expansion is the resultant list. If parameter is an array variable subscripted with @ or *, the operation is applied to each member of the array in turn and the expansion is the resultant list.

${parameter^pattern}
${parameter^^pattern}
${parameter,pattern}
${parameter,,pattern}
 Case modification. Modifies the case of alphabetic characters in parameter. The pattern is expanded to produce a pattern as in pathname expansion. Each character in the expanded value of parameter is tested against pattern, and if it matches, its case is converted. The pattern should not attempt to match more than one character.

 The ^ operator converts lowercase letters matching pattern to uppercase; the , operator converts matching uppercase letters to lowercase. The ^^ and ,, expansions convert each matched character in the expanded value; the ^ and , expansions convert only the first character. If pattern is omitted, it is treated as ?, which matches every character.

 If parameter is @ or *, the case modification operation is applied to each positional parameter in turn and the expansion is the resultant list. If parameter is an array variable subscripted with @ or *, the operation is applied to each member of the array in turn and the expansion is the resultant list.

${parameter@operator}
 Parameter transformation. The expansion is either a transformation of the value of parameter or information about parameter itself, depending on the value of operator. Each operator is a single letter:

 U  Converts lowercase alphabetic characters to uppercase.
 u  Converts the first character to uppercase, if it is alphabetic.
 L  Converts uppercase alphabetic characters to lowercase.
 Q  Quotes the value in a format that can be reused as input.
 E  Expands backslash escape sequences as with the $'...' quoting mechanism.
 P  Expands the value as if it were a prompt string (see PROMPTING).
 A  Produces a string in the form of an assignment statement or declare command that, if evaluated, would recreate parameter with its attributes and value.
 K  Produces a possibly-quoted version of the value, except that indexed and associative arrays are printed as a sequence of quoted key-value pairs (see Arrays).
 a  Produces a string of flag values representing parameter's attributes.
 k  Like K, but expands the keys and values of indexed and associative arrays to separate words after word splitting.

 If parameter is @ or *, the operation is applied to each positional parameter in turn and the expansion is the resultant list. If parameter is an array variable subscripted with @ or *, the operation is applied to each member of the array in turn and the expansion is the resultant list.

 The result of the expansion is subject to word splitting and pathname expansion.
