### Standard Argument Parsing Pattern
\`\`\`bash
while (($#)); do case $1 in
  -a|--add)       noarg "$@"; shift
                  process_argument "$1" ;;
  -m|--depth)     noarg "$@"; shift
                  max_depth="$1" ;;
  -L|--follow-symbolic)
                  symbolic='-L' ;;

  -p|--prompt)    PROMPT=1; VERBOSE=1 ;;
  -v|--verbose)   VERBOSE+=1 ;;

  -q|--quiet)     VERBOSE=0 ;;
  -V|--version)   echo "$SCRIPT_NAME $VERSION"; exit 0 ;;

  -h|--help)      show_help; exit 0 ;;
  -[amLpvqVh]*) #shellcheck disable=SC2046 #split up single options
                  set -- '' $(printf -- "-%c " $(grep -o . <<<"${1:1}")) "${@:2}" ;;
  -*)             die 22 "Invalid option '$1'" ;;
  *)              Paths+=("$1") ;;
esac; shift; done
\`\`\`
