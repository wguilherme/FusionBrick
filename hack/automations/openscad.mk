SHELL := /bin/bash
OPENSCAD := openscad
IMPL_DIR := impl/openscad
RENDERS_DIR := renders
STL_DIR := $(RENDERS_DIR)/stl
IMG_DIR := $(RENDERS_DIR)/img
PARTS := atom plate link bridge corner

.PHONY: preview build $(PARTS)

preview:
	@mkdir -p $(IMG_DIR)
	@for part in $(PARTS); do \
		$(OPENSCAD) --export-format png -o $(IMG_DIR)/$$part.png $(IMPL_DIR)/$$part.scad; \
	done

build:
	@mkdir -p $(STL_DIR)
	@for part in $(PARTS); do \
		$(OPENSCAD) --export-format binstl -o $(STL_DIR)/$$part.stl $(IMPL_DIR)/$$part.scad; \
	done
