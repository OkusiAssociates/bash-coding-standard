#!/bin/bash

#shellcheck source=../bitwiddle/bitwiddle
source bitwiddle
#shellcheck source=../get_mac/get-mac
source get-mac
#shellcheck source=../get_pubkey/get-pubkey
source get-pubkey

# common obs settings
declare -rx OBS_MARKER=${OBS_MARKER:-'OK:'}
declare -irx OBS_WINDOW=${OBS_WINDOW:-3}

obs_send() {
  printf '%s' "${OBS_MARKER}${1}" \
      | bitwiddle - xor "$((EPOCHSECONDS / OBS_WINDOW % 255 + 1))" \
      | base64 --wrap=0 | rev
}
declare -fx obs_send


#fin
