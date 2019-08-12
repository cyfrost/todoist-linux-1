DIST_DIR=dist
VERSION=1.22.0
DROPBOX_DIR=~/Dropbox/projects/binaries

DEPENDENCIES = node npm rpmbuild yarn
K := $(foreach exec,$(DEPENDENCIES), $(if $(shell which "$(exec)"),dependencies_ok,$(error Command Not Found: "$(exec)")))

# Default target executed on error.
error:
	@printf "\nUnknown target (Makefile error).\n\nAbort.\n\n"
	@exit 2


.PHONY: env
env:
	@yarn && cd src && yarn && printf "\nAll development dependencies have been installed successfully!\n\n"

.PHONY: update
update:
	@ncu -u && yarn && cd src && ncu -u && yarn && printf "\nAll development dependencies have been installed successfully!\n\n"

.PHONY: run
run:
	yarn start

.PHONY: build-rpm
build-rpm:
	./node_modules/.bin/electron-builder --linux rpm

.PHONY: build-snap
build-snap:
	./node_modules/.bin/electron-builder --linux snap

.PHONY: build-deb
build-deb:
	./node_modules/.bin/electron-builder --linux deb

.PHONY: build-appimage
build-appimage:
	./node_modules/.bin/electron-builder --linux AppImage

.PHONY: build-pacman
build-pacman:
	./node_modules/.bin/electron-builder --linux pacman

.PHONY: build-win
build-win:
	./node_modules/.bin/electron-builder --win

.PHONY: build-linux
build-linux:
	./node_modules/.bin/electron-builder --linux

.PHONY: build-all
build-all:
	./node_modules/.bin/electron-builder --linux && \
	./node_modules/.bin/electron-builder --win

.PHONY: archive-unpacked
archive-unpacked:
	zip -r $(DIST_DIR)/todoist-linux.zip $(DIST_DIR)/linux-unpacked/*

.PHONY: copy-to-dropbox
copy-to-dropbox: archive-unpacked
	cp $(DIST_DIR)/Todoist_$(VERSION)_amd64.deb $(DROPBOX_DIR)/Todoist.deb && \
	cp $(DIST_DIR)/Todoist-$(VERSION).x86_64.rpm $(DROPBOX_DIR)/Todoist.rpm && \
	cp $(DIST_DIR)/"Todoist $(VERSION).exe" $(DROPBOX_DIR)/Todoist.exe && \
	cp $(DIST_DIR)/todoist-linux.zip $(DROPBOX_DIR)/todoist-linux.zip

.PHONY: set-version
set-version:
	cd src && npm version $(VERSION)

.PHONY: clean
clean:
	@rm -rf $(DIST_DIR) && printf "\nBuild artifacts (from './$(DIST_DIR)') have been deleted successfully!\n\n"

.PHONY: list
list:
	@$(MAKE) -pRrq -f $(lastword $(MAKEFILE_LIST)) : 2>/dev/null | awk -v RS= -F: '/^# File/,/^# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' | sort | egrep -v -e '^[^[:alnum:]]' -e '^$@$$'
