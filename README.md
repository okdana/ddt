# ddt

**ddt** is a unit-testing tool for shell scripts and other command-line applications which is based on (and compatible with) [roundup](https://github.com/bmizerany/roundup). The main improvements over roundup are GNU-style argument handling, better file handling, better error handling, more options, and (IMO) nicer output. I feel that it's also easier to maintain, since it is written for bash 4+, although this does of course make it less portable.

## screen-shot

![screen-shot](https://raw.github.com/okdana/ddt/master/documentation/screenshot.png)

## todo

- [ ] Add basic argument handling for systems without extended getopt.
- [ ] Add FIFO support.
- [ ] Figure out weird recursive testing problems.
- [ ] Improve function definition syntax parsing.

