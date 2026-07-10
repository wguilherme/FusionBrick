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

// Estilo do acabamento das arestas: round (raio) ou chamfer (chanfro 45°)
border_style = "round"; // [round, chamfer]

/* [Furos de borda — interface lateral] */

// Diâmetro dos furos de borda (0 = sem furos de borda)
// Máximo seguro: thickness - 2mm de parede
edge_hole_d = 3; // [0:0.1:5]

// Profundidade dos furos de borda (mm)
edge_hole_depth = 4; // [1:0.5:10]

// Distância do centro do furo até a extremidade da célula
// (= thickness/2 — alinha com o centro da seção do CORNER)
edge_inset = 2.5; // [1:0.25:5]

// Rebaixo na boca do furo — recebe o colar do pino (trava de
// profundidade). Largura radial = 1 bico de 0.4mm (0 = sem rebaixo)
edge_collar_w = 0.4; // [0:0.1:1]

// Profundidade do rebaixo do colar (mm)
edge_collar_depth = 1; // [0.5:0.25:2]

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
// Módulo: corpo da placa com acabamento de aresta opcional
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
            border_finish(safe_radius);
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
// Módulo: furos de borda — 2 por célula, NAS EXTREMIDADES:
// a edge_inset (= thickness/2) de cada limite da célula.
// Centrados na espessura, em todas as 4 bordas.
// Dentro da célula os furos distam cell_size - 2*edge_inset;
// através de uma junção distam 2*edge_inset — o centro de cada
// furo alinha com o centro da seção do CORNER (thickness/2)
// ------------------------------------------------------------
// Furo de borda: bore Ø3 + rebaixo do colar na boca
module edge_hole_cut() {
    eps = 0.01;
    cylinder(d = edge_hole_d, h = edge_hole_depth + eps);
    if (edge_collar_w > 0)
        cylinder(d = edge_hole_d + 2 * edge_collar_w, h = edge_collar_depth + eps);
}

module edge_holes() {
    eps = 0.01;

    // Bordas +Y e -Y (furos ao longo do eixo X)
    for (ix = [0 : qty_x - 1], s = [-1, 1]) {
        x = ix * cell_size + cell_size / 2 + s * (cell_size / 2 - edge_inset) - total_x / 2;

        // Borda +Y — rotate([90,0,0]) aponta para -Y (fura para dentro)
        translate([x, total_y / 2 + eps, 0])
            rotate([90, 0, 0])
                edge_hole_cut();

        // Borda -Y — rotate NEGATIVO aponta para +Y
        translate([x, -total_y / 2 - eps, 0])
            rotate([-90, 0, 0])
                edge_hole_cut();
    }

    // Bordas +X e -X (furos ao longo do eixo Y)
    for (iy = [0 : qty_y - 1], s = [-1, 1]) {
        y = iy * cell_size + cell_size / 2 + s * (cell_size / 2 - edge_inset) - total_y / 2;

        // Borda +X — fura para dentro (-X)
        translate([total_x / 2 + eps, y, 0])
            rotate([0, -90, 0])
                edge_hole_cut();

        // Borda -X — fura para dentro (+X)
        translate([-total_x / 2 - eps, y, 0])
            rotate([0, 90, 0])
                edge_hole_cut();
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
echo(str("Furos de borda     : ", edge_hole_d > 0 ? str((qty_x + qty_y) * 4, " × Ø", edge_hole_d, "mm, prof. ", edge_hole_depth, "mm, a ", edge_inset, "mm das extremidades") : "desativados"));
echo("---");
echo(str("Parede nos furos de borda: ", edge_hole_d == 0 || thickness >= edge_hole_d + 2 ? "SIM (>= 1mm por lado)" : "VERIFICAR (thickness < edge_hole_d + 2)"));
