#!/bin/bash

#
# Demonstrate tests that all succeed (this is fails.sh with fixes)
#

. ../xtest_setup

shtest::parse "./my_funcs" || shtest::fatal "parse failed"

# source files we're testing
. "./my_funcs"

xtest::group1::commands() {
  local var='' othervar='' avar=() aref=("item 1" "item 2")

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
}

xtest::group2::files() {
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

xtest::run_tests "Good Test Results" "$@"
