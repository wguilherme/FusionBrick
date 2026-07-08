SHELL := /bin/bash
OPENSCAD := openscad
MAGICK   := magick
IMPL_DIR    := impl/openscad
RENDERS_DIR := renders
STL_DIR     := $(RENDERS_DIR)/stl
IMG_DIR     := $(RENDERS_DIR)/img
PARTS       := $(basename $(notdir $(wildcard $(IMPL_DIR)/*.scad)))
ASSEMBLIES  := $(wildcard examples/*/assembly.scad)

IMGSIZE     := 800,600
IMG_W       := 800
IMG_H       := 600
# options: Cornfield | Metallic | Sunset | Starnight | BeforeDawn | Nature | DeepOcean | Solarized | Tomorrow | Tomorrow Night | Monotone — https://en.wikibooks.org/wiki/OpenSCAD_User_Manual/Preferences#Color_Schemes
COLORSCHEME := Monotone
GRAD_TOP    := rgb(208,208,208)
GRAD_BOT    := rgb(82, 82, 82)
PART_COLOR  := [0.35, 0.38, 0.42]
ASM_IMGSIZE := 1200,900
# câmera isométrica: projeção ortográfica + rotação 54.7°/45°
ISO_ELEV    := 54.7
ISO_AZIM    := 45
ISO_CAMERA  := --projection=o --camera=0,0,0,$(ISO_ELEV),0,$(ISO_AZIM),500 --autocenter --viewall

# animação: frames por volta completa e delay entre frames (1/100s)
ANIM_FRAMES := 36
ANIM_DELAY  := 15

# animação de assembly: frames totais (explode/recolhe) e delay
ASM_ANIM_FRAMES := 72
ASM_ANIM_DELAY  := 5
ASM_ANIM_EXPLODE := 12
# graus de giro total no loop — 0 (padrão) mantém a câmera fixa no ângulo
# isométrico e só anima o explode/recolhe
ASM_ANIM_SPIN := 0
# multiplicador de velocidade — 2 = 2x mais rápido, 0.5 = metade (padrão: 1)
ASM_ANIM_SPEED := 1

.PHONY: preview preview-animated build assembly assembly-animated

preview:
	@mkdir -p $(IMG_DIR)
	@for part in $(PARTS); do \
		$(OPENSCAD) \
			--export-format png \
			--colorscheme=$(COLORSCHEME) \
			--imgsize=$(IMGSIZE) \
			$(ISO_CAMERA) \
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

assembly:
	@for asm in $(ASSEMBLIES); do \
		dir=$$(dirname $$asm); \
		echo "ASSEMBLY $$dir"; \
		$(OPENSCAD) \
			--export-format png \
			--imgsize=$(ASM_IMGSIZE) \
			$(ISO_CAMERA) \
			--preview \
			-o $$dir/assembly.png \
			$$asm || { echo "SKIP $$asm (render failed)"; continue; }; \
		$(OPENSCAD) \
			--export-format png \
			--imgsize=$(ASM_IMGSIZE) \
			$(ISO_CAMERA) \
			--preview \
			-D explode=12 \
			-o $$dir/assembly-exploded.png \
			$$asm; \
	done

preview-animated:
	@mkdir -p $(IMG_DIR)
	@for part in $(PARTS); do \
		echo "ANIMATE $$part"; \
		tmpdir=$$(mktemp -d); \
		ok=1; \
		for i in $$(seq 0 $$(( $(ANIM_FRAMES) - 1 ))); do \
			rot=$$(( $(ISO_AZIM) + i * 360 / $(ANIM_FRAMES) )); \
			frame=$$tmpdir/frame_$$(printf '%03d' $$i).png; \
			$(OPENSCAD) \
				--export-format png \
				--colorscheme=$(COLORSCHEME) \
				--imgsize=$(IMGSIZE) \
				--projection=o \
				--camera=0,0,0,$(ISO_ELEV),0,$$rot,500 \
				--autocenter --viewall \
				--preview \
				-D "part_color=$(PART_COLOR)" \
				-o $$frame \
				$(IMPL_DIR)/$$part.scad 2>/dev/null || { echo "SKIP $$part (render failed)"; ok=0; break; }; \
			BG=$$($(MAGICK) $$frame -format "%[pixel:u.p{0,0}]" info:); \
			$(MAGICK) $$frame -fuzz 2% -transparent "$$BG" $$frame; \
		done; \
		if [ $$ok -eq 1 ]; then \
			$(MAGICK) -delay $(ANIM_DELAY) -loop 0 -dispose Background $$tmpdir/frame_*.png $(IMG_DIR)/$$part.gif; \
			echo "  -> $(IMG_DIR)/$$part.gif"; \
		fi; \
		rm -rf $$tmpdir; \
	done

# Explode e recolhe (boomerang) — loop perfeito, câmera isométrica fixa
# por padrão (ASM_ANIM_SPIN=0). Se ASM_ANIM_SPIN > 0, soma um giro
# completo ao ângulo isométrico inicial (ISO_AZIM) enquanto anima.
# explode segue 1-cos (vai e volta suave), varrendo o mesmo número de
# frames que o giro para fechar o loop exatamente.
assembly-animated:
	@for asm in $(ASSEMBLIES); do \
		dir=$$(dirname $$asm); \
		echo "ANIMATE ASSEMBLY $$dir"; \
		tmpdir=$$(mktemp -d); \
		ok=1; \
		for i in $$(seq 0 $$(( $(ASM_ANIM_FRAMES) - 1 ))); do \
			rot=$$(( $(ISO_AZIM) + i * $(ASM_ANIM_SPIN) / $(ASM_ANIM_FRAMES) )); \
			frac=$$(LC_NUMERIC=C awk -v i=$$i -v n=$(ASM_ANIM_FRAMES) 'BEGIN { pi = atan2(0,-1); print (1 - cos(2*pi*i/n)) / 2 }'); \
			explode=$$(LC_NUMERIC=C awk -v f=$$frac -v e=$(ASM_ANIM_EXPLODE) 'BEGIN { print f * e }'); \
			frame=$$tmpdir/frame_$$(printf '%03d' $$i).png; \
			$(OPENSCAD) \
				--export-format png \
				--imgsize=$(ASM_IMGSIZE) \
				--projection=o \
				--camera=0,0,0,$(ISO_ELEV),0,$$rot,500 \
				--autocenter --viewall \
				--preview \
				-D "explode=$$explode" \
				-o $$frame \
				$$asm 2>/dev/null || { echo "SKIP $$asm (render failed)"; ok=0; break; }; \
		done; \
		if [ $$ok -eq 1 ]; then \
			eff_delay=$$(LC_NUMERIC=C awk -v d=$(ASM_ANIM_DELAY) -v s=$(ASM_ANIM_SPEED) 'BEGIN { v = d / s; print (v < 1) ? 1 : int(v + 0.5) }'); \
			$(MAGICK) -delay $$eff_delay -loop 0 $$tmpdir/frame_*.png $$dir/assembly.gif; \
			echo "  -> $$dir/assembly.gif (delay=$$eff_delay)"; \
		fi; \
		rm -rf $$tmpdir; \
	done
