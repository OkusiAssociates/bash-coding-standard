### Searching

Readline provides commands for searching through the command history for lines containing a specified string. There are two search modes: incremental and non-incremental.

Incremental searches begin before the user has finished typing the search string. As each character of the search string is typed, readline displays the next entry from the history matching the string typed so far. An incremental search requires only as many characters as needed to find the desired history entry. The characters present in the value of the isearch-terminators variable terminate an incremental search. If that variable has not been assigned a value, the Escape and Control-J characters terminate an incremental search. Control-G aborts an incremental search and restores the original line. When the search terminates, the history entry containing the search string becomes the current line.

To find other matching entries in the history list, type Control-S or Control-R as appropriate. This searches backward or forward in the history for the next entry matching the search string typed so far. Any other key sequence bound to a readline command terminates the search and executes that command. For instance, a newline terminates the search and accepts the line, executing the command from the history list.

Readline remembers the last incremental search string. If two Control-Rs are typed without any intervening characters defining a new search string, the remembered search string is used.

Non-incremental searches read the entire search string before starting to search for matching history lines. The search string may be typed by the user or be part of the contents of the current line.
