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

// Comprimento dos pinos — menor que edge_hole_depth da PLATE
// para o pino não bater no fundo antes de assentar
edge_pin_len = 3.5; // [1:0.25:9]

// Nervuras que preenchem os rebaixos de borda das PLATEs
// (+ cisalhamento e anti-deslizamento; false = faces lisas)
ribs = true;

// Profundidade do rebaixo de borda da PLATE (mm)
edge_relief_depth = 1.5; // [0.5:0.1:3]

// Altura do rebaixo de borda da PLATE (mm)
edge_relief_height = 2; // [1:0.1:4]

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

// Comprimento total da viga
beam_length = cells * cell_size;

// Posições dos pinos ao longo da viga — 2 por célula,
// centro da célula ± cell_size/4 (passo uniforme cell_size/2)
pin_positions = [
    for (c = [0 : cells - 1], s = [-1, 1])
        c * cell_size + cell_size / 2 + s * cell_size / 4
];

// Centros das células ao longo da viga (nervuras)
cell_centers = [ for (c = [0 : cells - 1]) c * cell_size + cell_size / 2 ];

// Nervura — dimensões efetivas (com tolerância)
rib_len    = cell_size / 2 - tolerance;
rib_depth  = edge_relief_depth - tolerance;
rib_height = edge_relief_height - tolerance;

// ============================================================
// MÓDULOS
// ============================================================

// ------------------------------------------------------------
// Módulo: CORNER completo
// Viga ocupa x ∈ [-wall_thickness, 0], z ∈ [0, plate_thickness],
// y ∈ [0, beam_length] — o mesmo volume da lacuna do canto
// ------------------------------------------------------------
module corner() {
    difference() {
        union() {
            // Corpo da viga
            translate([-wall_thickness, 0, 0])
                cube([wall_thickness, beam_length, plate_thickness]);

            // Pinos face +X — entram nos furos de borda da BASE
            // centrados na espessura da base (z = pt/2)
            for (y = pin_positions)
                translate([0, y, plate_thickness / 2])
                    rotate([0, 90, 0])
                        cylinder(d = edge_pin_d, h = edge_pin_len);

            // Pinos face +Z — entram nos furos de borda da PAREDE
            // centrados na espessura da parede (x = -wt/2)
            for (y = pin_positions)
                translate([-wall_thickness / 2, y, plate_thickness])
                    cylinder(d = edge_pin_d, h = edge_pin_len);

            // Nervuras — preenchem os rebaixos de borda das PLATEs
            if (ribs) {
                for (yc = cell_centers) {
                    // Face +X — rebaixo da borda da BASE
                    translate([0, yc - rib_len / 2, plate_thickness / 2 - rib_height / 2])
                        cube([rib_depth, rib_len, rib_height]);

                    // Face +Z — rebaixo da borda da PAREDE
                    translate([-wall_thickness / 2 - rib_height / 2, yc - rib_len / 2, plate_thickness])
                        cube([rib_height, rib_len, rib_depth]);
                }
            }
        }

        // Canal axial para fios (se canal_d > 0)
        if (canal_d > 0)
            translate([-wall_thickness / 2, -0.01, plate_thickness / 2])
                rotate([-90, 0, 0])
                    cylinder(d = canal_d, h = beam_length + 0.02);
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
echo(str("Passo dos pinos    : ", cell_size / 2, "mm (= cell_size/2)"));
echo(str("Nervuras           : ", ribs ? str(cells * 2, " × ", rib_len, " × ", rib_depth, " × ", rib_height, "mm") : "desativadas"));
echo(str("Canal axial        : ", canal_d > 0 ? str(canal_d, "mm") : "sólido (canal fechado)"));
echo(str("Tolerância         : ", tolerance, "mm"));
echo("---");
echo(str("Parede do canal    : ", canal_d == 0 || (min(wall_thickness, plate_thickness) - canal_d) / 2 >= 1 ? "SIM (>= 1mm)" : "VERIFICAR (seção fina demais)"));
echo(str("Pino cabe no furo (prof. 4mm): ", edge_pin_len < 4 ? "SIM" : "VERIFICAR (edge_pin_len >= edge_hole_depth)"));