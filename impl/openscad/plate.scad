// ============================================================
// PLATE — Design System 3D Modular
// ============================================================
// Placa base do sistema modular.
// Cada célula da placa referencia 1 ATOM — os furos coincidem
// quando os parâmetros cell_size, hole_d e relief são iguais.
//
// Compatibilidade com ATOM:
//   plate.cell_size   == atom.atom_size
//   plate.hole_d      == atom.hole_d
//   plate.relief_*    == atom.relief_*
//
// Parâmetros:
// - cell_size     : tamanho de 1 célula (deve = atom_size)
// - qty_x         : quantidade de células no eixo X
// - qty_y         : quantidade de células no eixo Y
// - thickness     : espessura da placa (mm)
// - hole_d        : diâmetro do furo (deve = atom.hole_d)
// - relief_depth  : profundidade do baixo relevo
// - relief_margin : margem ao redor do furo
// - border_radius : arredondamento das bordas externas
// ============================================================

/* [Tamanho da Placa] */

// Tamanho de 1 célula — deve ser igual ao atom_size do ATOM
cell_size = 20; // [5:1:100]

// Quantidade de células no eixo X
qty_x = 2; // [1:1:20]

// Quantidade de células no eixo Y
qty_y = 2; // [1:1:20]

// Espessura da placa (mm)
thickness = 3; // [1:0.5:20]

/* [Furos — manter igual ao ATOM para coincidir] */

// Diâmetro do furo passante (mm)
hole_d = 10; // [0.5:0.1:15]

// Profundidade do baixo relevo (mm)
relief_depth = 2; // [0.1:0.05:5]

// Margem do baixo relevo ao redor do furo (mm)
relief_margin = 2; // [0.5:0.1:5]

/* [Bordas] */

// Raio de arredondamento das bordas externas (0 = sem arredondamento)
border_radius = 0; // [0:0.1:5]

/* [Qualidade] */

// Segmentos dos cilindros
$fn = 32;

// ============================================================
// CALCULADOS
// ============================================================

// Diâmetro total do baixo relevo
relief_d = hole_d + (relief_margin * 2);

// Dimensões totais da placa
total_x = cell_size * qty_x;
total_y = cell_size * qty_y;

// Raio seguro — limitado pela espessura e pelo tamanho mínimo
safe_radius = min(border_radius, thickness / 2 - 0.01, cell_size / 2 - 0.01);

// ============================================================
// MÓDULOS
// ============================================================

// ------------------------------------------------------------
// Módulo: corpo da placa com border radius opcional
// ------------------------------------------------------------
module plate_body() {
    if (safe_radius <= 0) {
        cube([total_x, total_y, thickness], center = true);
    } else {
        // Minkowski com esfera para arredondar bordas
        inner_x = total_x - 2 * safe_radius;
        inner_y = total_y - 2 * safe_radius;
        inner_z = thickness - 2 * safe_radius;
        minkowski() {
            cube([inner_x, inner_y, inner_z], center = true);
            sphere(r = safe_radius);
        }
    }
}

// ------------------------------------------------------------
// Módulo: furo + baixo relevo em uma célula (face topo e base)
// Centrado em X=0, Y=0
// ------------------------------------------------------------
module cell_hole() {
    // Furo passante em Z
    cylinder(d = hole_d, h = thickness + 1, center = true);

    // Baixo relevo face TOPO (+Z)
    translate([0, 0, thickness / 2 - relief_depth])
        cylinder(d = relief_d, h = relief_depth + 0.01);

    // Baixo relevo face BASE (-Z)
    translate([0, 0, -thickness / 2])
        cylinder(d = relief_d, h = relief_depth + 0.01);
}

// ------------------------------------------------------------
// Módulo: grade de furos alinhada com o grid de ATOMs
// Furo centrado em cada célula → coincide com ATOM em Z
// ------------------------------------------------------------
module hole_grid() {
    for (ix = [0 : qty_x - 1])
        for (iy = [0 : qty_y - 1])
            translate([
                ix * cell_size + cell_size / 2 - total_x / 2,
                iy * cell_size + cell_size / 2 - total_y / 2,
                0
            ])
            cell_hole();
}

// ------------------------------------------------------------
// Módulo: PLATE completa
// ------------------------------------------------------------
module plate() {
    difference() {
        plate_body();
        hole_grid();
    }
}

// ============================================================
// RENDER
// ============================================================
plate();
