.PHONY: install uninstall lint test

install:
	./install.sh

uninstall:
	./uninstall.sh

lint:
	./scripts/lint

test:
	./scripts/test

