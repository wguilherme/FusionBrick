// ============================================================
// CORNER — Design System 3D Modular
// ============================================================
// Viga de canto: preenche a lacuna que sobra quando duas
// PLATEs se encontram a 90° borda-com-borda. Seção
// wall_thickness × plate_thickness, comprimento em células.
//
// Pinos em 2 faces perpendiculares entram nos FUROS DE BORDA
// das PLATEs (edge_hole_d) — os furos de face (topo/base) e
// rebaixos ficam 100% livres para LINKs e ATOMs.
//
// Estrutura (vista lateral, X-Z):
//
//       │ │ parede (x ∈ [-wt, 0])
//       │ │
//       │ │
//       └┬┘ ← borda inferior da parede (z = pt)
//    ┌─┐ ▲ pinos ↑ furos de borda da parede
//    │▓├►┌──────────── base (z ∈ [0, pt])
//    └─┘ └──────────── pinos → furos de borda da base
//     ↑ viga preenche a lacuna wt × pt
//
// Lei do Grid preservada:
//   - face interna da parede em x = 0 (plano do grid)
//   - borda inferior da parede em z = pt (plano da superfície)
//   - furo da parede a cell_size/2 da superfície → ATOM alinha
//   - nada protrui: faces externas da viga ficam flush com
//     a base (embaixo) e com a parede (fora)
//
// Parâmetros:
// - cells           : comprimento da viga em células do grid
// - cell_size       : passo do grid (igual à PLATE)
// - plate_thickness : espessura da PLATE base
// - wall_thickness  : espessura da PLATE parede
// - edge_hole_d     : diâmetro do furo de borda (igual à PLATE)
// - edge_pin_len    : comprimento dos pinos (< edge_hole_depth)
// - tolerance       : folga de encaixe
// - canal_d         : canal axial ao longo da viga (0 = sólido)
// ============================================================

/* [Grid — manter igual à PLATE] */

// Comprimento da viga em células
cells = 1; // [1:1:20]

// Passo do grid (= cell_size da PLATE)
cell_size = 20; // [5:1:100]

// Espessura da PLATE base (mm)
plate_thickness = 5; // [1:0.5:30]

// Espessura da PLATE parede (mm)
wall_thickness = 5; // [1:0.5:30]

/* [Furos de borda — manter igual à PLATE] */

// Diâmetro do furo de borda da PLATE (mm)
edge_hole_d = 3; // [1:0.1:5]

// Distância do centro do furo/pino até a extremidade da célula
// (= thickness/2 — centro da seção da viga)
edge_inset = 2.5; // [1:0.25:5]

// Comprimento dos pinos — menor que edge_hole_depth da PLATE
// para o pino não bater no fundo antes de assentar
edge_pin_len = 3.5; // [1:0.25:9]

// Rebaixo do colar na boca dos furos da PLATE (manter igual)
// Colar na raiz do pino trava profundidade e reforça a raiz
edge_collar_w = 0.4; // [0:0.1:1]

// Profundidade do rebaixo / altura do colar (mm)
edge_collar_depth = 1; // [0.5:0.25:2]

/* [Bordas] */

// Raio de acabamento das arestas da viga (0 = arestas vivas)
border_radius = 0; // [0:0.1:2]

// Estilo do acabamento das arestas: round (raio) ou chamfer (chanfro 45°)
border_style = "round"; // [round, chamfer]

/* [Tolerância de impressão] */

// Folga de encaixe — reduz o pino para caber no furo de borda
tolerance = 0.2; // [0:0.05:0.5]

/* [Canal interno para fios] */

// Canal axial ao longo da viga (0 = sólido)
// 3mm = passa jumper Dupont (2.5mm); limitado pela seção da viga
canal_d = 3; // [0:0.1:5]

/* [Qualidade] */
$fn = 32;

// ============================================================
// CALCULADOS
// ============================================================

// Diâmetro efetivo do pino (com tolerância)
edge_pin_d = edge_hole_d - tolerance;

// Diâmetro do colar na raiz do pino (assenta no rebaixo da boca)
collar_d = edge_hole_d + 2 * edge_collar_w - tolerance;

// Comprimento total da viga
beam_length = cells * cell_size;

// Posições dos pinos ao longo da viga — 2 por célula, NAS
// EXTREMIDADES: a edge_inset de cada limite da célula.
// O pino da ponta fica a edge_inset do fim da viga = centro da
// seção de outra viga perpendicular → duas vigas formam um "L"
// flush: o pino de uma entra no canal axial (Ø3) da outra.
pin_positions = [
    for (c = [0 : cells - 1], s = [0, 1])
        c * cell_size + edge_inset + s * (cell_size - 2 * edge_inset)
];


// ============================================================
// MÓDULOS
// ============================================================

// Raio seguro — limitado pela seção da viga
safe_radius = min(border_radius, wall_thickness / 2 - 0.01, plate_thickness / 2 - 0.01);

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
        translate([-wall_thickness, 0, 0])
            cube([wall_thickness, beam_length, plate_thickness]);
    } else {
        minkowski() {
            translate([-wall_thickness + safe_radius, safe_radius, safe_radius])
                cube([wall_thickness - 2 * safe_radius,
                      beam_length - 2 * safe_radius,
                      plate_thickness - 2 * safe_radius]);
            border_finish(safe_radius);
        }
    }
}

// ------------------------------------------------------------
// Módulo: CORNER completo
// Viga ocupa x ∈ [-wall_thickness, 0], z ∈ [0, plate_thickness],
// y ∈ [0, beam_length] — o mesmo volume da lacuna do canto
// ------------------------------------------------------------
// Pino com colar na raiz — orientado em +Z a partir da origem
module edge_pin() {
    if (edge_collar_w > 0)
        cylinder(d = collar_d, h = edge_collar_depth);
    cylinder(d = edge_pin_d, h = edge_pin_len);
}

module corner() {
    difference() {
        union() {
            // Corpo da viga
            beam_body();

            // Pinos face +X — entram nos furos de borda da BASE
            // centrados na espessura da base (z = pt/2)
            for (y = pin_positions)
                translate([0, y, plate_thickness / 2])
                    rotate([0, 90, 0])
                        edge_pin();

            // Pinos face +Z — entram nos furos de borda da PAREDE
            // centrados na espessura da parede (x = -wt/2)
            for (y = pin_positions)
                translate([-wall_thickness / 2, y, plate_thickness])
                    edge_pin();
        }

        // Canal axial para fios (se canal_d > 0)
        if (canal_d > 0) {
            translate([-wall_thickness / 2, -0.01, plate_thickness / 2])
                rotate([-90, 0, 0])
                    cylinder(d = canal_d, h = beam_length + 0.02);

            // Rebaixo do colar nas bocas do canal — permite o pino
            // (com colar) de outro CORNER/PIN entrar no encaixe em L
            if (edge_collar_w > 0) {
                translate([-wall_thickness / 2, -0.01, plate_thickness / 2])
                    rotate([-90, 0, 0])
                        cylinder(d = canal_d + 2 * edge_collar_w, h = edge_collar_depth + 0.01);
                translate([-wall_thickness / 2, beam_length + 0.01, plate_thickness / 2])
                    rotate([90, 0, 0])
                        cylinder(d = canal_d + 2 * edge_collar_w, h = edge_collar_depth + 0.01);
            }
        }
    }
}

// ============================================================
// RENDER
// ============================================================
part_color = [0.35, 0.38, 0.42];
color(part_color) corner();

// ============================================================
// INFO — dimensões no console
// ============================================================
echo("=== CORNER ===");
echo(str("Viga               : ", wall_thickness, " × ", plate_thickness, " × ", beam_length, "mm (", cells, " célula(s))"));
echo(str("Pinos por face     : ", len(pin_positions), " × Ø", edge_pin_d, "mm × ", edge_pin_len, "mm (furo receptor: Ø", edge_hole_d, "mm)"));
echo(str("Pinos              : a ", edge_inset, "mm das extremidades de cada célula (vão interno: ", cell_size - 2 * edge_inset, "mm)"));
echo(str("Encaixe em L       : pino da ponta a ", edge_inset, "mm do fim = centro da seção (", wall_thickness / 2, "mm): ", edge_inset == wall_thickness / 2 ? "SIM" : "VERIFICAR"));
echo(str("Canal axial        : ", canal_d > 0 ? str(canal_d, "mm") : "sólido (canal fechado)"));
echo(str("Tolerância         : ", tolerance, "mm"));
echo("---");
echo(str("Parede do canal    : ", canal_d == 0 || (min(wall_thickness, plate_thickness) - canal_d) / 2 >= 1 ? "SIM (>= 1mm)" : "VERIFICAR (seção fina demais)"));
echo(str("Pino cabe no furo (prof. 4mm): ", edge_pin_len < 4 ? "SIM" : "VERIFICAR (edge_pin_len >= edge_hole_depth)"));