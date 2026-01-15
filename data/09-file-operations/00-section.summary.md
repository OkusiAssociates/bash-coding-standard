# File Operations

Safe file handling practices for shell scripting. Covers file testing operators (`-e`, `-f`, `-d`, `-r`, `-w`, `-x`) with explicit quoting, safe wildcard expansion (`rm ./*` never `rm *`), process substitution (`< <(command)`) to avoid subshell variable issues, and here documents for multi-line input. Prevents accidental deletion, handles special characters safely, ensures reliable operations across environments.
