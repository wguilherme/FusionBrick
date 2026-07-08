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
// Espessura mínima recomendada:
//   thickness >= (relief_depth * 2) + 1mm de parede
//   Ex: relief_depth=2 → thickness mínima = 5mm
//
// Parâmetros:
// - cell_size     : tamanho de 1 célula (deve = atom_size)
// - qty_x         : quantidade de células no eixo X
// - qty_y         : quantidade de células no eixo Y
// - thickness     : espessura da placa (mm)
// - hole_d        : diâmetro do furo (deve = atom.hole_d)
// - relief_depth  : profundidade do baixo relevo (ambos os lados)
// - relief_margin : margem ao redor do furo
// - border_radius : arredondamento das bordas externas
// ============================================================

/* [Tamanho da Placa] */

// Tamanho de 1 célula — deve ser igual ao atom_size do ATOM
cell_size = 20; // [5:1:100]

// Quantidade de células no eixo X
qty_x = 1; // [1:1:20]

// Quantidade de células no eixo Y
qty_y = 1; // [1:1:20]

// Espessura da placa — mínimo: (relief_depth * 2) + 1mm
// Com relief_depth=2 o mínimo é 5mm
thickness = 5; // [1:0.5:30]

/* [Furos — manter igual ao ATOM para coincidir] */

// Diâmetro do furo passante (mm)
hole_d = 10; // [0.5:0.1:15]

// Profundidade do baixo relevo em cada face (topo e base)
relief_depth = 2; // [0.1:0.05:5]

// Margem do baixo relevo ao redor do furo (mm)
relief_margin = 2; // [0.5:0.1:5]

/* [Bordas] */

// Raio de arredondamento das bordas externas (0 = sem arredondamento)
border_radius = 0; // [0:0.1:5]

/* [Furos de borda — interface lateral] */

// Diâmetro dos furos de borda (0 = sem furos de borda)
// Máximo seguro: thickness - 2mm de parede
edge_hole_d = 3; // [0:0.1:5]

// Profundidade dos furos de borda (mm)
edge_hole_depth = 4; // [1:0.5:10]

// Profundidade do rebaixo de borda — pocket entre os 2 furos
// de cada célula; recebe a alma do BRIDGE e a nervura do
// CORNER (0 = desativado)
edge_relief_depth = 1.5; // [0:0.1:3]

// Altura do rebaixo de borda, na direção da espessura (mm)
edge_relief_height = 2; // [0:0.1:4]

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

// Relief seguro — limitado a no máximo metade da espessura
// para garantir parede entre os dois relevos
safe_relief = min(relief_depth, (thickness / 2) - 0.5);

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
// Módulo: furo + baixo relevo em ambos os lados de uma célula
// ------------------------------------------------------------
module cell_hole() {
    // Furo passante em Z
    cylinder(d = hole_d, h = thickness + 1, center = true);

    // Baixo relevo face TOPO (+Z)
    // parte da face superior e vai para dentro
    translate([0, 0, thickness / 2 - safe_relief])
        cylinder(d = relief_d, h = safe_relief + 0.01);

    // Baixo relevo face BASE (-Z)
    // parte da face inferior e vai para dentro
    translate([0, 0, -thickness / 2])
        cylinder(d = relief_d, h = safe_relief + 0.01);
}

// ------------------------------------------------------------
// Módulo: grade de furos alinhada com o grid de ATOMs
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
// Módulo: furos de borda — 2 por célula, passo cell_size/2
// Centrados na espessura, em todas as 4 bordas
// Posições: centro da célula ± cell_size/4 → passo uniforme
// de 10mm inclusive atravessando junções entre PLATEs
// ------------------------------------------------------------
module edge_holes() {
    eps = 0.01;

    // Bordas +Y e -Y (furos ao longo do eixo X)
    for (ix = [0 : qty_x - 1], s = [-1, 1]) {
        x = ix * cell_size + cell_size / 2 + s * cell_size / 4 - total_x / 2;

        // Borda +Y — rotate([90,0,0]) aponta para -Y (fura para dentro)
        translate([x, total_y / 2 + eps, 0])
            rotate([90, 0, 0])
                cylinder(d = edge_hole_d, h = edge_hole_depth + eps);

        // Borda -Y — rotate NEGATIVO aponta para +Y
        translate([x, -total_y / 2 - eps, 0])
            rotate([-90, 0, 0])
                cylinder(d = edge_hole_d, h = edge_hole_depth + eps);
    }

    // Bordas +X e -X (furos ao longo do eixo Y)
    for (iy = [0 : qty_y - 1], s = [-1, 1]) {
        y = iy * cell_size + cell_size / 2 + s * cell_size / 4 - total_y / 2;

        // Borda +X — fura para dentro (-X)
        translate([total_x / 2 + eps, y, 0])
            rotate([0, -90, 0])
                cylinder(d = edge_hole_d, h = edge_hole_depth + eps);

        // Borda -X — fura para dentro (+X)
        translate([-total_x / 2 - eps, y, 0])
            rotate([0, 90, 0])
                cylinder(d = edge_hole_d, h = edge_hole_depth + eps);
    }
}

// ------------------------------------------------------------
// Módulo: rebaixos de borda — pocket entre os 2 furos de cada
// célula, centrado na espessura, nas 4 bordas
// ------------------------------------------------------------
module edge_reliefs() {
    eps = 0.01;
    len = cell_size / 2;   // vão entre os 2 furos da célula

    // Bordas +Y e -Y
    for (ix = [0 : qty_x - 1]) {
        xc = ix * cell_size + cell_size / 2 - total_x / 2;
        for (sy = [-1, 1])
            translate([xc, sy * (total_y / 2 - edge_relief_depth / 2 + eps / 2), 0])
                cube([len, edge_relief_depth + eps, edge_relief_height], center = true);
    }

    // Bordas +X e -X
    for (iy = [0 : qty_y - 1]) {
        yc = iy * cell_size + cell_size / 2 - total_y / 2;
        for (sx = [-1, 1])
            translate([sx * (total_x / 2 - edge_relief_depth / 2 + eps / 2), yc, 0])
                cube([edge_relief_depth + eps, len, edge_relief_height], center = true);
    }
}

// ------------------------------------------------------------
// Módulo: PLATE completa
// ------------------------------------------------------------
module plate() {
    difference() {
        plate_body();
        hole_grid();
        if (edge_hole_d > 0)
            edge_holes();
        if (edge_relief_depth > 0 && edge_relief_height > 0)
            edge_reliefs();
    }
}

// ============================================================
// RENDER
// ============================================================
part_color = [0.35, 0.38, 0.42];
color(part_color) plate();

// ============================================================
// INFO — dimensões no console
// ============================================================
echo("=== PLATE ===");
echo(str("Dimensões          : ", total_x, " × ", total_y, " × ", thickness, "mm (", qty_x, "×", qty_y, " células)"));
echo(str("Furos de face      : ", qty_x * qty_y, " × Ø", hole_d, "mm"));
echo(str("Furos de borda     : ", edge_hole_d > 0 ? str((qty_x + qty_y) * 4, " × Ø", edge_hole_d, "mm, prof. ", edge_hole_depth, "mm, passo ", cell_size / 2, "mm") : "desativados"));
echo(str("Rebaixos de borda  : ", edge_relief_depth > 0 ? str(cell_size / 2, " × ", edge_relief_depth, " × ", edge_relief_height, "mm por célula") : "desativados"));
echo("---");
echo(str("Parede nos furos de borda: ", edge_hole_d == 0 || thickness >= edge_hole_d + 2 ? "SIM (>= 1mm por lado)" : "VERIFICAR (thickness < edge_hole_d + 2)"));
