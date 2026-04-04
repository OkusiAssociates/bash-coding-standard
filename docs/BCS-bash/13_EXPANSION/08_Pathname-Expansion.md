### Pathname Expansion

After word splitting, unless the -f option has been set, bash scans each word for the characters *, ?, and [. If one of these characters appears and is not quoted, the word is regarded as a pattern and replaced with an alphabetically sorted list of filenames matching the pattern (see Pattern Matching). If no matching filenames are found and the nullglob shell option is not enabled, the word is left unchanged. If nullglob is set and no matches are found, the word is removed. If the failglob shell option is set and no matches are found, an error message is printed and the command is not executed. If the nocaseglob shell option is enabled, the match is performed without regard to the case of alphabetic characters.

When using range expressions like [a-z], letters of the other case may be included depending on the setting of LC_COLLATE. When a pattern is used for pathname expansion, the character . at the start of a name or immediately following a slash must be matched explicitly, unless the dotglob shell option is set. To match the filenames . and .., the pattern must begin with . (for example, .?), even if dotglob is set. If the globskipdots shell option is enabled, the filenames . and .. are never matched, even if the pattern begins with a dot. When not matching pathnames, the . character is not treated specially. When matching a pathname, the slash character must always be matched explicitly by a slash in the pattern, but in other matching contexts it can be matched by a special pattern character as described in Pattern Matching. See the shopt builtin for descriptions of the nocaseglob, nullglob, globskipdots, failglob, and dotglob shell options.

The GLOBIGNORE shell variable restricts the set of filenames matching a pattern. If GLOBIGNORE is set, each matching filename that also matches one of the patterns in GLOBIGNORE is removed from the list of matches. If the nocaseglob option is set, the matching against GLOBIGNORE patterns is performed without regard to case.

The filenames . and .. are always ignored when GLOBIGNORE is set and not null. However, setting GLOBIGNORE to a non-null value enables the dotglob shell option, so all other filenames beginning with . will match. To restore the behavior of ignoring filenames beginning with a dot, include .* as one of the patterns in GLOBIGNORE. The dotglob option is disabled when GLOBIGNORE is unset. The pattern matching honors the setting of the extglob shell option.


#### Pattern Matching

Any character that appears in a pattern, other than the special pattern characters described here, matches itself. The NUL character may not occur in a pattern. A backslash escapes the following character; the escaping backslash is discarded when matching. The special pattern characters must be quoted if they are to be matched literally.

The special pattern characters have the following meanings:

*  Matches any string, including the null string. When the globstar shell option is enabled and * is used in a pathname expansion context, two adjacent *s used as a single pattern match all files and zero or more directories and subdirectories. If followed by a /, two adjacent *s match only directories and subdirectories.

?  Matches any single character.

[...]  Matches any one of the enclosed characters. A pair of characters separated by a hyphen denotes a range expression; any character that falls between those two characters, inclusive, using the current locale's collating sequence and character set, is matched. If the first character following the [ is a ! or a ^ then any character not enclosed is matched. The sorting order of characters in range expressions, and the characters included in the range, are determined by the current locale and the values of the LC_COLLATE or LC_ALL shell variables, if set. To obtain the traditional interpretation of range expressions where [a-d] is equivalent to [abcd], set LC_ALL to C or enable the globasciiranges shell option. A - may be matched by including it as the first or last character in the set. A ] may be matched by including it as the first character in the set.

 Within [ and ], character classes can be specified using the syntax [:class:], where class is one of the following classes defined in the POSIX standard: alnum alpha ascii blank cntrl digit graph lower print punct space upper word xdigit. A character class matches any character belonging to that class. The word character class matches letters, digits, and the character _.

 Within [ and ], an equivalence class can be specified using the syntax [=c=], which matches all characters with the same collation weight (as defined by the current locale) as the character c.

 Within [ and ], the syntax [.symbol.] matches the collating symbol symbol.

If the extglob shell option is enabled using shopt, the shell recognizes several extended pattern matching operators. In the following description, a pattern-list is a list of one or more patterns separated by a |. Composite patterns may be formed using one or more of the following sub-patterns:

 ?(pattern-list)
  Matches zero or one occurrence of the given patterns

 *(pattern-list)
  Matches zero or more occurrences of the given patterns

 +(pattern-list)
  Matches one or more occurrences of the given patterns

 @(pattern-list)
  Matches one of the given patterns

 !(pattern-list)
  Matches anything except one of the given patterns

The extglob option changes the behavior of the parser, since the parentheses are normally treated as operators with syntactic meaning. To ensure that extended matching patterns are parsed correctly, make sure extglob is enabled before parsing constructs containing the patterns, including shell functions and command substitutions.

When matching filenames, the dotglob shell option determines the set of filenames that are tested. When dotglob is enabled, the set includes all files beginning with ., but . and .. must still be matched by a pattern or sub-pattern that begins with a dot. When dotglob is disabled, the set does not include any filenames beginning with . unless the pattern or sub-pattern begins with a dot. The . character only has a special meaning when matching filenames.

Complicated extended pattern matching against long strings is slow, especially when the patterns contain alternations and the strings contain multiple matches. Using separate matches against shorter strings, or using arrays of strings instead of a single long string, may be faster.
