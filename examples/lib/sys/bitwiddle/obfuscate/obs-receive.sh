#!/bin/bash

[[ -v OBS_MARKER ]] || source obs-common

obs_receive() {
  # --- receiver (within OBS_WINDOW seconds) ---
  local -i twiddle=$((EPOCHSECONDS / OBS_WINDOW % 255 + 1))
  local -- tbase
  tbase=$(printf '%s' "$1" | rev)

  # Validate via hex output (null-safe) then decode with correct key
  local -- marker_hex trial result
  marker_hex=$(printf '%s' "$OBS_MARKER" | od -An -tx1 -v | tr -d ' \n')

  trial=$(printf '%s' "$tbase" | base64 -d | bitwiddle -x - xor "$twiddle" | tr -d ' \n')
  if [[ $trial != "${marker_hex}"* ]]; then
    twiddle=$(((EPOCHSECONDS / OBS_WINDOW - 1) % 255 + 1))
    #>&2 echo 'retry'
    trial=$(printf '%s' "$tbase" | base64 -d | bitwiddle -x - xor "$twiddle" | tr -d ' \n')
  fi

  if [[ $trial == "${marker_hex}"* ]]; then
    # Correct key — decode (original text is printable, no nulls)
    result=$(printf '%s' "$tbase" | base64 -d | bitwiddle - xor "$twiddle")
    printf '%s' "${result#"$OBS_MARKER"}"
    return 0
  fi

  >&2 echo "${FUNCNAME[0]}: Invalid Marker"
  return 1
}
declare -fx obs_receive

#fin
