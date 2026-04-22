<!-- SPDX-License-Identifier: GPL-3.0-or-later -->
### compgen
compgen [option] [word]

Generate possible completion matches for word according to the options, which may be any option accepted by the complete builtin except -p and -r, and write the matches to standard output. When using the -F or -C options, the various shell variables set by the programmable completion facilities, while available, will not have useful values.

Matches are generated as if the programmable completion code had produced them directly from a completion specification with the same flags. If word is specified, only completions matching word are displayed.

Returns true unless an invalid option is supplied or no matches were generated.
