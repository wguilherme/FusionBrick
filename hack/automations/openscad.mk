SHELL := /bin/bash
OPENSCAD := openscad
MAGICK   := magick
IMPL_DIR    := impl/openscad
RENDERS_DIR := renders
STL_DIR     := $(RENDERS_DIR)/stl
IMG_DIR     := $(RENDERS_DIR)/img
PARTS       := $(basename $(notdir $(wildcard $(IMPL_DIR)/*.scad)))

IMGSIZE     := 800,600
COLORSCHEME := Metallic
BG_COLOR    := \#313131
GRAD_TOP    := \#d0d0d0
GRAD_BOT    := \#313131

.PHONY: preview build

preview:
	@mkdir -p $(IMG_DIR)
	@for part in $(PARTS); do \
		$(OPENSCAD) \
			--export-format png \
			--colorscheme=$(COLORSCHEME) \
			--imgsize=$(IMGSIZE) \
			--autocenter --viewall \
			--projection=p \
			-o $(IMG_DIR)/$$part.tmp.png \
			$(IMPL_DIR)/$$part.scad || { echo "SKIP $$part (render failed)"; continue; }; \
		$(MAGICK) \
			-size 800x600 gradient:"$(GRAD_TOP)-$(GRAD_BOT)" \
			$(IMG_DIR)/$$part.tmp.png \
			-fuzz 5% -composite \
			$(IMG_DIR)/$$part.png; \
		rm -f $(IMG_DIR)/$$part.tmp.png; \
	done

build:
	@mkdir -p $(STL_DIR)
	@for part in $(PARTS); do \
		$(OPENSCAD) --export-format binstl -o $(STL_DIR)/$$part.stl $(IMPL_DIR)/$$part.scad; \
	done
