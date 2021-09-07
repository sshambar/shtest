#!/bin/bash

ctest::err() {
  echo >&2 "$*"
}

. ../shtest_setup

ctest::do_badcall() {
  echo "Attempt to use shtest::check_array without args... (script exits)"
  echo
  shtest::check_array
}

ctest::do_unbound() {
  echo "Use 'shtest::strict'"
  shtest::strict

  echo "Use unbound variable in subshell..."
  echo

  (echo "$unbound_var") || :

  echo
  echo "Use unbound variable in main script... (bash exits)"
  echo
  echo "$unbound_var"
}

ctest::do_whitelist() {
  echo "Use 'shtest::strict trace' (ie. showing backtrace)"
  shtest::strict trace

  echo "Command fails in strict mode..."
  echo
  false
  shtest::check_result F1 f "false without whitelist"

  # show test description when OK
  shtest::verbose

  echo
  echo "Whitelist function calling failing command, and retry..."
  echo
  # whitelist this function so commands can fail here...
  shtest::whitelist ctest::do_whitelist
  false
  shtest::check_result F2 f "false with whitelist"
  shtest::cleanup
  echo
  exit 0
}

ctest::do_dup() {
  echo "Use the same test id 'T4' multiple times"

  :
  shtest::check_result T4 t "first test"
  false
  shtest::check_result T4 f "duplicate test"
}

ctest::usage() {
  ctest::err "Display crash errors from various circumstances"
  ctest::err "Usage: ${0##*/} <mode>"
  ctest::err "  <mode> one of:"
  ctest::err "    badcall - show shtest function parameter error"
  ctest::err "    unbound - show unbound error in strict mode"
  ctest::err "    whitelist - show whitelist in strict mode (with backtrace)"
  ctest::err "    dup - demonstrate catching duplicate test ids"
  exit 1
}

main() { # <args>...
  local mode

  for mode in "$@"; do
    case $mode in
      badcall) ctest::do_badcall ;;
      unbound) ctest::do_unbound ;;
      whitelist) ctest::do_whitelist ;;
      dup) ctest::do_dup ;;
      *) ctest::usage ;;
    esac
  done

  ctest::usage
}

main "$@"
