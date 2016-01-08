# ddt

**ddt** is a unit- and functional-testing tool for shell scripts and other
command-line applications, in the vein of (but no longer compatible with) Blake
Mizerany's [roundup](https://github.com/bmizerany/roundup).

![ddt screen-shot](https://raw.githubusercontent.com/okdana/ddt/master/screenshot.png)

## Installation

Simply check out the repository and run `make install`.

If you're on OS X, you'll also need to install bash 4 and GNU `getopt`:

```bash
% brew install bash
% brew install gnu-getopt
% brew link --force gnu-getopt
```

## Usage

**ddt** works with *test plans*, which are simply shell scripts containing one
or more function definitions referred to as *tests*. When pointed to a test
plan, **ddt** sources it in a sub-shell and runs each test. If the test function
returns with `0` (the standard return code for success), it is considered to
have passed; otherwise, it is considered to have failed, and **ddt** will show a
trace indicating why.

An example test plan follows:

```bash
# plan:describe() is a special `ddt` function which gives the plan a name
plan:describe 'my test plan'

# Functions prefixed by `test:` naturally represent individual tests. This
# particular test ensures that the output of `myapp` contains `mystring`
test:prints_mystring() {
	myapp 2>&1 | grep -F 'mystring'
}
```

To run this test plan, simply point **ddt** to it:

```bash
% ddt mytest.ddtt
```

(By convention, **ddt** test plans use the extension `ddtt`, and **ddt** will
look for files with this extension when passed a directory on the command line.)

## Licence

MIT.

