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
  echo
  echo "In subshell: use shtest::strict, then unbound ref:"
  echo

  (shtest::strict
   local y=$unbound_var)

  echo
  echo "In subshell: use shtest::strict trace, then unbound ref:"
  echo

  (shtest::strict trace
   local y=$unbound_var)

  echo
  echo "Main script: shtest::strict, In subshell: unbound ref"
  echo "   (note no traceback, trap not set with shtest::strict)"
  echo

  shtest::strict trace
  (local y=$unbound_var) || :

  echo
  echo "Main script: use shtest::strict, then unbound ref (bash exits)"
  echo

  shtest::strict trace
  local y=$unbound_var

  ctest::err "ERROR: should not reach here!"
}

ctest::do_strict() {
  echo
  echo "Main strict: use shtest::strict"
  echo

  shtest::strict

  echo "Create failure"
  echo

  false

  echo
  echo "Main strict: use shtest::trace"

  shtest::trace

  echo
  echo "Create failure (with traceback)"
  echo

  false

  echo
  echo "In subshell, create failure"

  shtest::strict

  (false; :)

  shtest::strict off

  return 0
}

ctest::do_whitelist() {

  echo
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

  shtest::reset_state
  echo
}

ctest::do_dup() {
  echo "Use the same test id 'T4' multiple times"

  :
  shtest::check_result T4 t "first test"
  false
  shtest::check_result T4 f "duplicate test"
}

ctest::onexit_func() {
  [[ -e ${TEST_TEMP-} ]] && rm -f "${TEST_TEMP}"
}

ctest::test_file() { # <file>
  if [[ -e "$1" ]]; then
    echo " - file exists"
  else
    echo " - file not found!"
  fi
  return 0
}

ctest::do_onexit() {
  TEST_TEMP=$(mktemp -u -t "crash-test-XXXXXX") || {
    ctest::err "mktemp failed!"; exit 0; }

  echo "Create a file:"
  echo -n >>"${TEST_TEMP}"
  ctest::test_file "${TEST_TEMP}"
  echo "In subshell: shtest::add_onexit <onexit func>"
  (shtest::add_onexit ctest::onexit_func)
  echo "Check if file was removed by <onexit func>:"
  ctest::test_file "${TEST_TEMP}"

  echo
  echo -n >>"${TEST_TEMP}"
  echo "Again, but add shtest::cleanup"
  (shtest::add_onexit ctest::onexit_func
   shtest::cleanup)
  echo "Check file should remain (<onexit> not called):"
  ctest::test_file "${TEST_TEMP}"

  rm -f "${TEST_TEMP}"
}

ctest::usage() {
  ctest::err "Display crash errors from various circumstances"
  ctest::err "Usage: ${0##*/} <mode>"
  ctest::err "  <mode> one of:"
  ctest::err "    badcall - show shtest function parameter error"
  ctest::err "    unbound - show unbound error in strict mode"
  ctest::err "    whitelist - show whitelist in strict mode (with backtrace)"
  ctest::err "    dup - demonstrate catching duplicate test ids"
  ctest::err "    onexit - use an onexit handler"
  ctest::err "    strict - show strict failures"
  exit 1
}

main() { # <args>...
  local mode='help'

  for mode in "$@"; do
    case $mode in
      badcall)
        ctest::do_badcall ;;
      unbound)
        ctest::do_unbound ;;
      whitelist)
        ctest::do_whitelist ;;
      dup)
        ctest::do_dup ;;
      onexit)
        ctest::do_onexit ;;
      strict)
        ctest::do_strict ;;
      *)
        mode=help
        break ;;
    esac
  done

  [[ ${mode} == help ]] && ctest::usage
  shtest::cleanup
  return 0
}

main "$@"
