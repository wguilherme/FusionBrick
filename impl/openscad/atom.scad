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
border_radius = 1; // [0:0.1:5]

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
// Módulo: cubo com border radius via minkowski + esfera
// Quando border_radius = 0, usa cubo simples (mais rápido)
// ------------------------------------------------------------
module rounded_cube(size, r) {
    if (r <= 0) {
        cube([size, size, size], center = true);
    } else {
        // Minkowski de um cubo menor + esfera = cubo arredondado
        // O cubo interno é reduzido em 2*r para manter o tamanho externo
        inner = size - 2 * r;
        minkowski() {
            cube([inner, inner, inner], center = true);
            sphere(r = r);
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

// ============================================================
// RENDER
// ============================================================
atom_grid();
