# ddt Makefile

# Don't print any command text, ever
.SILENT: 

default: build

# Ensure `./configure` has been run
config.mk:
	echo 'Please run `./configure` prior to running `make`.'
	false

-include ./config.mk

# Merges/copies source files into /out
build: config.mk
	mkdir -p "$(CURDIR)/out/bin"
	mkdir -p "$(CURDIR)/out/man"
	
	# This is a silly but functional way to merge all source files into a single script
	cp "$(CURDIR)/source/ddt" "$(CURDIR)/out/bin/ddt"
	sed -i.bak '/^source .*variables/r $(CURDIR)/source/variables' "$(CURDIR)/out/bin/ddt"
	sed -i.bak '/^source .*functions/r $(CURDIR)/source/functions' "$(CURDIR)/out/bin/ddt"
	sed -i.bak '/^source .*getopt/r $(CURDIR)/source/getopt' "$(CURDIR)/out/bin/ddt"
	sed -i.bak '/^source /d;' "$(CURDIR)/out/bin/ddt"
	rm -f "$(CURDIR)/out/bin/"*.bak
	chmod a+x "$(CURDIR)/out/bin/ddt"
	
	cp "$(CURDIR)/source/man/ddt.1" "$(CURDIR)/out/man/ddt.1"
	
	echo 'Built into $(CURDIR)/out.'

# Checks for root privileges
privileges:
	test $(shell id -u) = 0 || echo 'Root privileges needed.'
	test $(shell id -u) = 0

# Installs /out files to the appropriate locations
install: build
	mkdir -p "$(MANPREFIX)/man1"
	cp "$(CURDIR)/out/bin/ddt" "$(PREFIX)/bin/ddt"
	cp "$(CURDIR)/out/man/ddt.1" "$(MANPREFIX)/man1/ddt.1"
	
	echo 'Successfully installed to $(PREFIX)/bin.'

# Un-installs `ddt` from the system
uninstall:
	rm -f "$(PREFIX)/bin/ddt"
	rm -f "$(MANPREFIX)/man1/ddt.1"
	
	echo 'Succesfully un-installed.'

# Removes /out directory
clean:
	rm -rf "$(CURDIR)/out"

# Removes /out directory and config.mk
distclean: clean
	rm -f "$(CURDIR)/config.mk"

# Builds roff file(s) with `ronn` (development use)
man:
	echo 'Building manual...'
	which ronn > /dev/null 2>&1 || echo '`ronn` is required but not installed; try `gem install ronn`.'
	which ronn > /dev/null 2>&1
	
	ronn -r --date=$(shell git log -1 --pretty='format:%ci' "$(CURDIR)/source/man/ddt.1.ronn" | cut -d ' ' -f 1) "$(CURDIR)/source/man/ddt.1.ronn"

# Runs shell syntax check (development use)
lint:
	echo 'Checking for syntax errors...'
	( for f in ddt variables functions getopt; do bash -n "$(CURDIR)/source/$$f" || exit 1; done )

# Ensures clean release state and creates tag in git (development use)
release: man lint
	sh -c 'REV="`sed "/^REVISION=/!d; s/^[^0-9]*//; s/[^0-9].*$$//;" "$(CURDIR)/source/ddt"`" ; echo "Adding revision tag rev/$$REV..." ; git tag -m "ddt revision $$REV" "rev/$$REV"'
	echo 'Use `git push origin --tags` to update remote tags.'


.PHONY: build install uninstall privileges clean distclean man lint release


