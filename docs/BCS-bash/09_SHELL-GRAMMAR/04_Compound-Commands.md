<!-- SPDX-License-Identifier: GPL-3.0-or-later -->
### Compound Commands

A compound command is one of the following. In most cases a list in a command's description may be separated from the rest of the command by one or more newlines, and may be followed by a newline in place of a semicolon.

(list)
 list is executed in a subshell (see COMMAND EXECUTION ENVIRONMENT). Variable assignments and builtin commands that affect the shell's environment do not remain in effect after the command completes. The return status is the exit status of list.

{ list; }
 list is executed in the current shell environment. list must be terminated with a newline or semicolon. This is known as a group command. The return status is the exit status of list. Unlike the metacharacters ( and ), { and } are reserved words and must occur where a reserved word is permitted. Since they do not cause a word break, they must be separated from list by whitespace or another shell metacharacter.

((expression))
 The expression is evaluated according to the rules described under ARITHMETIC EVALUATION. If the value of the expression is non-zero, the return status is 0; otherwise the return status is 1. The expression undergoes the same expansions as if it were within double quotes, but double quote characters in expression are not treated specially and are removed.

[[ expression ]]
 Returns a status of 0 or 1 depending on the evaluation of the conditional expression. Expressions are composed of the primaries described under CONDITIONAL EXPRESSIONS. The words between [[ and ]] do not undergo word splitting and pathname expansion. The shell performs tilde expansion, parameter and variable expansion, arithmetic expansion, command substitution, process substitution, and quote removal on those words (the expansions that would occur if the words were enclosed in double quotes). Conditional operators such as -f must be unquoted to be recognized as primaries.

 When used with [[, the < and > operators sort lexicographically using the current locale.

 When the == and != operators are used, the string to the right of the operator is considered a pattern and matched according to the rules described under Pattern Matching, as if the extglob shell option were enabled. The = operator is equivalent to ==. If the nocasematch shell option is enabled, the match is performed without regard to the case of alphabetic characters. The return value is 0 if the string matches (==) or does not match (!=) the pattern, and 1 otherwise. Any part of the pattern may be quoted to force the quoted portion to be matched as a string.

 An additional binary operator, =~, is available, with the same precedence as == and !=. The string to the right of the operator is considered an extended regular expression and matched accordingly (as described in regex(3)). The return value is 0 if the string matches the pattern, and 1 otherwise. If the regular expression is syntactically incorrect, the return value is 2. If the nocasematch shell option is enabled, the match is performed without regard to the case of alphabetic characters.

 If any part of the pattern is quoted, the quoted portion is matched literally -- every character in the quoted portion matches itself, without any special pattern matching meaning. If the pattern is stored in a shell variable, quoting the variable expansion forces the entire pattern to be matched literally. Treat bracket expressions in regular expressions carefully, since normal quoting and pattern characters lose their meanings between brackets.

 The pattern will match if it matches any part of the string. Anchor the pattern using the ^ and $ regular expression operators to force it to match the entire string. The array variable BASH_REMATCH records which parts of the string matched the pattern. The element with index 0 contains the portion of the string matching the entire regular expression. Substrings matched by parenthesized subexpressions are saved in the remaining BASH_REMATCH indices. The element with index n is the portion of the string matching the nth parenthesized subexpression. Bash sets BASH_REMATCH in the global scope; declaring it as a local variable will lead to unexpected results.

 Expressions may be combined using the following operators, listed in decreasing order of precedence:

 ( expression )
  Returns the value of expression. May be used to override normal operator precedence.

 ! expression
  True if expression is false.

 expression1 && expression2
  True if both expression1 and expression2 are true.

 expression1 || expression2
  True if either expression1 or expression2 is true.

 The && and || operators do not evaluate expression2 if the value of expression1 is sufficient to determine the return value of the entire conditional expression.

for name [ [ in [ word ... ] ] ; ] do list ; done
 The list of words following in is expanded, generating a list of items. The variable name is set to each element of this list in turn, and list is executed each time. If the in word is omitted, the for command executes list once for each positional parameter that is set (see PARAMETERS). The return status is the exit status of the last command that executes. If the expansion of the items following in results in an empty list, no commands are executed, and the return status is 0.

for (( expr1 ; expr2 ; expr3 )) ; do list ; done
 First, the arithmetic expression expr1 is evaluated according to the rules described under ARITHMETIC EVALUATION. The arithmetic expression expr2 is then evaluated repeatedly until it evaluates to zero. Each time expr2 evaluates to a non-zero value, list is executed and the arithmetic expression expr3 is evaluated. If any expression is omitted, it behaves as if it evaluates to 1. The return value is the exit status of the last command in list that is executed, or false if any of the expressions is invalid.

select name [ in word ] ; do list ; done
 The list of words following in is expanded, generating a list of items, and the set of expanded words is printed on standard error, each preceded by a number. If the in word is omitted, the positional parameters are printed (see PARAMETERS). select then displays the PS3 prompt and reads a line from standard input. If the line consists of a number corresponding to one of the displayed words, the value of name is set to that word. If the line is empty, the words and prompt are displayed again. If EOF is read, the select command completes and returns 1. Any other value read causes name to be set to null. The line read is saved in the variable REPLY. The list is executed after each selection until a break command is executed. The exit status of select is the exit status of the last command executed in list, or zero if no commands were executed.

case word in [ [(] pattern [ | pattern ] ... ) list ;; ] ... esac
 A case command first expands word, and tries to match it against each pattern in turn, using the matching rules described under Pattern Matching. The word is expanded using tilde expansion, parameter and variable expansion, arithmetic expansion, command substitution, process substitution, and quote removal. Each pattern examined is expanded using tilde expansion, parameter and variable expansion, arithmetic expansion, command substitution, process substitution, and quote removal. If the nocasematch shell option is enabled, the match is performed without regard to the case of alphabetic characters.

 When a match is found, the corresponding list is executed. If the ;; operator is used, no subsequent matches are attempted after the first pattern match. Using ;& in place of ;; causes execution to continue with the list associated with the next set of patterns. Using ;;& in place of ;; causes the shell to test the next pattern list in the statement, if any, and execute any associated list on a successful match, continuing the case statement execution as if the pattern list had not matched. The exit status is zero if no pattern matches. Otherwise, it is the exit status of the last command executed in list.

if list; then list; [ elif list; then list; ] ... [ else list; ] fi
 The if list is executed. If its exit status is zero, the then list is executed. Otherwise, each elif list is executed in turn, and if its exit status is zero, the corresponding then list is executed and the command completes. Otherwise, the else list is executed, if present. The exit status is the exit status of the last command executed, or zero if no condition tested true.

while list-1; do list-2; done
until list-1; do list-2; done
 The while command continuously executes list-2 as long as the last command in list-1 returns an exit status of zero. The until command is identical to while, except that the test is negated: list-2 is executed as long as the last command in list-1 returns a non-zero exit status. The exit status of while and until is the exit status of the last command executed in list-2, or zero if none was executed.
