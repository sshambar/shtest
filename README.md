# [shtest](https://github.com/sshambar/shtest)
*Full featured testing suite library in a single bash script*

## Description

shtest is a library of bash functions that make creating a test suite
extremely easy.

Source the 'shtest_setup' file in a bash script, and with a few
configuration functions you have a full test suite that handles
all the complexity of testing return values, variables, arrays and
file contents, keeping track of test results to create a summary
report.

## Main Features

* Extremely fast and simple
* Supports various levels of feedback, from verbose to summary only
* Makes it easy to display output from only selected tests
* Includes tests of environment to catch stray variables
* Full support for set -e/-u tests, including backtrace when
  an error is encountered.
* Section titles, and test name grouping
* Very limited "name pollution" making it easy to integrate into
  existing projects
* Logging that's independent of main script's stdout/stderr
* Bash 3.2+ compatibility
* Thoroughly tested (the test suite library has a test suite :)

## Built-in Tests

* last command return code
* variable values
* bash array values
* file contents
* multiple file contents

## Documentation

Full documentation for all public functions are in the comments
at the top of the shtest_setup file.

## Basic Instructions

Copy shtest_setup to your project, then source it somewhere in
your test program

	. shtest_setup

Set some options

	shtest::verbose
	shtest::strict trace
	shtest::global_whitelist "my_test_func_*"

Perform a parse test on your functions, and then source them

	shtest::parse "my_funcs" || shtest::fatal "parse failed"
	. my_funcs

Snapshot local variables in a variable (here $myenv)

	shtest::save_env myenv

Display some titles, set a logging prefix

	shtest::title "Command Tests"
	shtest::prefix "my_command() "

Run some tests

	my_command -v var "a value" 2>outfile
	shtest::check_result T1 t "with -v, returns true"
	shtest::check_var T2 "a value" "\$var == 'a value'"
	shtest::check_value T3 othervar "zzz" "\$othervar == 'zzz'"
	shtest::check_array T4 avar aref "array avar matches aref"
	shtest::check_file T5 "outfile" "command err" "command writes stderr"

	shtest::whitelist "my_command"
	var=$(my_command 2>&1 "fail arg")
	shtest::check_result T6 "with 'fail arg', returns 2"
	shtest::check_var T7 "command failed" "stderr contains 'command failed'"
	shtest::last_check_ok && more_tests

Check for "leaked" variables

	shtest::check_env ENV myenv "check environment"

Display summary report

	shtest::summary_report

Cleanup and exit

	shtest::cleanup
	exit

 -OR-

Reset counters for a new run

	shtest::reset

Several examples are in examples/

## Test suite for the library

A test suite for shtest is in test/, just run 'shtest-test'

## Test suite in a box: xtest_setup

A simple wrapper for shtest that handles setting options from the
command line, and easy test isolation, is available in xtest_setup.
See that file for instructions, and good.sh and fails.sh in
examples use it for demo purposes.

## Useful Tips

* To use shtest_setup, just copy it to your project and source it.

* All output is printed to stderr using file descriptor 88, so it's best
  not to use that descriptor in your tests.

* All test <id>'s must be unique... duplicates cause the test to exit.

* Aliases are useful to ease typing, eg:

	shopt -s expand_aliases
	alias xtest=shtest::check_result
	xtest T1 t "should return true"

* Strict mode can be tricky to use correctly, make sure you whitelist
  any parent functions that test failures with shtest::global_whitelist, eg:

	shtest::global_whitelist "my_test_func_*"
	my_test_func_1() {
	  false
	  shtest::check_result T1 f "should fail"
	}

* shtest::whitelist can be used for a "one-shot" whitelist.

* shtest::strict trace enables backtraces at failure points.

* shtest::add_focus is very useful to isolate just the output
  of a failing test (or test group)

* Strict mode exits when unbound variables are referenced, so make
  sure you don't "2>/dev/null" functions that might cause them, or
  you may miss the full description (shtest will still display
  backtrace to help though).

* File registrations make it easy to test multiple output streams, eg:

	shtest::reg_file "my_stdout"
	shtest::reg_file "my_stderr"
	my_func >"my_stdout" 2>"my_stderr"
	shtest::check_reg_files E1 "testing output" "output text" "err text"
