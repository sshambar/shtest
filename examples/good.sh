#!/bin/bash

#
# Demonstrate tests that all succeed (this is fails.sh with fixes)
#

xtest::err() {
  echo >&2 "$*"
}

. ../shtest_setup

shtest::parse "./my_funcs" || shtest::fatal "parse failed"

# source files we're testing
. "./my_funcs"

# save typing...
shopt -s expand_aliases
alias xtest=shtest::check_result
alias vtest=shtest::check_var
alias atest=shtest::check_array

xtest::group1::tests() {
  local var='' env_store othervar='' avar=() aref=("item 1" "item 2")

  shtest::save_env env_store

  shtest::title "Testing commands"

  $(exit 2)
  xtest T1 2 "'exit 2' should return 2"

  (( 0 == 4 ))
  xtest T2 f "a test that fails"

  shtest::prefix "my_command() "

  my_command -v var "a value"
  xtest T3 t "with -v, returns true"
  vtest T4 "a value" "\$var == 'a value'"
  shtest::check_value T5 othervar "zzz" "\$othervar == 'zzz'"
  atest T6 avar aref "array avar matches aref"

  shtest::whitelist "my_command"
  local unset_var=''
  var=$(my_command 2>&1 "fail arg")
  xtest X1 1 "with 'fail arg', returns 1"
  vtest X2 "command failed" "stderr contains 'command failed'"
  unset unset_var

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
  vtest R1 "$output"$'\n'"$testfile" "files should be registered"

  shtest::prefix "my_write: "

  rm -f "$testfile" "$output"
  my_write 2>"$output" "$testfile"
  xtest F1 t "returns true"
  shtest::check_reg_files F2 "creates file, logs message" \
                          "wrote file" "file content"

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
        # whitelist the main driver functions
        shtest::global_whitelist "xtest::group*"
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
