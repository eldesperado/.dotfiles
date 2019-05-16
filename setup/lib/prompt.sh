#!/usr/local/env bash

# Logging functions
info () {
  printf "  [ \033[00;34m..\033[0m ] %s\n" "$1"
}

user () {
  printf "\r  [ \033[0;33m?\033[0m ] %s" "$1"
}

success () {
  printf "\r\033[2K  [ \033[00;32mOK\033[0m ] %s\n" "$1"
}

fail () {
  printf "\r\033[2K  [\033[0;31mFAIL\033[0m] %s\n" "$1"
  echo
  exit
}

# Prompt
yes_no_prompt () {
  local result
  while true; do
    user "$1 [Y/n]: "
    read -rn 1 input

    if [[ $input = Y ]]; then
      echo ""
      result=0
      break
    elif [[ $input = n ]]; then
      echo ""
      result=1
      break
    else
      echo ""
      info "Invalid input ($input). Use Y or n."
      echo ""
    fi
  done

  return $result
}