.DEFAULT_GOAL := help
.PHONY: help install serve

help:
	@echo "Available targets:"
	@echo "  install   - Install Ruby dependencies"
	@echo "  serve     - Start the Jekyll local server"

install:
	bundle install

serve:
	bundle exec jekyll serve
