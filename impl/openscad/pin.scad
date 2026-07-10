// ============================================================
// PIN — Design System 3D Modular
// ============================================================
// Viga conectora universal da interface de borda. Parente do
// CORNER, mas totalmente configurável: cada grupo de faces
// (topo, base, laterais, pontas) pode ter PINO, FURO ou nada.
//
// Seção sec_w × sec_h (padrão 5×5 = espessura da PLATE),
// comprimento em células do grid. Pinos e furos ficam nas
// extremidades de cada célula (edge_inset), como todo o sistema.
//
//        pinos ↑ ↑
//       ┌─┴───────┴─┐
//    →  │           │  ←   furos/pinos nas laterais e pontas
//       └─┬───────┬─┘
//        furos ↓ ↓
//
// Presets (parâmetro `preset`):
//   custom               → usa face_top/face_bottom/face_sides/face_ends
//   full_pins_hole_bottom→ pinos no topo, laterais e pontas; furos na base
//   full_holes           → furos em todas as faces
//
// Furos: bore Ø3 × 4mm + rebaixo do colar na boca (Ø3.8 × 1mm)
// Pinos: colar Ø3.6 × 1mm na raiz + haste Ø2.8 (total 3.5mm)
// Furos opostos se encontram (profundidade 4+4 > seção 5) e
// viram furo passante — esperado.
// ============================================================

/* [Preset] */

// Preset de configuração (custom usa os parâmetros de faces abaixo)
preset = "custom"; // [custom, full_pins_hole_bottom, full_holes]

/* [Faces — usados quando preset = custom] */

// Face de cima (+Z)
face_top = "pin"; // [pin, hole, none]

// Face de baixo (-Z)
face_bottom = "hole"; // [pin, hole, none]

// Faces laterais (±X)
face_sides = "hole"; // [pin, hole, none]

// Pontas (±Y, axiais)
face_ends = "hole"; // [pin, hole, none]

/* [Tamanho] */

// Comprimento da viga em células
cells = 1; // [1:1:20]

// Passo do grid (= cell_size do sistema)
cell_size = 20; // [5:1:100]

// Largura da seção, eixo X (= thickness da PLATE)
sec_w = 5; // [3:0.5:20]

// Altura da seção, eixo Z (= thickness da PLATE)
sec_h = 5; // [3:0.5:20]

/* [Interface de borda — manter igual à PLATE/ATOM] */

// Diâmetro do furo de borda (mm)
edge_hole_d = 3; // [1:0.1:5]

// Profundidade do furo de borda (mm)
edge_hole_depth = 4; // [1:0.5:10]

// Distância do centro do furo/pino até a extremidade da célula
edge_inset = 2.5; // [1:0.25:5]

// Comprimento total do pino (colar + haste)
edge_pin_len = 3.5; // [1:0.25:9]

// Largura radial do rebaixo/colar (0 = desativado)
edge_collar_w = 0.4; // [0:0.1:1]

// Profundidade do rebaixo / altura do colar (mm)
edge_collar_depth = 1; // [0.5:0.25:2]

/* [Bordas] */

// Raio de acabamento das arestas da viga (0 = arestas vivas)
border_radius = 0; // [0:0.1:2]

// Estilo do acabamento das arestas: round (raio) ou chamfer (chanfro 45°)
border_style = "round"; // [round, chamfer]

/* [Tolerância de impressão] */

// Folga de encaixe
tolerance = 0.2; // [0:0.05:0.5]

/* [Qualidade] */
$fn = 32;

// ============================================================
// CALCULADOS
// ============================================================

// Configuração efetiva de cada grupo de faces (preset > custom)
top_c    = preset == "full_holes" ? "hole" : preset == "full_pins_hole_bottom" ? "pin"  : face_top;
bottom_c = preset == "full_holes" ? "hole" : preset == "full_pins_hole_bottom" ? "hole" : face_bottom;
sides_c  = preset == "full_holes" ? "hole" : preset == "full_pins_hole_bottom" ? "pin"  : face_sides;
ends_c   = preset == "full_holes" ? "hole" : preset == "full_pins_hole_bottom" ? "pin"  : face_ends;

// Diâmetros efetivos
edge_pin_d = edge_hole_d - tolerance;
collar_d   = edge_hole_d + 2 * edge_collar_w - tolerance;
recess_d   = edge_hole_d + 2 * edge_collar_w;

// Comprimento total da viga
beam_length = cells * cell_size;

// Posições ao longo da viga — nas extremidades de cada célula
pin_positions = [
    for (c = [0 : cells - 1], s = [0, 1])
        c * cell_size + edge_inset + s * (cell_size - 2 * edge_inset)
];

// Raio seguro — limitado pela seção da viga
safe_radius = min(border_radius, sec_w / 2 - 0.01, sec_h / 2 - 0.01);

// ============================================================
// MÓDULOS
// ============================================================

// ------------------------------------------------------------
// Módulo: sólido de acabamento das arestas — esfera (round)
// ou octaedro (chamfer 45°), usado no minkowski
// ------------------------------------------------------------
module border_finish(r) {
    if (border_style == "chamfer")
        polyhedron(
            points = [[r,0,0],[-r,0,0],[0,r,0],[0,-r,0],[0,0,r],[0,0,-r]],
            faces  = [[4,2,0],[4,1,2],[4,3,1],[4,0,3],[5,0,2],[5,2,1],[5,1,3],[5,3,0]]
        );
    else
        sphere(r = r);
}

// ------------------------------------------------------------
// Módulo: corpo da viga com acabamento de aresta opcional
// ------------------------------------------------------------
module beam_body() {
    if (safe_radius <= 0) {
        translate([-sec_w / 2, 0, -sec_h / 2])
            cube([sec_w, beam_length, sec_h]);
    } else {
        minkowski() {
            translate([-sec_w / 2 + safe_radius, safe_radius, -sec_h / 2 + safe_radius])
                cube([sec_w - 2 * safe_radius,
                      beam_length - 2 * safe_radius,
                      sec_h - 2 * safe_radius]);
            border_finish(safe_radius);
        }
    }
}

// Pino com colar na raiz — orientado em +Z a partir da origem
module edge_pin() {
    if (edge_collar_w > 0)
        cylinder(d = collar_d, h = edge_collar_depth);
    cylinder(d = edge_pin_d, h = edge_pin_len);
}

// Furo com rebaixo do colar na boca — orientado em -Z (fura
// para dentro) a partir da origem na superfície
module edge_hole_cut() {
    eps = 0.01;
    rotate([180, 0, 0]) {
        cylinder(d = edge_hole_d, h = edge_hole_depth + eps);
        if (edge_collar_w > 0)
            cylinder(d = recess_d, h = edge_collar_depth + eps);
    }
}

// Aplica pino OU furo numa posição/orientação
// (rot orienta +Z do feature para fora da face)
module face_feature(cfg, pos, rot) {
    if (cfg == "pin")
        translate(pos) rotate(rot) edge_pin();
}
module face_feature_cut(cfg, pos, rot) {
    if (cfg == "hole")
        translate(pos) rotate(rot) edge_hole_cut();
}

// ------------------------------------------------------------
// Módulo: PIN completo — viga centrada em X/Z, y ∈ [0, length]
// ------------------------------------------------------------
module pin() {
    difference() {
        union() {
            // Corpo da viga
            beam_body();

            // Pinos
            for (y = pin_positions) {
                face_feature(top_c,    [0,  y,  sec_h / 2], [0, 0, 0]);
                face_feature(bottom_c, [0,  y, -sec_h / 2], [180, 0, 0]);
                face_feature(sides_c,  [ sec_w / 2, y, 0],  [0, 90, 0]);
                face_feature(sides_c,  [-sec_w / 2, y, 0],  [0, -90, 0]);
            }
            face_feature(ends_c, [0, 0, 0],           [90, 0, 0]);
            face_feature(ends_c, [0, beam_length, 0], [-90, 0, 0]);
        }

        // Furos
        for (y = pin_positions) {
            face_feature_cut(top_c,    [0,  y,  sec_h / 2], [0, 0, 0]);
            face_feature_cut(bottom_c, [0,  y, -sec_h / 2], [180, 0, 0]);
            face_feature_cut(sides_c,  [ sec_w / 2, y, 0],  [0, 90, 0]);
            face_feature_cut(sides_c,  [-sec_w / 2, y, 0],  [0, -90, 0]);
        }
        face_feature_cut(ends_c, [0, 0, 0],           [90, 0, 0]);
        face_feature_cut(ends_c, [0, beam_length, 0], [-90, 0, 0]);
    }
}

// ============================================================
// RENDER
// ============================================================
part_color = [0.35, 0.38, 0.42];
color(part_color) pin();

// ============================================================
// INFO — dimensões no console
// ============================================================
echo("=== PIN ===");
echo(str("Preset             : ", preset));
echo(str("Viga               : ", sec_w, " × ", sec_h, " × ", beam_length, "mm (", cells, " célula(s))"));
echo(str("Faces              : topo=", top_c, " base=", bottom_c, " laterais=", sides_c, " pontas=", ends_c));
echo(str("Pino               : Ø", edge_pin_d, "mm × ", edge_pin_len, "mm + colar Ø", collar_d, "mm × ", edge_collar_depth, "mm"));
echo(str("Furo               : Ø", edge_hole_d, "mm × ", edge_hole_depth, "mm + rebaixo Ø", recess_d, "mm × ", edge_collar_depth, "mm"));
echo(str("Tolerância         : ", tolerance, "mm"));
echo("---");
echo(str("Posições nas extremidades (= centro da seção): ", edge_inset == sec_w / 2 ? "SIM" : "VERIFICAR (edge_inset != sec_w/2)"));
echo(str("Compatível com furo de borda PLATE/ATOM       : ", edge_pin_len < edge_hole_depth ? "SIM" : "VERIFICAR"));