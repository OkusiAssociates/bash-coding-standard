<!-- SPDX-License-Identifier: GPL-3.0-or-later -->
## DEFINITIONS

The following definitions are used throughout this document.

blank
 A space or tab.

word
 A sequence of characters considered as a single unit by the shell. Also known as a token.

name
 A word consisting only of alphanumeric characters and underscores, beginning with an alphabetic character or an underscore. Also referred to as an identifier.

metacharacter
 A character that, when unquoted, separates words. One of the following:
 | & ; ( ) < > space tab newline

control operator
 A token that performs a control function. One of the following symbols:
 || & && ; ;; ;& ;;& ( ) | |& <newline>

