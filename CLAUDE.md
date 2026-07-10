# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

---

## What is FusionBrick

Parametric modular 3D design system for FDM printing. Parts connect on any face via press-fit connectors (LINKs). Currently implemented in OpenSCAD. Architecture is **spec-first**: `spec/` defines the system contract, `impl/` contains tool-specific implementations.

## Commands

```bash
make preview                          # isometric PNG for every part in impl/openscad/
make preview-animated                 # 360° turntable GIF for every part (renders/img/*.gif)
make preview-animated ANIM_DELAY=10 ANIM_FRAMES=72  # slower/smoother (defaults: 15, 36)
make build                            # export STL for every part in impl/openscad/
make assembly                         # isometric PNGs (normal + exploded) for every examples/*/assembly.scad
make assembly-animated                # looping GIF (360° spin + explode/collapse) for every examples/*/assembly.scad
make assembly-animated ASM_ANIM_DELAY=10 ASM_ANIM_FRAMES=96 ASM_ANIM_EXPLODE=20  # tune (defaults: 5, 72, 12)
make assembly-animated ASM_ANIM_SPIN=360                                        # enable full rotation (default: 0 — fixed isometric camera)
make assembly-animated ASM_ANIM_SPEED=2                                         # 2x faster (default: 1; 0.5 = half speed)
make preview PART_COLOR="[r,g,b]"    # override render color (values 0.0–1.0)
make openscad-preview                 # explicit namespace alias
make openscad-build
```

**Dependencies:** `openscad` (see `.tool-versions`) + `magick` (ImageMagick 7).

```bash
asdf plugin add openscad https://github.com/gabrielelana/asdf-openscad
asdf install   # installs openscad version from .tool-versions
```

## Building models

To build a new model/assembly from a user description, use the `fusionbrick-builder` skill (`.claude/skills/fusionbrick-builder/SKILL.md`). It contains the validated module coordinate tables, joint patterns, render commands and the collision-test workflow. Result goes to `examples/<name>/assembly.scad`.

## Architecture

### Spec → Impl separation

`spec/` is the source of truth — tool-agnostic definitions:

- `spec/design-system.md` — system premises (grid integrity, wire passage by default, permanent compatibility)
- `spec/params.md` — global parameters all parts must share
- `spec/parts/*.md` — intent, geometry rules, constraints per part
- `spec/rules.md` — compatibility and design rules (Grid Law, face/edge interfaces)

`impl/openscad/` translates spec to OpenSCAD. Future: `impl/fusion360/`, `impl/manual/`.

### Make pipeline

```
Makefile → hack/automations/core.mk → hack/automations/openscad.mk
```

`core.mk` routes `openscad-*` targets. `openscad.mk` owns all render/export logic. Part list is dynamic: `$(wildcard impl/openscad/*.scad)` — adding a file is enough.

### OpenSCAD conventions

Every `.scad` file follows this order: parameters → derived values → modules → render call.

```openscad
part_color = [0.35, 0.38, 0.42];   // default; overridden by make via -D
border_radius = 0;                   // default 0 (VERTEX: 2)
border_style = "round";              // "round" (sphere) | "chamfer" (45° octahedron minkowski)
color(part_color) my_part();
```

`-D` flags passed at render time override any variable declared in the file. `color()` only affects `--preview` mode (F5/CLI `--preview`), not full render (`--render`/F6).

### Global system parameters — must match across all parts

```
cell_size / atom_size = 20mm
hole_d                = 10mm
relief_depth          = 2mm
relief_margin         = 2mm   → relief_d = hole_d + relief_margin*2 = 14mm
tolerance             = 0.2mm (subtracted from pin/flange for press-fit)
$fn                   = 32
```

If these values differ between parts, holes won't align.

### Known quirk — Y-axis face rotation

```openscad
// Face +Y
translate([0, size/2, 0])  rotate([90,  0, 0]) cylinder(...);
// Face -Y  ← rotate NEGATIVE
translate([0, -size/2, 0]) rotate([-90, 0, 0]) cylinder(...);
```

`rotate([90,0,0])` points toward −Y. Counterintuitive — always verify with F5.

### Preview render pipeline

1. OpenSCAD renders `.tmp.png` with `--preview --colorscheme=Monotone`
2. ImageMagick samples `[0,0]` pixel → removes background color → transparent PNG
3. Output goes to `renders/img/<part>.png`

`make preview` injects `border_radius=1` for documentation renders; `.scad` defaults stay `0`.
