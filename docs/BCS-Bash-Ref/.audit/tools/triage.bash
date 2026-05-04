#!/usr/bin/env bash
# triage.bash — fold lint + runtime findings into a per-finding
# disposition table. First-pass classification is rule-based; rows that
# need human attention are tagged TRIAGE_NEEDED with a hint.
#
# Output: .audit/findings/dispositions-augmented.tsv
#   leaf  block_idx  source(lint|runtime)  code_or_bucket  action  confidence  rationale
# action ∈ {FIX_BLOCK, FIX_ANNOTATION, ADD_SUPPRESSION, EXPECTED_VIOLATION,
#           EXPECTED_CRASH, SANDBOX_ARTEFACT, FALSE_POSITIVE, REVIEW}
# confidence ∈ {HIGH, MEDIUM, LOW}
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

declare -rx PATH="$HOME/.local/bin:/usr/local/bin:/usr/bin:/bin"

declare -r VERSION='1.0.0'
#shellcheck disable=SC2155
declare -r SCRIPT_PATH="$(realpath -- "$0")"
declare -r SCRIPT_DIR="${SCRIPT_PATH%/*}"
declare -r SCRIPT_NAME="${SCRIPT_PATH##*/}"

declare -r REF_DIR="${SCRIPT_DIR%/.audit/tools}"
declare -r DEFAULT_INV="$REF_DIR/.audit/findings/inventory.tsv"
declare -r DEFAULT_LINT="$REF_DIR/.audit/findings/shellcheck.tsv"
declare -r DEFAULT_RUN="$REF_DIR/.audit/findings/runtime.tsv"
declare -r DEFAULT_BLOCKS="$REF_DIR/.audit/blocks"
declare -r DEFAULT_LOG_DIR="$REF_DIR/.audit/findings/runtime-log"
declare -r DEFAULT_OUT="$REF_DIR/.audit/findings/dispositions-augmented.tsv"

declare -i VERBOSE=1

if [[ -t 1 && -t 2 ]]; then
  declare -r RED=$'\033[0;31m' GREEN=$'\033[0;32m' YELLOW=$'\033[0;33m' CYAN=$'\033[0;36m' NC=$'\033[0m'
else
  declare -r RED='' GREEN='' YELLOW='' CYAN='' NC=''
fi

_msg()    { >&2 printf '%s: %s %s\n' "$SCRIPT_NAME" "$1" "${*:2}"; }
error()   { _msg "$RED✗$NC" "$@"; }
warn()    { _msg "$YELLOW▲$NC" "$@"; }
info()    { ((VERBOSE)) || return 0; _msg "$CYAN◉$NC" "$@"; }
success() { ((VERBOSE)) || return 0; _msg "$GREEN✓$NC" "$@"; }
die()     { (($# < 2)) || error "${@:2}"; exit "${1:-0}"; }
noarg()   { (($# > 1)) || die 22 "Option ${1@Q} requires an argument"; }

show_help() {
  cat <<HELP
$SCRIPT_NAME $VERSION -- First-pass triage of lint+runtime findings.

Usage: $SCRIPT_NAME [OPTIONS]

Options:
  -i, --inventory FILE  Inventory TSV (default: $DEFAULT_INV)
  -l, --lint FILE       Shellcheck TSV (default: $DEFAULT_LINT)
  -r, --runtime FILE    Runtime TSV (default: $DEFAULT_RUN)
  -b, --blocks DIR      Materialised blocks (default: $DEFAULT_BLOCKS)
  -L, --log-dir DIR     Per-block runtime logs (default: $DEFAULT_LOG_DIR)
  -o, --output FILE     Output TSV (default: $DEFAULT_OUT)
  -q, --quiet           Suppress informational output
  -V, --version         Show version
  -h, --help            Show this help
HELP
}

flatten_path() {
  local -- p="$1"
  printf '%s' "${p//\//__}"
}

# Read body of a materialised block (sidecar stripped) for pattern matching.
read_block_body() {
  local -- leaf="$1" idx="$2" blocks_dir="$3"
  local -- flat src
  flat="$(flatten_path "$leaf")"
  printf -v src '%s/%s__%03d.bash' "$blocks_dir" "$flat" "$idx"
  [[ -f "$src" ]] && awk '!/^# bcs-audit:/' "$src" || true
}

# Read captured stderr / stdout of a runtime block. Empty string if absent.
read_log() {
  local -- leaf="$1" idx="$2" log_dir="$3" suffix="$4"
  local -- flat src
  flat="$(flatten_path "$leaf")"
  printf -v src '%s/%s__%03d.%s' "$log_dir" "$flat" "$idx" "$suffix"
  [[ -f "$src" ]] && cat -- "$src" || true
}

# Classify one shellcheck finding into action + confidence.
# Inputs: code, level, label, body (block body), block_line.
# Outputs: "ACTION\tCONFIDENCE\tRATIONALE"
# Single-quoted printf strings deliberately preserve literal $() / [] / # ⇒
# in rationales — this is data, not code.
#shellcheck disable=SC2016
classify_lint() {
  local -- code="$1" level="$2" label="$3" body="$4"
  case "$label" in
    WRONG)
      printf 'EXPECTED_VIOLATION\tHIGH\tblock labelled WRONG (anti-pattern demo)' ; return ;;
  esac
  case "$code" in
    SC1128)
      # Shebang must be on first line. Convention here puts a
      # `# scenario:` comment above the shebang to label the demo.
      if [[ "$body" =~ ^[[:space:]]*\#[[:space:]]*scenario: ]]; then
        printf 'ADD_SUPPRESSION\tHIGH\tcorpus convention places `# scenario:` above shebang'
      else
        printf 'FIX_BLOCK\tMEDIUM\tshebang not on first non-blank line'
      fi
      return ;;
    SC2034)
      # Variable unused — most are pedagogy.
      if [[ "$label" == 'MIXED' || "$label" == 'RIGHT' ]]; then
        printf 'ADD_SUPPRESSION\tMEDIUM\tdeclared to demonstrate, not consumed'
      else
        printf 'ADD_SUPPRESSION\tMEDIUM\tlikely declared for demonstration'
      fi
      return ;;
    SC2154)
      # Variable referenced but not assigned — common in fragments
      # that reference vars defined earlier in the leaf prose.
      printf 'ADD_SUPPRESSION\tMEDIUM\tfragment references context var defined in prose'
      return ;;
    SC1090|SC1091)
      printf 'ADD_SUPPRESSION\tHIGH\tnon-constant source — standard suppression idiom'
      return ;;
    SC2155)
      printf 'FIX_BLOCK\tHIGH\tdeclare and assign separately (BCS-flagged)'
      return ;;
    SC2046)
      printf 'FIX_BLOCK\tHIGH\tunquoted $(...) — likely real bug'
      return ;;
    SC2086)
      printf 'FIX_BLOCK\tHIGH\tunquoted variable — likely real bug'
      return ;;
    SC2120)
      # BCS canonical idiom: helpers like noarg() { (($# > 1)) || die ...; }
      # use $#/$@ without declaring parameters; SC2120 is a false positive
      # for these. Real cases are rare; default to suppression.
      printf 'ADD_SUPPRESSION\tMEDIUM\tBCS noarg-style helper uses $#/$@ without declared params'
      return ;;
    SC2288)
      printf 'FIX_BLOCK\tHIGH\t$(...) inside [...] — likely real bug'
      return ;;
    SC1072|SC1073)
      # Parser errors — usually intentional grammar samples.
      printf 'REVIEW\tLOW\tparser error — possibly an intentional grammar sample'
      return ;;
    SC1083)
      printf 'REVIEW\tLOW\tliteral { ... } in word context — diagram or footgun?'
      return ;;
    SC1056|SC1036)
      printf 'REVIEW\tLOW\tcode-fence parser confusion — investigate per-leaf'
      return ;;
    SC2242)
      # Invalid exit code (e.g., negative). Often pedagogical.
      printf 'REVIEW\tLOW\tinvalid exit code — verify pedagogical intent'
      return ;;
    SC2068)
      printf 'FIX_BLOCK\tHIGH\t$@ unquoted — likely real bug'
      return ;;
    SC2091)
      printf 'REVIEW\tMEDIUM\t$(...) used as a command — verify'
      return ;;
    *)
      printf 'REVIEW\tLOW\tcode %s — first-pass triage rule not yet defined' "$code"
      return ;;
  esac
}

# Classify one runtime row. Inputs: bucket, label, exit_code, body, stderr,
# stdout, expected. Empty-string stderr/stdout/expected if logs missing.
#shellcheck disable=SC2016
classify_runtime() {
  local -- bucket="$1" label="$2" exit_code="$3" body="$4"
  local -- stderr="${5:-}" stdout="${6:-}" expected="${7:-}"
  case "$bucket" in
    OK)
      printf 'NO_ACTION\tHIGH\tran cleanly; expected output matched'
      return ;;
    NO_EXPECTED)
      printf 'NO_ACTION\tHIGH\tran cleanly; no annotations to compare'
      return ;;
    MISSING_ANNOT)
      printf 'FIX_ANNOTATION\tMEDIUM\tblock produced output but has no `# ⇒` annotation — opportunity to add'
      return ;;
    MISMATCH)
      # If actual stdout exposes the sandbox HOME (mktemp dir) and the
      # expected output references a real /home/ path, that is a HOME
      # divergence, not a corpus bug.
      if [[ "$stdout" =~ /tmp/bcs-audit-run- ]] \
        && [[ "$expected" =~ /home/ ]]; then
        printf 'SANDBOX_HOME\tHIGH\tactual leaks sandbox tmp; expected references /home/'
        return
      fi
      # /home/u/ placeholder convention — doc shows a literal placeholder.
      if [[ "$body" =~ /home/u(/|[[:space:]]|$) ]]; then
        printf 'FALSE_POSITIVE\tMEDIUM\tdoc uses /home/u placeholder; runtime sees sandbox HOME'
        return
      fi
      # Documentation references a real user home (/home/<name>) that
      # the sandbox cannot reproduce.
      if [[ "$expected" =~ /home/[a-z][a-z0-9_-]+ ]]; then
        printf 'SANDBOX_HOME\tMEDIUM\texpected references a real /home/<user> path'
        return
      fi
      # Non-deterministic output — PID / BASHPID / $$.
      if [[ "$expected" =~ (BASHPID|\$\$|PID=|PPID=|UID=) ]]; then
        printf 'SANDBOX_NONDETERMINISTIC\tHIGH\texpected references PID/BASHPID — varies per run'
        return
      fi
      # Non-deterministic output — timestamp / date.
      if [[ "$expected" =~ (Mon|Tue|Wed|Thu|Fri|Sat|Sun)[[:space:]] ]] \
        || [[ "$expected" =~ [0-9]{4}-[0-9]{2}-[0-9]{2} ]] \
        || [[ "$expected" =~ [0-9]{2}:[0-9]{2}:[0-9]{2} ]] \
        || [[ "$expected" =~ (Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)[[:space:]] ]]; then
        printf 'SANDBOX_NONDETERMINISTIC\tHIGH\texpected references timestamp — varies per run'
        return
      fi
      # Non-deterministic — random tmp path or mktemp output.
      if [[ "$expected" =~ /tmp/[a-zA-Z0-9._-]+ ]] \
        || [[ "$expected" =~ tmp\.[A-Za-z0-9]{6,} ]] \
        || [[ "$expected" =~ \$RANDOM ]]; then
        printf 'SANDBOX_NONDETERMINISTIC\tHIGH\texpected references random tmp path'
        return
      fi
      # Live filesystem listing — `ls -l` output, depends on host state.
      if [[ "$expected" =~ ^[[:space:]]*total[[:space:]][0-9]+ ]] \
        || [[ "$expected" =~ -[r-][w-][x-][r-][w-][x-][r-][w-][x-] ]] \
        || [[ "$expected" =~ drwx ]]; then
        printf 'SANDBOX_FS\tMEDIUM\texpected lists ls -l output — depends on host filesystem state'
        return
      fi
      printf 'REVIEW\tMEDIUM\tactual stdout did not contain documented `# ⇒` text — fix doc or block'
      return ;;
    CRASH)
      if [[ "$label" == 'WRONG' ]]; then
        printf 'EXPECTED_CRASH\tHIGH\tblock is anti-pattern demo; non-zero exit is the point'
        return
      fi
      # Documentation explicitly anticipates non-zero exit — pipefail/SIGPIPE
      # demos, errexit-exemption gotchas, etc.
      if [[ "$expected" =~ (EXITS|exits|abort|fails|killed|SIGPIPE|rc=[1-9]|exit[[:space:]]code[[:space:]][1-9]) ]]; then
        printf 'EXPECTED_CRASH\tHIGH\tdoc annotations describe non-zero exit as the expected outcome'
        return
      fi
      # SIGPIPE — exit 141 from a producer killed by an early-closing reader.
      if [[ "$exit_code" == '141' ]]; then
        printf 'EXPECTED_CRASH\tHIGH\texit 141 (SIGPIPE) — likely deliberate pipefail/SIGPIPE demo'
        return
      fi
      # `# scenario:` self-documents the failure intent.
      if [[ "$body" =~ \#[[:space:]]scenario:[^$]*(EXIT|exit|abort|fail|wrong|crash|gotcha) ]]; then
        printf 'EXPECTED_CRASH\tMEDIUM\tscenario comment marks the block as failure-demo'
        return
      fi
      # Stderr-led classification (preferred — looks at the actual
      # failure, not just the source body).
      if [[ -n "$stderr" ]]; then
        # Okusi fleet binary missing.
        if [[ "$stderr" =~ (bcscheck|phcs|ok[0-3]|push-to-okusi|symlink|oknav|lhssh|lhssh-cmd)(:[[:space:]]|[[:space:]])*command\ not\ found ]]; then
          printf 'SANDBOX_FLEET\tHIGH\tfleet binary not present in sandbox'
          return
        fi
        # Common system tool missing under env -i.
        if [[ "$stderr" =~ (curl|wget|ssh|scp|systemctl|journalctl|nft|iptables|nmcli|lsof|nc|netcat|dig|host|bats|bash5\.3|brew|apt|dpkg|snap|docker|podman|kubectl|jq)(:[[:space:]]|[[:space:]])*command\ not\ found ]]; then
          printf 'SANDBOX_TOOL\tHIGH\tsystem tool unavailable in sandbox PATH'
          return
        fi
        # Permission denied — usually system file.
        if [[ "$stderr" =~ [Pp]ermission[[:space:]]denied ]]; then
          printf 'SANDBOX_PERM\tHIGH\tpermission denied (sandbox lacks privilege)'
          return
        fi
        # Missing system path under /etc, /var, /proc, /sys, /run.
        if [[ "$stderr" =~ (No[[:space:]]such[[:space:]]file[[:space:]]or[[:space:]]directory|cannot[[:space:]]open|cannot[[:space:]]access|cannot[[:space:]]statx)[^$]*/(etc|var|proc|sys|run)/ ]]; then
          printf 'SANDBOX_FS\tHIGH\tmissing system path under /etc /var /proc /sys /run'
          return
        fi
        # Strict-mode unbound-variable from a fragment that pulls a name
        # from surrounding leaf prose.
        if [[ "$stderr" =~ unbound[[:space:]]variable ]]; then
          printf 'ILLUSTRATIVE_FRAGMENT\tMEDIUM\tunbound var under set -u; fragment references prose-context name'
          return
        fi
        # Bats / test-runner fixtures absent in sandbox.
        if [[ "$stderr" =~ (bats|tests/?:|cd[[:space:]]+tests:[[:space:]]No[[:space:]]such) ]]; then
          printf 'SANDBOX_TOOL\tMEDIUM\ttest-runner fixtures absent in sandbox'
          return
        fi
        # Block needs root (explicit re-run-with-sudo message).
        if [[ "$stderr" =~ needs[[:space:]]root|requires[[:space:]]root|run[[:space:]]as[[:space:]]root ]]; then
          printf 'SANDBOX_PERM\tHIGH\tblock self-aborts: needs root'
          return
        fi
        # Bash version requirement.
        if [[ "$stderr" =~ requires[[:space:]]bash[[:space:]][0-9] ]]; then
          printf 'SANDBOX_TOOL\tHIGH\tblock asserts a bash version newer than sandbox'
          return
        fi
        # Custom error-trap output: the block is demonstrating error
        # handling, so a non-zero exit *is* the documented outcome.
        if [[ "$stderr" =~ ^ERR[[:space:]]rc=[0-9]+ ]] \
          || [[ "$stderr" =~ ERR[[:space:]]rc=[0-9]+[[:space:]] ]]; then
          printf 'EXPECTED_CRASH\tMEDIUM\tcustom error-trap output: block demos failure handling'
          return
        fi
        # Catch-all for command-not-found (placeholder names like
        # `mytool`, `cleanup`, `@test`, `mylib` or genuine missing tools
        # that the curated list doesn't enumerate). After the fleet/
        # tool-curated checks above, anything else is sandbox or
        # placeholder, not a corpus bug.
        if [[ "$stderr" =~ command[[:space:]]not[[:space:]]found ]]; then
          printf 'SANDBOX_TOOL\tMEDIUM\tunresolved external command (sandbox lacks tool or placeholder name)'
          return
        fi
        # Generic missing-file (No such file or directory, cannot open,
        # cannot access, cannot statx) outside system paths. Most are
        # sandbox setup gaps.
        if [[ "$stderr" =~ (No[[:space:]]such[[:space:]]file[[:space:]]or[[:space:]]directory|cannot[[:space:]](open|access|statx)) ]]; then
          printf 'SANDBOX_FS\tMEDIUM\tmissing file or path (sandbox setup gap)'
          return
        fi
        # Syntax errors — likely intentional grammar-illustration fragment.
        if [[ "$stderr" =~ syntax[[:space:]]error ]]; then
          printf 'EXPECTED_CRASH\tLOW\tparser error — possibly intentional grammar sample'
          return
        fi
        # Generic "fatal:" prefix from upstream tool (git/etc.) we do not
        # have configured in the sandbox.
        if [[ "$stderr" =~ ^fatal: ]]; then
          printf 'SANDBOX_TOOL\tMEDIUM\tupstream tool fatal error (likely missing setup in sandbox)'
          return
        fi
      else
        # Empty stderr + non-zero exit: typically an intentional
        # `false` / `exit N` / `return N` demonstration.
        if [[ "$body" =~ (^|[^[:alnum:]_])(false|exit[[:space:]]+[0-9]+|return[[:space:]]+[0-9]+) ]]; then
          printf 'EXPECTED_CRASH\tMEDIUM\tbody contains explicit false/exit/return — failure is the demo'
          return
        fi
      fi
      # Body-led fallback (still useful when stderr is empty).
      if [[ "$body" =~ (^|[^[:alnum:]_])(die|info|success|warn|error|noarg|vecho|yn)[[:space:]] ]]; then
        printf 'SANDBOX_ARTEFACT\tMEDIUM\tblock calls BCS messaging helper (stub-loaded but call may still fail)'
        return
      fi
      if [[ "$body" =~ (^|[^[:alnum:]_])(bcscheck|phcs|ok[123]|push-to-okusi|symlink)[[:space:]] ]]; then
        printf 'SANDBOX_FLEET\tHIGH\tbody calls Okusi-fleet binary'
        return
      fi
      if [[ "$body" =~ /(etc|var|proc|sys|run)/ ]]; then
        printf 'SANDBOX_FS\tMEDIUM\tbody reads /etc /var /proc /sys /run path — sandbox may differ'
        return
      fi
      printf 'REVIEW\tLOW\tcrash with no obvious sandbox cause; exit=%s' "$exit_code"
      return ;;
    TIMEOUT)
      # Polling/signal demos genuinely cannot run in batch.
      if [[ "$body" =~ (^|[^[:alnum:]_])(read[[:space:]]+-r|wait[[:space:]]|kill[[:space:]]+-STOP|trap[[:space:]]+) ]]; then
        printf 'EXPECTED_TIMEOUT\tMEDIUM\tinteractive/signal-bound demo cannot complete in batch'
        return
      fi
      printf 'REVIEW\tMEDIUM\thit 10s wall — long sleep loop or accidental hang'
      return ;;
    *)
      printf 'REVIEW\tLOW\tunknown bucket %s' "$bucket"
      return ;;
  esac
}

run() {
  local -- inv="$1" lint="$2" runtm="$3" blocks="$4" log_dir="$5" out="$6"
  for f in "$inv" "$lint" "$runtm"; do
    [[ -f "$f" ]] || die 3 "missing input: $f"
  done
  [[ -d "$blocks" ]] || die 3 "missing blocks dir: $blocks"
  [[ -d "$log_dir" ]] || warn "log dir not found: $log_dir (stderr-aware rules disabled)"

  mkdir -p -- "${out%/*}"
  printf 'leaf_path\tblock_idx\tsource\tcode\tlevel_or_bucket\tlabel\taction\tconfidence\trationale\n' > "$out"

  # Build label map from inventory: leaf TAB idx -> label
  declare -A LABEL_MAP=()
  local -- l_leaf l_idx l_label
  while IFS=$'\t' read -r l_leaf l_idx _ _ _ _ l_label _ _ _; do
    [[ "$l_leaf" == 'leaf_path' ]] && continue
    LABEL_MAP["$l_leaf	$l_idx"]="$l_label"
  done < "$inv"

  local -i lint_count=0 runtime_count=0
  local -- leaf idx label code level body action conf rat runrow
  local -- bucket exit_code

  # Pass 1: lint rows
  #shellcheck disable=SC2034
  local -- _runn _label _exp _block_line _leaf_line _msg
  while IFS=$'\t' read -r leaf idx _runn _label code level _block_line _leaf_line _exp _msg; do
    [[ "$leaf" == 'leaf_path' ]] && continue
    label="${LABEL_MAP["$leaf	$idx"]:-NEUTRAL}"
    body="$(read_block_body "$leaf" "$idx" "$blocks")"
    runrow="$(classify_lint "$code" "$level" "$label" "$body")"
    IFS=$'\t' read -r action conf rat <<< "$runrow"
    printf '%s\t%s\tlint\t%s\t%s\t%s\t%s\t%s\t%s\n' \
      "$leaf" "$idx" "$code" "$level" "$label" "$action" "$conf" "$rat" >> "$out"
    lint_count+=1
  done < "$lint"

  # Pass 2: runtime rows
  local -- stderr_txt stdout_txt expected_txt
  while IFS=$'\t' read -r leaf idx _runn label exit_code bucket _ _ _ _; do
    [[ "$leaf" == 'leaf_path' ]] && continue
    body="$(read_block_body "$leaf" "$idx" "$blocks")"
    stderr_txt=''; stdout_txt=''; expected_txt=''
    if [[ -d "$log_dir" ]]; then
      stderr_txt="$(read_log "$leaf" "$idx" "$log_dir" stderr)"
      stdout_txt="$(read_log "$leaf" "$idx" "$log_dir" stdout)"
    fi
    # Cheap re-extraction of expected: any `# ⇒` line from the body. Used
    # only for SANDBOX_HOME detection in MISMATCH cases.
    expected_txt="$(awk '/[[:space:]]*#[[:space:]]*⇒/' <<< "$body")"
    runrow="$(classify_runtime "$bucket" "$label" "$exit_code" "$body" "$stderr_txt" "$stdout_txt" "$expected_txt")"
    IFS=$'\t' read -r action conf rat <<< "$runrow"
    printf '%s\t%s\truntime\t%s\t%s\t%s\t%s\t%s\t%s\n' \
      "$leaf" "$idx" "$bucket" "exit=$exit_code" "$label" "$action" "$conf" "$rat" >> "$out"
    runtime_count+=1
  done < "$runtm"

  success "triaged $lint_count lint findings + $runtime_count runtime rows → $out"
}

main() {
  local -- inv="$DEFAULT_INV" lint="$DEFAULT_LINT" runtm="$DEFAULT_RUN"
  local -- blocks="$DEFAULT_BLOCKS" log_dir="$DEFAULT_LOG_DIR" out="$DEFAULT_OUT"
  while (($#)); do
    case "$1" in
      -i|--inventory) noarg "$@"; inv="$2"; shift 2 ;;
      -l|--lint)      noarg "$@"; lint="$2"; shift 2 ;;
      -r|--runtime)   noarg "$@"; runtm="$2"; shift 2 ;;
      -b|--blocks)    noarg "$@"; blocks="$2"; shift 2 ;;
      -L|--log-dir)   noarg "$@"; log_dir="$2"; shift 2 ;;
      -o|--output)    noarg "$@"; out="$2"; shift 2 ;;
      -q|--quiet)     VERBOSE=0; shift ;;
      -V|--version)   printf '%s %s\n' "$SCRIPT_NAME" "$VERSION"; exit 0 ;;
      -h|--help)      show_help; exit 0 ;;
      -[ilrbLoqVh]?*) set -- "${1:0:2}" "-${1:2}" "${@:2}"; continue ;;
      --)             shift; break ;;
      -*)             die 22 "Unknown option: $1" ;;
      *)              die 22 "Unexpected argument: $1" ;;
    esac
  done
  run "$inv" "$lint" "$runtm" "$blocks" "$log_dir" "$out"
}

main "$@"
#fin
