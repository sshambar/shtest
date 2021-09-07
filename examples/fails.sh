#!/bin/bash

#
# Demonstrate tests with failures
#

. ../xtest_setup

shtest::parse "./my_funcs" || shtest::fatal "parse failed"

# source files we're testing
. "./my_funcs"

xtest::group1::commands() {
  local var='' othervar avar=() aref=("item 1" "item X")

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
}

xtest::group2::files() {
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

xtest::run_tests "" "$@"
