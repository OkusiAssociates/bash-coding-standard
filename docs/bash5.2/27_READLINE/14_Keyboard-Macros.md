### Keyboard Macros

start-kbd-macro (C-x ()
 Begin saving the characters typed into the current keyboard macro.
end-kbd-macro (C-x ))
 Stop saving the characters typed into the current keyboard macro and store the definition.
call-last-kbd-macro (C-x e)
 Re-execute the last keyboard macro defined, by making the characters in the macro appear as if typed at
 the keyboard.
print-last-kbd-macro ()
 Print the last keyboard macro defined in a format suitable for the inputrc file.

