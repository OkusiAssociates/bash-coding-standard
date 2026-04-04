### complete
complete [-abcdefgjksuv] [-o comp-option] [-DEI] [-A action] [-G globpat] [-W wordlist]
 [-F function] [-C command] [-X filterpat] [-P prefix] [-S suffix] name [name ...]
complete -pr [-DEI] [name ...]
 Specify how arguments to each name should be completed.  If the -p option is supplied, or if no options
 are supplied, existing completion specifications are printed in a way that allows them to be reused as
 input.  The -r option removes a completion specification for each name, or, if no names are supplied,
 all completion specifications.  The -D option indicates that other supplied options and actions should
 apply to the ``default'' command completion; that is, completion attempted on a command for which no
 completion has previously been defined.  The -E option indicates that other supplied options and
 actions should apply to ``empty'' command completion; that is, completion attempted on a blank line.
 The -I option indicates that other supplied options and actions should apply to completion on the
 initial non-assignment word on the line, or after a command delimiter such as ; or |, which is usually
 command name completion.  If multiple options are supplied, the -D option takes precedence over -E, and
 both take precedence over -I.  If any of -D, -E, or -I are supplied, any other name arguments are
 ignored; these completions only apply to the case specified by the option.

 The process of applying these completion specifications when word completion is attempted is described
 above under Programmable Completion.

 Other options, if specified, have the following meanings. The arguments to the -G, -W, and -X options
 (and, if necessary, the -P and -S options) should be quoted to protect them from expansion before the
 complete builtin is invoked.
 -o comp-option
 The comp-option controls several aspects of the compspec's behavior beyond the simple
 generation of completions.  comp-option may be one of:
 bashdefault
 Perform the rest of the default bash completions if the compspec generates no matches.
 default Use readline's default filename completion if the compspec generates no matches.
 dirnames
 Perform directory name completion if the compspec generates no matches.
 filenames
 Tell readline that the compspec generates filenames, so it can perform any
 filename-specific processing (like adding a slash to directory names, quoting special
 characters, or suppressing trailing spaces).  Intended to be used with shell functions.
 noquote Tell readline not to quote the completed words if they are filenames (quoting filenames
 is the default).
 nosort  Tell readline not to sort the list of possible completions alphabetically.
 nospace Tell readline not to append a space (the default) to words completed at the end of the
 line.
 plusdirs
 After any matches defined by the compspec are generated, directory name completion is
 attempted and any matches are added to the results of the other actions.
 -A action
 The action may be one of the following to generate a list of possible completions:
 alias Alias names.  May also be specified as -a.
 arrayvar
 Array variable names.
 binding Readline key binding names.
 builtin Names of shell builtin commands.  May also be specified as -b.
 command Command names.  May also be specified as -c.
 directory
 Directory names.  May also be specified as -d.
 disabled
 Names of disabled shell builtins.
 enabled Names of enabled shell builtins.
 export  Names of exported shell variables.  May also be specified as -e.
 file  File names.  May also be specified as -f.
 function
 Names of shell functions.
 group Group names.  May also be specified as -g.
 helptopic
 Help topics as accepted by the help builtin.
 hostname
 Hostnames, as taken from the file specified by the HOSTFILE shell variable.
 job Job names, if job control is active.  May also be specified as -j.
 keyword Shell reserved words.  May also be specified as -k.
 running Names of running jobs, if job control is active.
 service Service names.  May also be specified as -s.
 setopt  Valid arguments for the -o option to the set builtin.
 shopt Shell option names as accepted by the shopt builtin.
 signal  Signal names.
 stopped Names of stopped jobs, if job control is active.
 user  User names.  May also be specified as -u.
 variable
 Names of all shell variables.  May also be specified as -v.
 -C command
 command is executed in a subshell environment, and its output is used as the possible
 completions.  Arguments are passed as with the -F option.
 -F function
 The shell function function is executed in the current shell environment. When the function is
 executed, the first argument ($1) is the name of the command whose arguments are being
 completed, the second argument ($2) is the word being completed, and the third argument ($3) is
 the word preceding the word being completed on the current command line.  When it finishes, the
 possible completions are retrieved from the value of the COMPREPLY array variable.
 -G globpat
 The pathname expansion pattern globpat is expanded to generate the possible completions.
 -P prefix
 prefix is added at the beginning of each possible completion after all other options have been
 applied.
 -S suffix
 suffix is appended to each possible completion after all other options have been applied.
 -W wordlist
 The wordlist is split using the characters in the IFS special variable as delimiters, and each
 resultant word is expanded.  Shell quoting is honored within wordlist, in order to provide a
 mechanism for the words to contain shell metacharacters or characters in the value of IFS.  The
 possible completions are the members of the resultant list which match the word being
 completed.
 -X filterpat
 filterpat is a pattern as used for pathname expansion.  It is applied to the list of possible
 completions generated by the preceding options and arguments, and each completion matching
 filterpat is removed from the list.  A leading ! in filterpat negates the pattern; in this
 case, any completion not matching filterpat is removed.

 The return value is true unless an invalid option is supplied, an option other than -p or -r is
 supplied without a name argument, an attempt is made to remove a completion specification for a name
 for which no specification exists, or an error occurs adding a completion specification.

