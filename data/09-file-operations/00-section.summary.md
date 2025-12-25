# File Operations

This section establishes safe file handling practices to prevent common shell scripting pitfalls. Covers proper file testing operators (`-e`, `-f`, `-d`, `-r`, `-w`, `-x`) with explicit quoting, safe wildcard expansion using explicit paths (`rm ./*` never `rm *`), process substitution (`< <(command)`) to avoid subshell variable issues, and here document patterns for multi-line input. These defensive practices prevent accidental deletion, handle special characters safely, and ensure reliable operations across environments.
