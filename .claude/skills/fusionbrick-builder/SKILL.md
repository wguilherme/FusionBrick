---
name: fusionbrick-builder
description: Builds models/assemblies with FusionBrick parts from a user description. Use when the user asks to build, create or prototype an object (box, case, stand, vehicle, organizer...) using the design system — the final result is an assembly.scad in examples/ with validated previews. Triggers - "build a", "monta um", "create a model", "assembly of", "prototype of", "construct with the parts".
---

# FusionBrick Builder

Turns the user's description into a validated `assembly.scad` in `examples/<name>/`, with isometric preview, zero-collision test and exploded view.

## Mandatory workflow

1. **Decompose onto the grid** — translate the request into 20mm cells. Sketch the layout as an ASCII comment (side and/or top view) BEFORE writing geometry. Consult `spec/design-system.md` and `spec/rules.md` when unsure about a rule.
2. **Write `examples/<name>/assembly.scad`** — follow the template below.
3. **Render and LOOK** — render an isometric PNG and read the image with the Read tool. Compare against the intent. Rotation/mirror transforms are easy to get wrong — iterate until the image matches.
4. **Collision test** — full render; volume must be `0.0000 mm³`.
5. **Generate finals** — `make assembly` (normal + exploded stills) and, if requested, `make assembly-animated` (GIF).
6. **Evaluate honestly** — part counts, which interface each joint uses, limitations of the result.

## Part catalog and when to use each

| Part | Use | Interface |
| --- | --- | --- |
| `plate()` | floor, wall, deck, skin | Ø10 face hole + Ø3 edge holes |
| `atom()` | volumetric structure, 20mm spacer, "window" (Ø10 holes) | face + edge (4 holes per lateral face) |
| `link()` | join two face holes (stack plates, atom↔plate) | face (Ø13.8 flange + Ø9.8 pin) |
| `bridge()` | invisible dowel between edge holes (coplanar joint; 2 per joint) | edge |
| `corner()` | 90° plate↔plate joint; rail with vertical pins | edge (+X and +Z pins, axial canal) |
| `pin()` | generic beam: bumper, post, crossbar, spoiler | edge (studs on top, holes elsewhere — defaults) |
| `elbow()` | rounded 90° curve between beam ends/edge holes | edge (2 pin ports) |
| `vertex()` | 3-way corner (post + 2 beams, or box corner), rounded tip | edge (3 orthogonal pins) |

## Golden rules

- **`use <>` only imports modules with their DEFAULTS** — parameters cannot be overridden. A plate is always 1×1: larger areas = tiled plates + dowels at the seams.
- **Grid Law**: plate/beam thickness lives OUTSIDE the grid volume. Walls, rails and frames sit outside the footprint (`x<0`, `y<0`, etc.).
- Face hole: cell center. Edge hole: 2.5mm from the cell extremities, centered in the thickness.
- Flush contact causes z-fighting in preview — that is correct, not a bug.
- Joints never insert spacing: parts touch, zero gap.
- Canonical test: an `atom()` must fit in any interior cell of the assembly.

## Module coordinates (defaults) — ALWAYS CONSULT

| Module | Occupies | Placement |
| --- | --- | --- |
| `plate()` | 20×20×5 **centered** | cell (cx,cy) on the floor: `translate([cx*20+10, cy*20+10, 2.5])` |
| `atom()` | `[0,20]³` (corner at origin) | `translate([cx*20, cy*20, z_base])` |
| `link()` | centered on the joint plane, halves ±Z | at the joint: `translate([x_hole, y_hole, z_joint])`; horizontal: `rotate([0,90,0])` |
| `bridge()` | dowel along X, centered on the x=0 seam | along Y: `rotate([0,0,90])`; vertical: `rotate([0,-90,0])` |
| `corner()` | beam x∈[-5,0], length Y [0,20], z∈[0,5]; pins +X (y=2.5/17.5, z=2.5) and +Z (x=-2.5); axial canal at (-2.5, 2.5) | rail along X with +Y/+Z pins: `translate([x0+20, 0, 0]) rotate([0,0,90])` → beam x∈[x0,x0+20], y∈[-5,0] |
| `pin()` | beam along Y [0,20], 5×5 section centered on X/Z; studs +Z, holes on bottom/sides/ends | upright: `rotate([90,0,0])` → z∈[0,20], studs −Y (mirror with `mirror([0,1,0])` for +Y); along X: `rotate([0,0,-90])` → x∈[0,20], studs up |
| `elbow()` | quarter cylinder r=5, z∈[0,5], 1st quadrant; pin ports −Y at (2.5,0,2.5) and −X at (0,2.5,2.5) | `mirror` flips port directions — front-left chassis corner: `mirror([1,0,0]) mirror([0,1,0])` → ports +X and +Y |
| `vertex()` | cube `[0,5]³`; pins −X/−Y/−Z at face centers (2.5,2.5) | combinations of `mirror([1,0,0])`/`mirror([0,1,0])` give any octant; e.g. pins +X,+Y,−Z: `translate([x,y,z]) mirror([1,0,0]) mirror([0,1,0]) vertex()` |

Y-rotation quirk (from CLAUDE.md): `rotate([90,0,0])` points +Z toward −Y; for +Y use `rotate([-90,0,0])`. Always confirm on the render.

## Validated joint patterns

- **Stack plate on plate/atom**: `link()` in the face hole, `spacer=0` → flush.
- **Plates side by side**: 2 `bridge()` per joint, in the edge holes (2.5/17.5 of the cell).
- **90° wall on a base**: wall standing on the border (outside the grid) + mirrored `corner()` filling the 5×5 gap: `translate([x_border, 0, 0]) mirror([1,0,0]) corner()`.
- **Vertical post**: upright `pin()` on a `corner()` rail's +Z pin (the post's axial end hole receives the pin). Stack 2 pins + axial dowel for 40mm.
- **3-way top corner** (post + crossbar + longitudinal rail): mirrored `vertex()`.
- **Rounded floor corner**: `elbow()` joining a beam end ↔ rail canal.

## Assembly template

```openscad
// ============================================================
// ASSEMBLY — <name> (<one-line description>)
// ============================================================
// <ASCII sketch of the layout with dimensions in cells>
// ============================================================

use <../../impl/openscad/plate.scad>
// ... only the parts actually used

/* [Assembly] */
explode = 0;          // [0:1:30]
check_collisions = false;   // only works with --render (F6)
collisions_only = false;

// positioned modules, one per logical group, with explode
// applied in levels (ez1 = explode, ez2 = explode*2, ...)

if (!collisions_only) {
    color([...]) group1();
    // connectors: links yellow [0.85,0.75,0.20], dowels green [0.10,0.65,0.45]
}

if (check_collisions || collisions_only) {
    color([1, 0, 0]) {
        intersection() { groupA(); groupB(); }
        // ... every pair that touches
    }
}
```

## Render and validation commands

```bash
# Isometric preview (READ the image afterwards with the Read tool)
openscad --export-format png --imgsize=1200,900 --projection=o \
  --camera=0,0,0,54.7,0,45,500 --autocenter --viewall --preview \
  -o examples/<name>/assembly.png examples/<name>/assembly.scad

# Exploded view
#   ... same command + -D explode=12 -o .../assembly-exploded.png

# Final stills + GIF (scans all examples/*/assembly.scad)
make assembly
make assembly-animated
```

**Collision test** (mandatory before delivering; `intersection()` between modules only works with `--render`, never `--preview`):

```bash
openscad --render --export-format binstl -D collisions_only=true \
  -o /tmp/coll.stl examples/<name>/assembly.scad
python3 -c "
import struct
f = open('/tmp/coll.stl','rb'); f.read(80)
n = struct.unpack('<I', f.read(4))[0]
vol = 0.0
for _ in range(n):
    d = struct.unpack('<12fH', f.read(50))
    v1,v2,v3 = d[3:6],d[6:9],d[9:12]
    vol += (v1[0]*(v2[1]*v3[2]-v3[1]*v2[2]) - v2[0]*(v1[1]*v3[2]-v3[1]*v1[2]) + v3[0]*(v1[1]*v2[2]-v2[1]*v1[2]))/6.0
print(f'collision volume: {abs(vol):.4f} mm³')
"
# Require 0.0000 — coincident faces produce degenerate triangles
# (zero volume); real interpenetration produces volume > 0.
```

## Reference examples

- `examples/u-channel/` — basic joints: bridges, corners, atom+links
- `examples/car-body/` — atom structure + plate skin (closed)
- `examples/rover-chassis/` — pin cage with elbows and vertexes (open)

## When delivering

Report: part counts by type, measured collision volume, which interface each joint uses, and honest limitations of the result (e.g. exposed studs due to `use` defaults, no diagonals). If the request requires part variants beyond the defaults, warn that this is currently impossible via `use <>` and suggest the modules-with-arguments refactor.
