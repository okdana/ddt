# ddt Makefile

# REQUIRES GNU MAKE

# Don't print any command text, ever
.SILENT: 

# We use these in `make revision`
TODAY           := $(shell date +'%Y-%m-%d')
GIT_STATUS      := $(shell git status --porcelain 2>&1)
GIT_LAST_TAG    := $(shell git tag -l 'rev/*' | tail -1 | grep -o '[0-9]*')
GIT_NEXT_TAG    := $(shell expr $(GIT_LAST_TAG) + 1)
GIT_REVISION    := $(shell git rev-parse --short=6 HEAD 2>&1)
REV_TAG         := $(shell test '$(MAKECMDGOALS)' = 'release' && echo 'release' || echo 'custom')

# This is the final revision string
DDT_REVISION    := $(GIT_NEXT_TAG) ($(TODAY), $(GIT_REVISION)-$(REV_TAG))

# This is used for `ronn`-based conditionals
RONN            := $(shell which ronn 2> /dev/null | grep -v 'not found')

# This checks to see if the command-line target is equal to the target we're currently in;
# if it is, whatever follows will be run. If it's not, it will just return true.
CALLED_SELF_AND  = $(shell test '$(MAKECMDGOALS)' = '$@' && echo ' true && ' || echo ' true ')


default: help


-include ./config.mk

# Ensures `./configure` has been run
config.mk:
	echo 'Please run `./configure` prior to running `make`.'
	false


# Usage help
help:
	echo 'Valid targets (requires GNU make):'
	echo '  build      —  Builds ddt locally'
	echo '  install    —  Builds and installs ddt'
	echo '  uninstall  —  Un-installs ddt'
	echo '  clean      —  Purges out dir'
	echo '  distclean  —  Purges out dir and config.mk'
	echo '  lint       —  Runs lint against ddt source'
	echo '  man        —  Builds man pages with ronn'
	echo '  release    —  Builds and prepares for release'

# Debug: Print vars
vars:
	echo 'TODAY:        $(TODAY)'
	echo 'GIT_STATUS:   $(GIT_STATUS)'
	echo 'GIT_LAST_TAG: $(GIT_LAST_TAG)'
	echo 'GIT_NEXT_TAG: $(GIT_NEXT_TAG)'
	echo 'GIT_REVISION: $(GIT_REVISION)'
	echo 'REV_TAG:      $(REV_TAG)'

# Helper: Checks for root privileges
privileges:
	test $(shell id -u) = 0 || echo 'Root privileges needed (try with sudo?).'
	test $(shell id -u) = 0

# Helper: Checks for clean repository state
repo_state:
	test -n '$(GIT_STATUS)' && echo 'Repository state is unclean.' && git status || true
	test -n '$(GIT_STATUS)' || echo 'Repository state is clean.'
	test -z '$(GIT_STATUS)'

# Alias for local_revision
revision: local_revision

# Updates the local revision number in /out
local_revision: $(CURDIR)/out/bin/ddt
	grep -q 'REVISION=.*# Auto-updated' 'out/bin/ddt' || echo "Can't update revision."
	grep -q 'REVISION=.*# Auto-updated' 'out/bin/ddt'
	#
	echo "Updating local revision to: $(DDT_REVISION)"
	sed -i.bak 's/^REVISION=.*# Auto-updated/REVISION="$(DDT_REVISION)" # Auto-updated/;' 'out/bin/ddt' && rm 'out/bin/ddt.bak'

# Updates the revision number in source
dev_revision:
	grep -q 'REVISION=.*# Auto-updated' 'source/ddt' || echo "Can't update revision."
	grep -q 'REVISION=.*# Auto-updated' 'source/ddt'
	#
	echo "Updating source revision to: $(DDT_REVISION)"
	sed -i.bak 's/^REVISION=.*# Auto-updated/REVISION="$(DDT_REVISION)" # Auto-updated/;' 'source/ddt' && rm 'source/ddt.bak'

# Ensures build has been run
out/bin/ddt: build

# Lints, merges/copies source files into /out
build: lint man_optional
	mkdir -p 'out/bin'
	mkdir -p 'out/man'
	#
	# This is a silly but functional way to merge all source files into a single script
	cp 'source/ddt' 'out/bin/ddt'
	sed -i.bak '/^source .*variables/r source/variables' 'out/bin/ddt'
	sed -i.bak '/^source .*functions/r source/functions' 'out/bin/ddt'
	sed -i.bak '/^source .*getopt/r source/getopt' 'out/bin/ddt'
	sed -i.bak '/^source /d;' 'out/bin/ddt'
	rm -f 'out/bin/'*.bak
	chmod a+x 'out/bin/ddt'
	#
	# If the man page isn't there, that's fine
	cp 'source/man/ddt.1' 'out/man/ddt.1' 2> /dev/null || echo 'Man page is missing; skipping.'
	#
	# Make sure /out is writeable by the group, in case we've used sudo
	# (This is so you can `make clean` without needing sudo again)
	chmod -R g+w 'out'
	#
	# Update local revision
	$(MAKE) --no-print-directory local_revision
	#
	echo 'Built into $(CURDIR)/out.'
	$(CALLED_SELF_AND) echo 'Run `make man` to build man page, or `./configure && make install` to install.'


# Builds roff file(s) into man page(s) with `ronn` (dies if `ronn` is missing)
man:
	test -n "$(RONN)" || echo '`ronn` is required to build man page(s); try `gem install ronn`.'
	test -n "$(RONN)"
	#
	echo 'Building man page(s)...'
	ronn -r --date=$(shell git log -1 --pretty='format:%ci' 'source/man/ddt.1.ronn' | cut -d ' ' -f 1) 'source/man/ddt.1.ronn'

# Builds roff file(s) into man page(s) with `ronn` (moves on if `ronn` is missing)
man_optional:
	test -n "$(RONN)" || echo '`ronn` is needed to build man page(s); Skipping this step...'
	#
	test -z "$(RONN)" || echo 'Building man page(s)...'
	test -z "$(RONN)" || ronn -r --date=$(shell git log -1 --date='short' --pretty='format:%cd' 'source/man/ddt.1.ronn') 'source/man/ddt.1.ronn'


# Updates local version and installs /out files to the appropriate locations
install: config.mk privileges build
	cp 'out/bin/ddt' "$(PREFIX)/bin/ddt"
	#
	# If the man page isn't there, that's fine
	test -e 'out/man/ddt.1' && mkdir -p "$(MANPREFIX)/man1" && cp 'out/man/ddt.1' "$(MANPREFIX)/man1/ddt.1" || true
	test -e 'out/man/ddt.1' || echo 'Man page is missing; skipping.'
	#
	echo 'Successfully installed to $(PREFIX)/bin/ddt.'

# Un-installs `ddt` from the system
uninstall: config.mk privileges
	rm -f "$(MANPREFIX)/man1/ddt.1"
	rm "$(PREFIX)/bin/ddt" && echo 'Succesfully un-installed.' || true


# Removes /out directory
clean:
	rm -rf 'out'

# Removes /out directory and config.mk
distclean: clean
	rm -f 'config.mk'


# Runs shell syntax check (development use)
lint:
	echo 'Checking for syntax errors...'
	( for f in ddt variables functions getopt; do bash -n "$(CURDIR)/source/$$f" || exit 1; done )

# Aliases for test
tests: test
unit:  test

# Runs unit tests
test: $(CURDIR)/out/bin/ddt
	echo 'Running unit tests on $(shell out/bin/ddt -V)...'
	out/bin/ddt -q tests/*


# Lints, builds man page, ensures clean repo state,
# updates revision, and creates tag in git (dev use only)
release: lint build test man repo_state dev_revision
	echo hi
	false
	#sh -c 'REV="`sed "/^REVISION=/!d; s/^[^0-9]*//; s/[^0-9].*$$//;" "$(CURDIR)/source/ddt"`" ; echo "Adding revision tag rev/$$REV..." ; git tag -m "ddt revision $$REV" "rev/$$REV"'
	#echo 'Use `git push origin --tags` to update remote tags.'


.PHONY: help vars privileges repo_state revision local_revision dev_revision build install uninstall clean distclean man man_optional lint tests unit test release


