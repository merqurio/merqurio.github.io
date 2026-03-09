BUNDLE := $(shell command -v rbenv >/dev/null 2>&1 && echo "rbenv exec bundle" || echo "bundle")

.DEFAULT_GOAL := help
.PHONY: help install serve

help:
	@echo "Available targets:"
	@echo "  install   - Install Ruby dependencies"
	@echo "  serve     - Start the Jekyll local server"

install:
	$(BUNDLE) install

serve:
	$(BUNDLE) exec jekyll serve
