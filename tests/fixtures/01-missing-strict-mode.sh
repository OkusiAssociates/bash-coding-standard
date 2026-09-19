#!/usr/bin/env bash

main() {
  local -- name=${1:-world}
  echo "hello, $name"
}

main "$@"
#fin
