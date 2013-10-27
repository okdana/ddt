# ddt Makefile

default: build

# Ensure `./configure` has been run
config.mk:
	@echo 'Please run `./configure` prior to running `make`.'
	@false

include ./config.mk

# Merges/copies source files into /out
build: config.mk
	@mkdir -p "$(CURDIR)/out/bin"
	@mkdir -p "$(CURDIR)/out/doc"
	
	@# This is a silly but functional way to merge all source files into a single script
	@cp "$(CURDIR)/source/ddt" "$(CURDIR)/out/bin/ddt"
	@sed -i '' '/^source .*variables/r $(CURDIR)/source/variables' "$(CURDIR)/out/bin/ddt"
	@sed -i '' '/^source .*functions/r $(CURDIR)/source/functions' "$(CURDIR)/out/bin/ddt"
	@sed -i '' '/^source .*getopt/r $(CURDIR)/source/getopt' "$(CURDIR)/out/bin/ddt"
	@sed -i '' '/^source /d;' "$(CURDIR)/out/bin/ddt"
	@chmod a+x "$(CURDIR)/out/bin/ddt"
	
	@cp "$(CURDIR)/source/man/ddt.1" "$(CURDIR)/out/doc/ddt.1"
	
	@echo 'Built into $(CURDIR)/out.'

# Checks for root privileges
privileges:
	@test $(shell id -u) = 0 || echo 'Root privileges needed.'
	@test $(shell id -u) = 0

# Installs /out files to the appropriate locations
install: privileges build
	@mkdir -p "$(MANPREFIX)/man1"
	@cp "$(CURDIR)/out/bin/ddt" "$(PREFIX)/bin/ddt"
	@cp "$(CURDIR)/out/doc/ddt.1" "$(MANPREFIX)/man1/ddt.1"
	
	@echo 'Successfully installed.'

# Un-installs `ddt` from the system
uninstall: privileges
	@rm -f "$(PREFIX)/bin/ddt"
	@rm -f "$(MANPREFIX)/man1/ddt.1"
	
	@echo 'Succesfully un-installed.'

# Builds roff file(s) with `ronn` (development usage)
man:
	@ronn -r "$(CURDIR)/source/man/ddt.1.ronn"

# Runs shell syntax check
lint:
	@for f in ddt variables functions getopt; do bash -n "$(CURDIR)/source/$$f" || exit 1; done

# Removes /out directory
clean:
	@rm -rf "$(CURDIR)/out"

# Removes /out directory
distclean: clean
	@rm -f "$(CURDIR)/config.mk"


.PHONY: build install uninstall privileges man lint clean distclean

