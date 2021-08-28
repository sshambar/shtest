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
* Thoroughly tested (the test suite library has a test suite :)

## Built-in Tests

* last command return code
* variable values
* bash array values
* file contents
* multiple file contents
