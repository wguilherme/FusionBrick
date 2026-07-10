// ============================================================
// ATOM — Design System 3D Modular
// ============================================================
// Unidade base do sistema de encaixe modular.
// Cada ATOM é um cubo com furos passantes em todas as 6 faces
// e um baixo relevo ao redor de cada furo.
//
// Parâmetros editáveis:
// - atom_size     : tamanho base de 1 ATOM (mm)
// - qty_x         : quantidade de ATOMs no eixo X
// - qty_y         : quantidade de ATOMs no eixo Y
// - qty_z         : quantidade de ATOMs no eixo Z
// - hole_d        : diâmetro do furo passante (mm)
// - relief_depth  : profundidade do baixo relevo (mm)
// - relief_margin : margem do baixo relevo ao redor do furo (mm)
// - border_radius : raio de arredondamento das arestas (mm)
// ============================================================

/* [Tamanho do ATOM] */

// Tamanho base de 1 ATOM (mm)
atom_size = 20; // [5:1:100]

// Raio de arredondamento das arestas (0 = sem arredondamento)
border_radius = 0; // [0:0.1:5]

// Estilo do acabamento das arestas: round (raio) ou chamfer (chanfro 45°)
border_style = "round"; // [round, chamfer]

/* [Quantidade de ATOMs] */

// Quantidade de ATOMs no eixo X
qty_x = 1; // [1:1:10]

// Quantidade de ATOMs no eixo Y
qty_y = 1; // [1:1:10]

// Quantidade de ATOMs no eixo Z
qty_z = 1; // [1:1:10]

/* [Furos] */

// Diâmetro do furo passante (mm)
hole_d = 10; // [0.5:0.1:15]

// Profundidade do baixo relevo ao redor do furo (mm)
relief_depth = 2; // [0.1:0.05:5]

// Margem do baixo relevo ao redor do furo (mm)
relief_margin = 2; // [0.5:0.1:5]

/* [Furos de borda — interface lateral, compatível com PLATE] */

// Diâmetro dos furos de borda (0 = sem furos de borda)
edge_hole_d = 3; // [0:0.1:5]

// Profundidade dos furos de borda (mm)
edge_hole_depth = 4; // [1:0.5:10]

// Distância do centro do furo até a extremidade (= thickness/2 da PLATE)
edge_inset = 2.5; // [1:0.25:5]

// Rebaixo na boca do furo — recebe o colar do pino (trava de
// profundidade). Largura radial = 1 bico de 0.4mm (0 = sem rebaixo)
edge_collar_w = 0.4; // [0:0.1:1]

// Profundidade do rebaixo do colar (mm)
edge_collar_depth = 1; // [0.5:0.25:2]

/* [Qualidade] */

// Segmentos dos cilindros e esferas (mais = mais suave, mais lento)
$fn = 32;

// ============================================================
// CALCULADOS
// ============================================================

// Diâmetro total do baixo relevo
relief_d = hole_d + (relief_margin * 2);

// Raio seguro — não pode ser maior que metade do atom_size
safe_radius = min(border_radius, atom_size / 2 - 0.01);

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
// Módulo: cubo com acabamento de aresta via minkowski
// Quando border_radius = 0, usa cubo simples (mais rápido)
// ------------------------------------------------------------
module rounded_cube(size, r) {
    if (r <= 0) {
        cube([size, size, size], center = true);
    } else {
        // Minkowski de um cubo menor + sólido de acabamento
        // O cubo interno é reduzido em 2*r para manter o tamanho externo
        inner = size - 2 * r;
        minkowski() {
            cube([inner, inner, inner], center = true);
            border_finish(r);
        }
    }
}

// ------------------------------------------------------------
// Módulo: um único ATOM centrado na origem
// ------------------------------------------------------------
module atom_unit() {
    difference() {
        // Corpo principal (com ou sem border radius)
        rounded_cube(atom_size, safe_radius);

        // ---- EIXO Z — furo passante (topo → base) ----
        cylinder(d = hole_d, h = atom_size + 1, center = true);

        // Baixo relevo face TOPO (+Z)
        translate([0, 0, atom_size / 2 - relief_depth])
            cylinder(d = relief_d, h = relief_depth + 0.01);

        // Baixo relevo face BASE (-Z)
        translate([0, 0, -atom_size / 2])
            cylinder(d = relief_d, h = relief_depth + 0.01);

        // ---- EIXO X — furo passante (direita → esquerda) ----
        rotate([0, 90, 0])
            cylinder(d = hole_d, h = atom_size + 1, center = true);

        // Baixo relevo face +X
        translate([atom_size / 2 - relief_depth, 0, 0])
            rotate([0, 90, 0])
                cylinder(d = relief_d, h = relief_depth + 0.01);

        // Baixo relevo face -X
        translate([-atom_size / 2, 0, 0])
            rotate([0, 90, 0])
                cylinder(d = relief_d, h = relief_depth + 0.01);

        // ---- EIXO Y — furo passante (frente → trás) ----
        rotate([90, 0, 0])
            cylinder(d = hole_d, h = atom_size + 1, center = true);

        // Baixo relevo face +Y
        translate([0, atom_size / 2, 0])
            rotate([90, 0, 0])
                cylinder(d = relief_d, h = relief_depth + 0.01);

        // Baixo relevo face -Y
        translate([0, -atom_size / 2, 0])
            rotate([-90, 0, 0])
                cylinder(d = relief_d, h = relief_depth + 0.01);
    }
}

// ------------------------------------------------------------
// Módulo: grid de ATOMs — qty_x * qty_y * qty_z
// ------------------------------------------------------------
module atom_grid() {
    for (ix = [0 : qty_x - 1])
        for (iy = [0 : qty_y - 1])
            for (iz = [0 : qty_z - 1])
                translate([
                    ix * atom_size + atom_size / 2,
                    iy * atom_size + atom_size / 2,
                    iz * atom_size + atom_size / 2
                ])
                atom_unit();
}

// ------------------------------------------------------------
// Módulo: furos de borda — 4 por face lateral (2 embaixo + 2
// em cima por célula), nas extremidades: edge_inset das bordas.
// Compatível com os furos de borda da PLATE — uma PLATE ao lado
// de um ATOM conecta via BRIDGE, respeitando o grid.
// Aplicados só nas 4 faces laterais EXTERNAS do grid.
// ------------------------------------------------------------
// Furo de borda: bore Ø3 + rebaixo do colar na boca
module atom_edge_hole_cut() {
    eps = 0.01;
    cylinder(d = edge_hole_d, h = edge_hole_depth + eps);
    if (edge_collar_w > 0)
        cylinder(d = edge_hole_d + 2 * edge_collar_w, h = edge_collar_depth + eps);
}

module atom_edge_holes() {
    eps = 0.01;
    total_x = qty_x * atom_size;
    total_y = qty_y * atom_size;

    // Posições ao longo da largura (por célula) e alturas (por camada)
    xs = [ for (c = [0 : qty_x - 1], s = [0, 1]) c * atom_size + edge_inset + s * (atom_size - 2 * edge_inset) ];
    ys = [ for (c = [0 : qty_y - 1], s = [0, 1]) c * atom_size + edge_inset + s * (atom_size - 2 * edge_inset) ];
    zs = [ for (c = [0 : qty_z - 1], s = [0, 1]) c * atom_size + edge_inset + s * (atom_size - 2 * edge_inset) ];

    for (z = zs) {
        // Faces +Y / -Y (furos ao longo de X)
        for (x = xs) {
            translate([x, total_y + eps, z])
                rotate([90, 0, 0])
                    atom_edge_hole_cut();
            translate([x, -eps, z])
                rotate([-90, 0, 0])
                    atom_edge_hole_cut();
        }
        // Faces +X / -X (furos ao longo de Y)
        for (y = ys) {
            translate([total_x + eps, y, z])
                rotate([0, -90, 0])
                    atom_edge_hole_cut();
            translate([-eps, y, z])
                rotate([0, 90, 0])
                    atom_edge_hole_cut();
        }
    }
}

// ------------------------------------------------------------
// Módulo: ATOM completo — grid + interface de borda
// ------------------------------------------------------------
module atom() {
    difference() {
        atom_grid();
        if (edge_hole_d > 0)
            atom_edge_holes();
    }
}

// ============================================================
// RENDER
// ============================================================
part_color = [0.35, 0.38, 0.42];
color(part_color) atom();

// ============================================================
// INFO — dimensões no console
// ============================================================
echo("=== ATOM ===");
echo(str("Dimensões          : ", qty_x * atom_size, " × ", qty_y * atom_size, " × ", qty_z * atom_size, "mm (", qty_x, "×", qty_y, "×", qty_z, ")"));
echo(str("Furos de borda     : ", edge_hole_d > 0 ? str("Ø", edge_hole_d, "mm, prof. ", edge_hole_depth, "mm, a ", edge_inset, "mm das extremidades (4/face lateral por célula)") : "desativados"));
