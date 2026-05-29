#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-3.0-or-later
# bcs-accuracy-score.sh - Score `bcs check` against the labelled fixture corpus.
#
# Turns the accuracy *collector* (bcs-check-accuracy.sh, which only dumps model
# output) into a *scorer*: it parses `bcs check -j` findings against each
# fixture's `bcs-fixture-expect:` pragma to compute precision / recall / F1
# (aggregate and per-rule), and re-runs every fixture N times to report a
# run-to-run stability score -- quantifying the LLM checker's non-determinism.
#
# Corpus (relative to repo root):
#   tests/fixtures/*.sh              violation fixtures (one core rule each)
#   tests/fixtures/probabilistic/*.sh  scored, not gated (recommended-tier, or core rules cheap models miss)
#   tests/fixtures/clean/*.sh        compliant scripts -- ANY finding is a FP
#
# Scoring (per fixture, per run, against the pragma's expected code set):
#   TP = reported codes that were expected
#   FP = reported codes that were NOT expected  (all findings on clean fixtures)
#   FN = expected codes that were NOT reported
# Precision = TP/(TP+FP)   Recall = TP/(TP+FN)   F1 = 2PR/(P+R)
#
# NOTE: on violation fixtures, "FP" includes *extra* findings that may well be
# real secondary issues -- so read precision off the clean fixtures, which have
# no true findings. Recall is the trustworthy signal on violation fixtures.
#
# Environment / flags:
#   -m MODEL  / BCS_SCORE_MODEL    pin model alias (skips backend sniff)
#   -e EFFORT / BCS_SCORE_EFFORT   effort level (default: low)
#   -n RUNS   / BCS_SCORE_RUNS     repetitions per fixture (default: 3)
#   -o DIR    / BCS_SCORE_OUTDIR   report output dir (default: this script's dir)
#   BCS_FIXTURES_REQUIRE_BACKEND=1 fail instead of skip when no backend reachable
#   trailing args = explicit fixture paths to score (default: whole corpus)
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

declare -- SCRIPT_PATH
SCRIPT_PATH=$(realpath -- "$0")
declare -r SCRIPT_PATH
declare -r SCRIPT_DIR=${SCRIPT_PATH%/*}
declare -r SCRIPT_NAME=${SCRIPT_PATH##*/}
declare -r VERSION='1.0.0'

declare -- PROJECT_DIR
PROJECT_DIR=$(realpath -- "$SCRIPT_DIR/../..")
declare -r PROJECT_DIR
declare -r BCS_CMD="$PROJECT_DIR"/bcs
declare -r FIXTURES_DIR="$PROJECT_DIR"/tests/fixtures

# Tunables (env defaults; CLI flags override).
declare -- MODEL=${BCS_SCORE_MODEL:-}
declare -- EFFORT=${BCS_SCORE_EFFORT:-low}
declare -i RUNS=${BCS_SCORE_RUNS:-3}
declare -- OUT_DIR=${BCS_SCORE_OUTDIR:-$SCRIPT_DIR}
declare -ri TIMEOUT_S=${BCS_SCORE_TIMEOUT:-150}
declare -i REQUIRE_BACKEND=${BCS_FIXTURES_REQUIRE_BACKEND:-0}

# Colors (stderr is the message channel).
if [[ -t 2 ]]; then
  declare -r RED=$'\033[0;31m' GREEN=$'\033[0;32m' YELLOW=$'\033[0;33m'
  declare -r CYAN=$'\033[0;36m' BOLD=$'\033[1m' NC=$'\033[0m'
else
  declare -r RED='' GREEN='' YELLOW='' CYAN='' BOLD='' NC=''
fi

# ---- messaging (BCS standard) ----
_msg() {
  local -- kind=${FUNCNAME[1]} color='' icon=''
  case $kind in
    info)    color=$CYAN;   icon='◉' ;;
    success) color=$GREEN;  icon='✓' ;;
    warn)    color=$YELLOW; icon='▲' ;;
    error)   color=$RED;    icon='✗' ;;
  esac
  printf '%s%s%s %s\n' "$color" "$icon" "$NC" "$*" >&2
}
info()    { _msg "$@"; }
success() { _msg "$@"; }
warn()    { _msg "$@"; }
error()   { _msg "$@"; }
die() {
  local -i rc=$1; shift
  [[ -n $* ]] && error "$*" ||:
  exit "$rc"
}
noarg() {
  (($# > 1)) || die 22 "Option ${1@Q} requires an argument"
  [[ ${2:0:1} != '-' ]] || die 22 "Option ${1@Q} requires an argument"
}

# ---- helpers ----
# Clean, sorted, unique BCS codes from a whitespace/newline blob.
_codes() { printf '%s\n' "$1" | grep -oE 'BCS[0-9]{4}' | sort -u || true; }
# True if newline-list $1 contains code $2.
_has() { [[ $'\n'"$1"$'\n' == *$'\n'"$2"$'\n'* ]]; }
# Filesystem-safe slug for a model name.
_slug() { local -- s=$1; s=${s//\//_}; s=${s//:/_}; printf '%s' "$s"; }

# Mirror test-check-fixtures.sh sniff order: claude → ollama → anthropic → openai → google.
probe_backend() {
  command -v claude &>/dev/null && { echo claude; return 0; } ||:
  local -- host=${OLLAMA_HOST:-localhost:11434}
  curl -sf --connect-timeout 2 "http://$host/api/tags" &>/dev/null \
    && { echo ollama; return 0; } ||:
  [[ -n ${ANTHROPIC_API_KEY:-} ]] && { echo anthropic; return 0; } ||:
  [[ -n ${OPENAI_API_KEY:-} ]] && { echo openai; return 0; } ||:
  [[ -n ${GOOGLE_API_KEY:-${GEMINI_API_KEY:-}} ]] && { echo google; return 0; } ||:
  return 1
}
# Cheapest model alias for a probed backend.
pick_model() {
  case $1 in
    claude)    echo claude-code:haiku ;;
    ollama)    echo "${BCS_FIXTURES_MODEL:-qwen-small}" ;;
    openai)    echo gpt5-mini ;;
    google)    echo flash-lite ;;
    anthropic) echo haiku ;;
    *)         echo haiku ;;
  esac
}

# ---- scoring state (global: populated by main(), read by _emit_reports()) ----
declare -i TP=0 FP=0 FN=0 INCONCLUSIVE=0 SCORED=0 CLEAN_FP=0 CLEAN_RUNS=0
declare -A PAIR_HITS=() PAIR_RUNS=() CODE_HIT=() CODE_TOT=()

show_help() {
  cat <<HELP
${BOLD}$SCRIPT_NAME$NC v$VERSION - Score bcs check accuracy (precision/recall/F1 + stability)

${BOLD}Usage:$NC $SCRIPT_NAME [OPTIONS] [FIXTURE...]

${BOLD}Options:$NC
  -m, --model MODEL   Model alias/id (default: cheapest reachable backend)
  -e, --effort LEVEL  Effort: min|low|medium|high|xhigh|max (default: low)
  -n, --runs N        Repetitions per fixture for stability (default: 3)
  -o, --output DIR    Report output directory (default: alongside this script)
  -h, --help          Show this help

With no FIXTURE arguments, scores the whole corpus under tests/fixtures/
(violation + probabilistic/ + clean/). Skips gracefully when no LLM backend
is reachable (set BCS_FIXTURES_REQUIRE_BACKEND=1 to fail instead).

${BOLD}Outputs (in --output dir):$NC
  accuracy-<model>-<effort>.tsv   per (fixture,code) hit-rates
  accuracy-<model>-<effort>.md    precision/recall/F1 + stability summary
HELP
}

main() {
  local -a rest=()
  while (($#)); do case $1 in
    -m|--model)   noarg "$@"; shift; MODEL=$1 ;;
    -e|--effort)  noarg "$@"; shift; EFFORT=$1 ;;
    -n|--runs)    noarg "$@"; shift; RUNS=$1 ;;
    -o|--output)  noarg "$@"; shift; OUT_DIR=$1 ;;
    -h|--help)    show_help; return 0 ;;
    --)           shift; rest+=("$@"); break ;;
    -*)           die 22 "Invalid option ${1@Q}" ;;
    *)            rest+=("$1") ;;
  esac; shift; done
  set -- "${rest[@]}"

  command -v jq &>/dev/null || die 18 'jq is required'
  command -v timeout &>/dev/null || die 18 'timeout (coreutils) is required'
  [[ -x $BCS_CMD ]] || die 3 "bcs CLI not found at ${BCS_CMD@Q}"
  ((RUNS >= 1)) || die 22 "runs must be >= 1 (got $RUNS)"

  # Resolve model: pinned wins; otherwise sniff a reachable backend.
  local -- backend='(pinned)'
  if [[ -z $MODEL ]]; then
    backend=$(probe_backend) ||:
    if [[ -z $backend ]]; then
      ((REQUIRE_BACKEND)) \
        && die 1 'no LLM backend available (BCS_FIXTURES_REQUIRE_BACKEND=1)' ||:
      warn 'no LLM backend reachable — skipping accuracy scoring'
      exit 0
    fi
    MODEL=$(pick_model "$backend")
  fi

  # Build corpus.
  local -a fixtures=()
  if (($#)); then
    fixtures=("$@")
  else
    fixtures=("$FIXTURES_DIR"/*.sh "$FIXTURES_DIR"/probabilistic/*.sh \
              "$FIXTURES_DIR"/clean/*.sh)
  fi
  local -a corpus=()
  local -- f
  for f in "${fixtures[@]}"; do [[ -f $f ]] && corpus+=("$f") ||:; done
  ((${#corpus[@]})) || die 3 'no fixtures found'

  mkdir -p -- "$OUT_DIR"
  info "model=$MODEL backend=$backend effort=$EFFORT runs=$RUNS fixtures=${#corpus[@]}"

  # Precompute expected sets.
  local -A EXP=() IS_CLEAN=()
  local -- expected
  for f in "${corpus[@]}"; do
    expected=$(sed -n '1,15p' "$f" | grep -F 'bcs-fixture-expect:' \
      | grep -oE 'BCS[0-9]{4}' | sort -u || true)
    EXP[$f]=$expected
    if [[ -z $expected || $f == */clean/* ]]; then IS_CLEAN[$f]=1; else IS_CLEAN[$f]=0; fi
  done

  # Per-run scratch (accumulators are module globals, reset at declaration).
  local -i run i_tp i_fp i_fn
  local -- json reported code pair

  for ((run=1; run<=RUNS; run+=1)); do
    info "run $run/$RUNS ..."
    for f in "${corpus[@]}"; do
      json=$(timeout "$TIMEOUT_S" "$BCS_CMD" check -j -m "$MODEL" -e "$EFFORT" \
        --quiet -- "$f" 2>/dev/null) || true
      if [[ -z $json ]] || ! jq -e 'has("comments")' <<<"$json" &>/dev/null; then
        INCONCLUSIVE+=1
        warn "inconclusive: ${f##*/} (run $run) — empty/invalid backend output"
        continue
      fi
      SCORED+=1
      reported=$(jq -r '.comments[].bcsCode // empty' <<<"$json" 2>/dev/null \
        | grep -oE 'BCS[0-9]{4}' | sort -u || true)
      expected=${EXP[$f]}
      i_tp=$(comm -12 <(_codes "$expected") <(_codes "$reported") | wc -l)
      i_fp=$(comm -13 <(_codes "$expected") <(_codes "$reported") | wc -l)
      i_fn=$(comm -23 <(_codes "$expected") <(_codes "$reported") | wc -l)
      TP=$((TP + i_tp)); FP=$((FP + i_fp)); FN=$((FN + i_fn))
      if ((IS_CLEAN[$f])); then CLEAN_FP=$((CLEAN_FP + i_fp)); CLEAN_RUNS+=1; fi
      while IFS= read -r code; do
        [[ -n $code ]] || continue
        pair="$f|$code"
        PAIR_RUNS[$pair]=$(( ${PAIR_RUNS[$pair]:-0} + 1 ))
        CODE_TOT[$code]=$(( ${CODE_TOT[$code]:-0} + 1 ))
        if _has "$reported" "$code"; then
          PAIR_HITS[$pair]=$(( ${PAIR_HITS[$pair]:-0} + 1 ))
          CODE_HIT[$code]=$(( ${CODE_HIT[$code]:-0} + 1 ))
        fi
      done < <(_codes "$expected")
    done
  done

  _emit_reports
}

# Render TSV + markdown from the accumulator state (called from main scope).
_emit_reports() {
  local -- slug tsv md ts
  slug=$(_slug "$MODEL")
  tsv="$OUT_DIR/accuracy-$slug-$EFFORT.tsv"
  md="$OUT_DIR/accuracy-$slug-$EFFORT.md"
  ts=$(date '+%Y-%m-%d %H:%M:%S')

  # Aggregate precision/recall/F1.
  local -- precision recall f1
  read -r precision recall f1 < <(awk -v tp="$TP" -v fp="$FP" -v fn="$FN" 'BEGIN{
    p=(tp+fp>0)?tp/(tp+fp):0; r=(tp+fn>0)?tp/(tp+fn):0;
    f=(p+r>0)?2*p*r/(p+r):0; printf "%.3f %.3f %.3f\n", p, r, f }')

  # Per-(fixture,code) stability rows + counts.
  local -i total_pairs=0 stable_pairs=0
  local -- rows='' key fixb code hr st pr ph
  for key in "${!PAIR_RUNS[@]}"; do
    total_pairs+=1
    pr=${PAIR_RUNS[$key]}; ph=${PAIR_HITS[$key]:-0}
    hr=$(awk -v h="$ph" -v n="$pr" 'BEGIN{printf "%.3f", (n>0)?h/n:0}')
    if [[ $hr == 1.000 || $hr == 0.000 ]]; then st=yes; stable_pairs+=1; else st=no; fi
    fixb=${key%%|*}; fixb=${fixb##*/}; code=${key##*|}
    rows+=$(printf '%s\t%s\t%s\t%s\t%s\t%s' "$fixb" "$code" "$pr" "$ph" "$hr" "$st")$'\n'
  done
  local -- stability
  stability=$(awk -v s="$stable_pairs" -v t="$total_pairs" \
    'BEGIN{printf "%.3f", (t>0)?s/t:1}')

  # Write TSV (sorted by fixture then code).
  { printf 'fixture\tcode\truns\thits\thitrate\tstable\n'
    [[ -n $rows ]] && printf '%s' "$rows" | sort ||:
  } > "$tsv"

  # Per-rule recall table (sorted by code).
  local -- rule_table='' c hit tot rr
  while IFS= read -r c; do
    [[ -n $c ]] || continue
    hit=${CODE_HIT[$c]:-0}; tot=${CODE_TOT[$c]}
    rr=$(awk -v h="$hit" -v t="$tot" 'BEGIN{printf "%.3f", (t>0)?h/t:0}')
    rule_table+=$(printf '| %s | %s | %s | %s |' "$c" "$hit" "$tot" "$rr")$'\n'
  done < <(printf '%s\n' "${!CODE_TOT[@]}" | sort)

  # Clean-fixture false-positive rate.
  local -- clean_rate
  clean_rate=$(awk -v fp="$CLEAN_FP" -v n="$CLEAN_RUNS" \
    'BEGIN{printf "%.3f", (n>0)?fp/n:0}')

  # Write markdown report.
  cat > "$md" <<MD
<!-- SPDX-License-Identifier: GPL-3.0-or-later -->
# BCS Check Accuracy Report

| Field | Value |
|-------|-------|
| Generated | $ts |
| Model | \`$MODEL\` |
| Effort | \`$EFFORT\` |
| Runs per fixture | $RUNS |
| Conclusive fixture-runs | $SCORED |
| Inconclusive (empty/timeout) | $INCONCLUSIVE |

## Aggregate

| Metric | Value |
|--------|-------|
| True positives  (TP) | $TP |
| False positives (FP) | $FP |
| False negatives (FN) | $FN |
| **Precision** TP/(TP+FP) | **$precision** |
| **Recall** TP/(TP+FN) | **$recall** |
| **F1** | **$f1** |

> On violation fixtures, FP includes extra findings that may be genuine
> secondary issues. The clean-fixture rate below is the trustworthy
> false-positive signal; recall is the trustworthy detection signal.

## False positives on clean fixtures

| Metric | Value |
|--------|-------|
| Spurious findings on clean fixtures | $CLEAN_FP |
| Clean fixture-runs | $CLEAN_RUNS |
| Avg spurious findings per clean run | $clean_rate |

## Stability (run-to-run determinism)

| Metric | Value |
|--------|-------|
| Expected (fixture,code) pairs | $total_pairs |
| Deterministic pairs (hit-rate 0.0 or 1.0) | $stable_pairs |
| **Stability score** | **$stability** |

A stability score below 1.0 means at least one expected rule was reported on
some runs and missed on others — the non-determinism this report quantifies.
Per-pair hit-rates are in \`${tsv##*/}\`.

## Per-rule recall

| Code | Hits | Runs | Recall |
|------|------|------|--------|
$rule_table
MD

  success "Wrote $md"
  success "Wrote $tsv"
  # Console one-liner.
  printf '%sprecision=%s recall=%s F1=%s stability=%s clean-FP/run=%s%s\n' \
    "$BOLD" "$precision" "$recall" "$f1" "$stability" "$clean_rate" "$NC" >&2
}

main "$@"
#fin
