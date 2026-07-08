# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

---

## What is FusionBrick

Parametric modular 3D design system for FDM printing. Parts connect on any face via press-fit connectors (LINKs). Currently implemented in OpenSCAD. Architecture is **spec-first**: `spec/` defines the system contract, `impl/` contains tool-specific implementations.

## Commands

```bash
make preview                          # render PNG for every part in impl/openscad/
make build                            # export STL for every part in impl/openscad/
make assembly                         # isometric PNGs (normal + exploded) for every examples/*/assembly.scad
make preview PART_COLOR="[r,g,b]"    # override render color (values 0.0–1.0)
make openscad-preview                 # explicit namespace alias
make openscad-build
```

**Dependencies:** `openscad` (see `.tool-versions`) + `magick` (ImageMagick 7).

```bash
asdf plugin add openscad https://github.com/gabrielelana/asdf-openscad
asdf install   # installs openscad version from .tool-versions
```

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
border_radius = 0;                   // default 0; make preview injects 1
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
