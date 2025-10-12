### Case Statements

#### Compact Format
For simple, single-action cases:

\`\`\`bash
while (($#)); do
  case $1 in
    -v|--verbose) VERBOSE+=1 ;;
    -q|--quiet)   VERBOSE=0 ;;
    -h|--help)    show_help; exit 0 ;;
    -[vqh]*) #shellcheck disable=SC2046 #split up single options
                  set -- '' $(printf -- "-%c " $(grep -o . <<<"${1:1}")) "${@:2}" ;;
    -*)           die 22 "Invalid option '$1'" ;;
    *)            Paths+=("$1") ;;
  esac
  shift
done
\`\`\`

#### Expanded Format
For multi-line actions or complex logic, use expanded format with column alignment:

\`\`\`bash
while (($#)); do
  case $1 in
    -b|--builtin)     INSTALL_BUILTIN=1
                      BUILTIN_REQUESTED=1
                      ;;
    -n|--no-builtin)  SKIP_BUILTIN=1
                      ;;
    -p|--prefix)      noarg "$@"; shift
                      PREFIX="$1"
                      BIN_DIR="$PREFIX"/bin
                      LOADABLE_DIR="$PREFIX"/lib/bash/loadables
                      # Comments within case branches allowed
                      ;;
    -V|--version)     echo "$SCRIPT_NAME $VERSION"
                      exit 0
                      ;;
    -h|--help)        show_help
                      exit 0
                      ;;
    -[bnpVh]*) #shellcheck disable=SC2046
                      set -- '' $(printf -- '-%c ' $(grep -o . <<<"${1:1}")) "${@:2}"
                      ;;
    -*)               die 22 "Invalid option '$1'"
                      ;;
    *)                >&2 show_help
                      die 2 "Unknown argument '$1'"
                      ;;
  esac
  shift
done
\`\`\`

**Formatting guidelines:**
- Align actions at column 14-18 for readability
- Use blank lines between \`;;\` and next pattern for multi-line actions
- Comments within branches are acceptable
- Omit quotes on \`$1\` in \`case $1 in\` (one-word literal exception)
- Choose compact or expanded consistently within a script
\`\`\`
