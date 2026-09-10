VERSION := $(shell ruby -r ./lib/gsc/version -e 'puts GSC::VERSION')
GEM_FILE := gsc-cli-$(VERSION).gem

.PHONY: all build test install git-push gem-push release publish clean help

all: build

help:
	@echo "Available commands:"
	@echo "  make build       - Build standalone binary (dist/gsc) and gem package ($(GEM_FILE))"
	@echo "  make test        - Run syntax checks and test suite"
	@echo "  make install     - Install standalone binary to ~/.local/bin/gsc"
	@echo "  make git-push    - Stage, commit with 'release: v$(VERSION)', and push to GitHub"
	@echo "  make gem-push    - Build and push $(GEM_FILE) to RubyGems.org"
	@echo "  make release     - Run tests, build, git-push, and gem-push (All-in-one)"
	@echo "  make publish     - Alias for 'make release'"
	@echo "  make clean       - Remove built *.gem packages"

build:
	@echo "🔨 Building standalone binary (v$(VERSION))..."
	rake build:standalone
	cp dist/gsc bin/gsc
	@echo "💎 Building RubyGem package ($(GEM_FILE))..."
	gem build gsc.gemspec

test:
	@echo "🧪 Running syntax and unit tests..."
	rake test

install:
	@echo "📦 Installing standalone binary to ~/.local/bin/gsc..."
	rake install:standalone

git-push:
	@echo "📦 Staging and committing changes for v$(VERSION)..."
	git add -A
	@if git diff-index --quiet HEAD; then \
		echo "ℹ️  Working directory clean, nothing to commit."; \
	else \
		git commit -m "release: v$(VERSION) - sync release binaries and gemspec"; \
	fi
	@echo "🚀 Pushing to GitHub (origin main)..."
	git push origin main

gem-push: build
	@echo "💎 Pushing $(GEM_FILE) to RubyGems.org..."
	gem push $(GEM_FILE)

release: test git-push gem-push
	@echo ""
	@echo "🎉 v$(VERSION) successfully published to GitHub and RubyGems.org!"
	@echo "   GitHub:   https://github.com/ApollosWave/gsc-cli"
	@echo "   RubyGems: https://rubygems.org/gems/gsc-cli"

publish: release

clean:
	@echo "🧹 Cleaning built gem files..."
	rm -f *.gem
