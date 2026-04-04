## FUNCTIONS

A shell function, defined as described under SHELL GRAMMAR, stores a series of commands for later execution. When the name of a shell function is used as a simple command name, the list of commands associated with that function name is executed. Functions execute in the context of the current shell; no new process is created to interpret them (contrast this with executing a shell script). When a function executes, the arguments to the function become the positional parameters during its execution. Special parameter # is updated to reflect the change. Special parameter 0 is unchanged. The first element of the FUNCNAME variable is set to the name of the function while it is executing.

All other aspects of the shell execution environment are identical between a function and its caller with these exceptions: the DEBUG and RETURN traps are not inherited unless the function has been given the trace attribute (see the declare builtin) or the -o functrace option has been enabled with set (in which case all functions inherit the DEBUG and RETURN traps), and the ERR trap is not inherited unless the -o errtrace option has been enabled.

Variables local to the function may be declared with the local builtin. Ordinarily, variables and their values are shared between the function and its caller. If a variable is declared local, its visible scope is restricted to that function and its children (including the functions it calls).

In the following description, the current scope is a currently-executing function. Previous scopes consist of that function's caller and so on, back to the "global" scope, where the shell is not executing any shell function. A local variable at the current scope is a variable declared using the local or declare builtins in the function that is currently executing.

Local variables "shadow" variables with the same name declared at previous scopes. A local variable declared in a function hides a global variable of the same name: references and assignments refer to the local variable, leaving the global variable unmodified. When the function returns, the global variable is once again visible.

The shell uses dynamic scoping to control a variable's visibility within functions. With dynamic scoping, visible variables and their values are a result of the sequence of function calls that caused execution to reach the current function. The value of a variable that a function sees depends on its value within its caller, whether that caller is the "global" scope or another shell function. This is also the value that a local variable declaration "shadows", and the value restored when the function returns.

For example, if a variable var is declared as local in function func1, and func1 calls another function func2, references to var from within func2 resolve to the local variable var from func1, shadowing any global variable named var.

The unset builtin also acts using the same dynamic scope: if a variable is local to the current scope, unset will unset it; otherwise the unset refers to the variable found in any calling scope as described. If a variable at the current local scope is unset, it will remain so (appearing as unset) until it is reset in that scope or until the function returns. Once the function returns, any instance of the variable at a previous scope becomes visible. If the unset acts on a variable at a previous scope, any instance of a variable with that name that had been shadowed becomes visible (see localvar_unset shell option for modified behavior).

The FUNCNEST variable, if set to a numeric value greater than 0, defines a maximum function nesting level. Function invocations that exceed the limit cause the entire command to abort.

If the return builtin is executed in a function, the function completes and execution resumes with the next command after the function call. Any command associated with the RETURN trap is executed before execution resumes. When a function completes, the values of the positional parameters and special parameter # are restored to the values they had prior to the function's execution.

Function names and definitions may be listed with the -f option to declare or typeset. The -F option to declare or typeset lists function names only (and optionally the source file and line number, if the extdebug shell option is enabled). Functions may be exported so that child shell processes automatically have them defined with the -f option to the export builtin. A function definition may be deleted using the -f option to the unset builtin.

Functions may be recursive. The FUNCNEST variable may be used to limit the depth of the function call stack and restrict the number of function invocations. By default, no limit is imposed on the number of recursive calls.

