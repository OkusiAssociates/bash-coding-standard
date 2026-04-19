#!/bin/bash
# obs sender
set -euo pipefail
shopt -s inherit_errexit

#shellcheck source=obs-common
source obs-common
#shellcheck source=obs-receive
source obs-receive
#shellcheck source=../../get_pubkey/is-authorized-pubkey
source is-authorized-pubkey

source urlencode
source urldecode

declare -i i=50
declare -i SLEEP=OBS_WINDOW

declare -- mac pubkey string send='' receive=''

declare -- user="${1:-sysadmin}"

mac=$(get_mac) # dies if not found
pubkey=$(get_pubkey "$user") # dies if not found

string="$(get_mac)|$(get_pubkey "$user")"
declare -p mac pubkey string

declare -- r_mac

while ((i--)); do
  >&2 echo "$i"
  send=$(obs_send "$string")
  send=$(urlencode "$send")

  #...
  sleep $((RANDOM % SLEEP))
  #...

  send=$(urldecode "$send")
  receive=$(obs_receive "$send" ||:)
  [[ $string == "$receive" ]] || { >&2 echo "error: $SLEEP ${string@Q} != ${receive@Q}"; continue; }

  # extract mac and pubkey from received payload
  r_mac=${receive%%|*}
  is_approved_mac "$r_mac" || { >&2 echo "error: unapproved mac ${r_mac@Q}"; break; }

#  is_authorized_pubkey "$receive" || { >&2 echo "error: pubkey not in authorized_keys ${AUTHORIZED_KEYS_FILE@Q}"; break; }
done

#fin
