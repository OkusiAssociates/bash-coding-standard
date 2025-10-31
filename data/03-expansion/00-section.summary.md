# Variable Expansion & Parameter Substitution

This section defines when to use braces in variable expansion. Default form is `"$var"` without braces. Use braces (`"${var}"`) only when syntactically required: parameter expansion operations (`${var##pattern}`, `${var:-default}`), variable concatenation (`"${var1}${var2}"`), array expansions (`"${array[@]}"`), and disambiguation. This keeps code cleaner and more readable.
