# ddt

**ddt** is a unit-testing tool for shell scripts and other command-line applications which is based on (and compatible with) [roundup](https://github.com/bmizerany/roundup). The main improvements over roundup are GNU-style argument handling, better file handling, better error handling, more options, and (IMO) nicer output. I feel that it's also easier to maintain, since it is written for bash 4+, although this does of course make it less portable.

## screen-shot

![screen-shot](https://raw.github.com/okdana/ddt/master/documentation/screenshot.png)

## explanation

**ddt** works with roundup(5)-style test plans, which are simply shell scripts containing one or more function definitions, or tests. When pointed to a test plan, **ddt** sources it in a sub-shell and calls each function/test. If the function returns with `0` (the standard return code for success), it is considered a passed test. Otherwise, it is considered failed, and **ddt** will optionally (with `-v`) show you a trace indicating why.

Example:

```bash
# This test simply executes `myapp` with no arguments, and pipes its output to
# `grep` to ensure it displays usage information as expected. If the information
# is there, `grep` will return with 0, and the test will pass.
returns_usage_with_no_arguments() {
	myapp 2>&1 | grep -q 'usage:'
}
```

## todo

- Add basic argument handling for systems without extended getopt.
- Add FIFO support.
- Add support for specifying directories in addition to individual files.
- Figure out weird recursive testing problems.
- Improve function definition syntax parsing.


