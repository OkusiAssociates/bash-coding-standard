## Wildcard Expansion
Always use explicit path prefix when expanding wildcards to prevent filenames starting with `-` from being interpreted as flags.

```bash
#  Correct - explicit path prevents flag interpretation
rm -v ./*
for file in ./*.txt; do
  process "$file"
done

#  Incorrect - filenames starting with - become flags
rm -v *
```
