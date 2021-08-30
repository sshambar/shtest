#!/bin/bash

#
# Demonstrate tests with failures
#

xtest::err() {
  echo >&2 "$*"
}

. ../shtest_setup

shtest::parse "./my_funcs" || shtest::fatal "parse failed"

# source files we're testing
. "./my_funcs"

xtest::group1::tests() {
  local var='' env_store othervar avar=() aref=("item 1" "item X")

  shtest::save_env env_store

  shtest::title "Testing commands"

  $(exit 2)
  shtest::check_result T1 2 "'exit 2' should return 2"

  (( 2+2 == 4 ))
  shtest::check_result T2 f "a test that expects failure"

  shtest::prefix "my_command() "

  my_command -v var "wrong value"
  shtest::check_result T3 t "with -v, returns true"
  shtest::check_var T4 "a value" "\$var != 'a value'"
  shtest::check_value T5 othervar "zzz" "\$othervar == 'zzz'"
  shtest::check_array T6 avar aref "array values differs"
  unset aref; aref[0]="item 1"; aref[2]="item 2"
  shtest::check_array T7 avar aref "array indexes differ"

  my_command -v extravar "extra value"

  var=$(my_command 2>&1 "fail arg")
  shtest::check_result X1 2 "with 'fail arg', returns 2"
  var=${var//$'\n'/ } # strip newlines
  shtest::check_var X2 "command failed" "stderr contains 'command failed'"

  var=$(my_command 2>&1 "backtrace")
  shtest::prefix
  shtest::check_env G1 env_store "check environment"
}

xtest::group2::tests() {
  local var testfile="./TEST FILE" output="./TESTERR.LOG"

  shtest::title "Testing files"

  # register files
  shtest::reg_file "$output"
  shtest::reg_file "$testfile"

  var=$(shtest::reg_file)
  shtest::check_var R1 "$output"$'\n'"$testfile" "files should be registered"

  shtest::prefix "my_write: "

  rm -f "$testfile" "$output"
  my_write 2>"$output"
  shtest::check_result F1 t "returns true"
  shtest::check_reg_files F2 "mismatch content" "wrote file" "some text"
  shtest::check_reg_files F3 "file missing" "missing file"

  rm -f "$testfile" "$output"
}

xtest::usage() {
  xtest::err "Usage: ${0##*/} <options>"
  xtest::err "  <options> include:"
  xtest::err "    help - show help"
  xtest::err "    verbose - always show test descriptions"
  xtest::err "    quiet - show summary only"
  xtest::err "    strict - enable -eEu bash options"
  xtest::err "    trace - enable -eEu bash options with traceback"
  xtest::err "    +<id/pattern> - show test <id/pattern(*|?)> (may be repeated)"
  shtest::cleanup
  exit 1
}

xtest::parse_args() { # <args>...
  local arg

  for arg in "$@"; do
    case $arg in
      strict|trace)
        shtest::strict "${arg[@]/strict/}"
        ;;
      verbose)
        shtest::verbose
        ;;
      quiet)
        shtest::quiet
          ;;
      +*)
        arg=${arg#+}; [[ $arg ]] || xtest::usage
        shtest::add_focus "${arg}"
        ;;
      help)
        xtest::usage
        ;;
      *)
        xtest::err "Unknown option: ${arg}"
        xtest::usage
        ;;
    esac
  done
}

xtest::main() { # <args>...
  xtest::parse_args "$@"

  xtest::group1::tests

  xtest::group2::tests

  shtest::summary_report || {
    shtest::log "To display one test, use \"+<id/pattern>\" (repeatable)"
  }
  return 0
}

xtest::main "$@"
shtest::cleanup
