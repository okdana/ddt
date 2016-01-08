.SILENT:

SHELL    := /bin/bash
PREFIX   := /usr/local

default: help

help:
	echo 'Valid targets: build install uninstall lint test'

build:
	echo 'Nothing to do.'

install:
	mkdir -vp "$(PREFIX)/bin"
	cp    -v  ./ddt "$(PREFIX)/bin/"

uninstall:
	rm -f "$(PREFIX)/bin/ddt"

lint:
	bash -n ./ddt && echo 'OK'

tests: test
test:
	./ddt ./tests

.PHONY: default help man build install uninstall lint test tests

