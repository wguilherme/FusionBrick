SHELL := /bin/bash
OPENSCAD := openscad
MAGICK   := magick
IMPL_DIR    := impl/openscad
RENDERS_DIR := renders
STL_DIR     := $(RENDERS_DIR)/stl
IMG_DIR     := $(RENDERS_DIR)/img
PARTS       := $(basename $(notdir $(wildcard $(IMPL_DIR)/*.scad)))

IMGSIZE     := 800,600
IMG_W       := 800
IMG_H       := 600
# options: Cornfield | Metallic | Sunset | Starnight | BeforeDawn | Nature | DeepOcean | Solarized | Tomorrow | Tomorrow Night | Monotone — https://en.wikibooks.org/wiki/OpenSCAD_User_Manual/Preferences#Color_Schemes
COLORSCHEME := Monotone
GRAD_TOP    := rgb(208,208,208)
GRAD_BOT    := rgb(82, 82, 82)
PART_COLOR  := [0.35, 0.38, 0.42]
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
			--preview \
			-D "part_color=$(PART_COLOR)" \
			-o $(IMG_DIR)/$$part.tmp.png \
			$(IMPL_DIR)/$$part.scad || { echo "SKIP $$part (render failed)"; continue; }; \
		BG=$$($(MAGICK) $(IMG_DIR)/$$part.tmp.png -format "%[pixel:u.p{0,0}]" info:); \
		$(MAGICK) $(IMG_DIR)/$$part.tmp.png -fuzz 2% -transparent "$$BG" $(IMG_DIR)/$$part.png; \
		rm -f $(IMG_DIR)/$$part.tmp.png; \
	done

build:
	@mkdir -p $(STL_DIR)
	@for part in $(PARTS); do \
		$(OPENSCAD) --export-format binstl -o $(STL_DIR)/$$part.stl $(IMPL_DIR)/$$part.scad; \
	done
