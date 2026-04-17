#!/bin/bash
# Accuracy testing for bcs check across models and effort levels.
set -euo pipefail
shopt -s inherit_errexit extglob

declare -r VERSION=1.0.0
#shellcheck disable=SC2155
declare -r SCRIPT_PATH=$(realpath -- "$0")
declare -r SCRIPT_DIR=${SCRIPT_PATH%/*} SCRIPT_NAME=${SCRIPT_PATH##*/}

declare -a BASH_SCRIPTS=( md2ansi cln which "$SCRIPT_PATH")
declare -- script scriptname scriptdir

# Models to exercise
declare -a LLM_MODELS=(
  claude-code
  claude-sonnet-4-6
  #claude-opus-4-6
  #gemini-2.5-pro
  gpt-5.4
  minimax-m2.7:cloud
  glm-5.1:cloud
  qwen3-coder:480b-cloud
)

# Efforts; low ommitted because of consistent poor quality with current models
declare -a EFFORTS=(
  #low
  medium
  high
  max
)
declare -- model effort modelname

if (($#)); then
  if [[ $1 == @(-V|--version) ]]; then
    printf '%s %s\n' "$SCRIPT_NAME" "$VERSION"
  elif [[ $1 == @(-h|--help) ]]; then
    cat <<HELP
$SCRIPT_NAME $VERSION - Accuracy testing for bcs check across models and effort levels

Will test these scripts:

  ${BASH_SCRIPTS[@]@Q}

with these models:

  ${LLM_MODELS[@]@Q}

and these efforts:

  ${EFFORTS[@]@Q}

Options:
  -V, --version  Show version
  -h, --help     This help
HELP
  else
    >&2 printf '%s: ✗ %s\n' "$SCRIPT_NAME" "Invalid argument ${1@Q}"
    exit 1
  fi
  exit 0
fi

cd "$SCRIPT_DIR" # anchor to script's dir path

declare -- output_to

declare -i start_time=$EPOCHSECONDS

for script in "${BASH_SCRIPTS[@]}"; do
  script=$(realpath -- "$script")
  scriptname=${script##*/}
  scriptdir=${script%/*}

  cd "$scriptdir"

  for model in "${LLM_MODELS[@]}"; do
    # Sanitize for filename: collapse ':' and '/' to '_'.
    modelname=${model//[:\/]/-}
    for effort in "${EFFORTS[@]}"; do
      output_to="$SCRIPT_DIR"/bcs-check_"$scriptname"_"$modelname"_"$effort".md
      >&2 echo "bcs check --model $model --effort $effort ${script@Q} &>${output_to@Q}"
      if [[ -f $output_to ]]; then
        >&2 echo "    ${output_to@Q} already exists; skipping"
        continue
      fi

      bcs check --model "$model" --effort "$effort" "$script" &>"$output_to" ||:

    done
  done

done

TZ=UTC0 printf '%(%T)T\n' $((EPOCHSECONDS-start_time))

#fin
