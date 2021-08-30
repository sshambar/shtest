#!/bin/bash

xtest::err() {
  echo >&2 "$*"
}

. ../shtest_setup

xtest::do_badcall() {
  echo "Attempt to use shtest::check_array without args... (script exits)"
  echo
  shtest::check_array
}

xtest::do_unbound() {
  echo "Use 'shtest::strict'"
  shtest::strict

  echo "Use unbound variable in subshell..."
  echo

  (echo $unbound_var) || :

  echo
  echo "Use unbound variable in main script... (bash exits)"
  echo
  echo $unbound_var
}

xtest::do_whitelist() {
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
  shtest::whitelist xtest::do_whitelist
  false
  shtest::check_result F2 f "false with whitelist"
  shtest::cleanup
  echo
  exit 0
}

xtest::do_dup() {
  echo "Use the same test id 'T4' multiple times"

  local var='a value'
  shtest::check_result T4 t "first test"
  shtest::check_var T4 "duplicate test"
}

xtest::usage() {
  xtest::err "Display crash errors from various circumstances"
  xtest::err "Usage: ${0##*/} <mode>"
  xtest::err "  <mode> one of:"
  xtest::err "    badcall - show shtest function parameter error"
  xtest::err "    unbound - show unbound error in strict mode"
  xtest::err "    whitelist - show whitelist in strict mode (with backtrace)"
  xtest::err "    dup - demonstrate catching duplicate test ids"
  exit 1
}

xtest::main() { # <args>...
  local mode

  for mode in "$@"; do
    case $mode in
      badcall) xtest::do_badcall ;;
      unbound) xtest::do_unbound ;;
      whitelist) xtest::do_whitelist ;;
      dup) xtest::do_dup ;;
      *) xtest::usage ;;
    esac
  done

  xtest::usage
}

xtest::main "$@"
