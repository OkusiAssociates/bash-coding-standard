### local
local [option] [name[=value] ... | -]

For each argument, a local variable named name is created and assigned value. The option can be any of the options accepted by declare. When local is used within a function, it causes the variable name to have a visible scope restricted to that function and its children.

If name is -, the set of shell options is made local to the function in which local is invoked: shell options changed using set inside the function are restored to their original values when the function returns. The restore is effected as if a series of set commands were executed to restore the values that were in place before the function.

With no operands, local writes a list of local variables to standard output. It is an error to use local when not within a function.

Returns 0 unless local is used outside a function, an invalid name is supplied, or name is a readonly variable.
