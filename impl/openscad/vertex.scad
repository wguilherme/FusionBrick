// ============================================================
// VERTEX — Design System 3D Modular
// ============================================================
// Quina 3-vias com ponta arredondada. Une as 3 peças que
// convergem num vértice (ex: base + 2 paredes de uma caixa,
// ou 3 vigas CORNER/PIN nas arestas).
//
//            ╭────╮  ← ponta externa ARREDONDADA
//          ╱      │
//         │  cubo │ ←  corpo 5×5×5
//         │ 5×5×5 │
//    -X ← ┤       ├
//         └───┬───┘
//        -Y ↙  ↓ -Z    ← 3 faces internas com pino/furo
//
// Faces internas: X=0 (aponta -X), Y=0 (-Y), Z=0 (-Z) — cada
// uma com pino/furo no CENTRO da face (sec/2 = 2.5mm), que
// alinha com o canal axial das vigas E com os furos de borda
// no canto de uma PLATE.
//
// Ponta externa (+X,+Y,+Z) arredondada com raio r_tip.
//
// Com 2+ faces em "hole", os furos se encontram no centro do
// cubo (profundidade 4 > 2.5) — fio vira a esquina por dentro.
//
// Parâmetros:
// - sec              : lado do cubo (= thickness da PLATE)
// - face_x/_y/_z     : "pin", "hole" ou "none" por face
// - r_tip            : raio do arredondamento da ponta externa
// - edge_*           : interface de borda (igual ao sistema)
// ============================================================

/* [Faces internas] */

// Face X=0 (aponta -X)
face_x = "pin"; // [pin, hole, none]

// Face Y=0 (aponta -Y)
face_y = "pin"; // [pin, hole, none]

// Face Z=0 (aponta -Z)
face_z = "pin"; // [pin, hole, none]

/* [Tamanho] */

// Lado do cubo (= thickness da PLATE / seção do CORNER)
sec = 5; // [3:0.5:20]

/* [Bordas] */

// Raio do acabamento da ponta externa (padrão do sistema)
border_radius = 2; // [0:0.25:5]

// Estilo do acabamento: round (esfera) ou chamfer (facetado reto)
border_style = "round"; // [round, chamfer]

/* [Interface de borda — manter igual à PLATE/ATOM] */

// Diâmetro do furo de borda (mm)
edge_hole_d = 3; // [1:0.1:5]

// Profundidade do furo de borda (mm)
edge_hole_depth = 4; // [1:0.5:10]

// Comprimento total do pino (colar + haste)
edge_pin_len = 3.5; // [1:0.25:9]

// Largura radial do rebaixo/colar (0 = desativado)
edge_collar_w = 0.4; // [0:0.1:1]

// Profundidade do rebaixo / altura do colar (mm)
edge_collar_depth = 1; // [0.5:0.25:2]

/* [Tolerância de impressão] */

// Folga de encaixe
tolerance = 0.2; // [0:0.05:0.5]

/* [Qualidade] */
$fn = 48;

// ============================================================
// CALCULADOS
// ============================================================

edge_pin_d = edge_hole_d - tolerance;
collar_d   = edge_hole_d + 2 * edge_collar_w - tolerance;
recess_d   = edge_hole_d + 2 * edge_collar_w;

// Centro das faces
c = sec / 2;

// Raio seguro da ponta
safe_tip = min(border_radius, sec / 2 - 0.01);

// ============================================================
// MÓDULOS
// ============================================================

// Pino com colar na raiz — orientado em +Z a partir da origem
module edge_pin() {
    if (edge_collar_w > 0)
        cylinder(d = collar_d, h = edge_collar_depth);
    cylinder(d = edge_pin_d, h = edge_pin_len);
}

// Furo com rebaixo do colar — fura em -Z a partir da superfície
module edge_hole_cut() {
    eps = 0.01;
    rotate([180, 0, 0]) {
        cylinder(d = edge_hole_d, h = edge_hole_depth + eps);
        if (edge_collar_w > 0)
            cylinder(d = recess_d, h = edge_collar_depth + eps);
    }
}

// ------------------------------------------------------------
// Módulo: sólido de acabamento da ponta — esfera (round) ou
// octaedro (chamfer: facetas retas 45°)
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
// Módulo: corpo do vertex — cubo com a ponta (+X,+Y,+Z)
// acabada. Hull de 3 lajes (que preservam as faces internas
// planas) + sólido de acabamento no canto externo.
// border_radius = 0 → cubo de ponta viva.
// ------------------------------------------------------------
module vertex_body() {
    if (safe_tip <= 0) {
        cube([sec, sec, sec]);
    } else {
        hull() {
            cube([sec - safe_tip, sec, sec]);
            cube([sec, sec - safe_tip, sec]);
            cube([sec, sec, sec - safe_tip]);
            translate([sec - safe_tip, sec - safe_tip, sec - safe_tip])
                border_finish(safe_tip);
        }
    }
}

// ------------------------------------------------------------
// Módulo: VERTEX completo
// ------------------------------------------------------------
module vertex() {
    difference() {
        union() {
            vertex_body();

            // Pinos nas faces internas
            if (face_x == "pin")
                translate([0, c, c]) rotate([0, -90, 0]) edge_pin();
            if (face_y == "pin")
                translate([c, 0, c]) rotate([90, 0, 0]) edge_pin();
            if (face_z == "pin")
                translate([c, c, 0]) rotate([180, 0, 0]) edge_pin();
        }

        // Furos nas faces internas (se cruzam no centro — fio
        // vira a esquina por dentro quando 2+ faces são furo)
        if (face_x == "hole")
            translate([0, c, c]) rotate([0, 90, 0]) rotate([180, 0, 0]) edge_hole_cut();
        if (face_y == "hole")
            translate([c, 0, c]) rotate([-90, 0, 0]) rotate([180, 0, 0]) edge_hole_cut();
        if (face_z == "hole")
            translate([c, c, 0]) rotate([180, 0, 0]) edge_hole_cut();
    }
}

// ============================================================
// RENDER
// ============================================================
part_color = [0.35, 0.38, 0.42];
color(part_color) vertex();

// ============================================================
// INFO — dimensões no console
// ============================================================
echo("=== VERTEX ===");
echo(str("Cubo               : ", sec, " × ", sec, " × ", sec, "mm, ponta r=", safe_tip, "mm (", border_style, ")"));
echo(str("Faces              : X=", face_x, " Y=", face_y, " Z=", face_z));
echo(str("Pino               : Ø", edge_pin_d, "mm × ", edge_pin_len, "mm + colar Ø", collar_d, "mm × ", edge_collar_depth, "mm"));
echo(str("Furo               : Ø", edge_hole_d, "mm × ", edge_hole_depth, "mm + rebaixo Ø", recess_d, "mm × ", edge_collar_depth, "mm"));
echo(str("Tolerância         : ", tolerance, "mm"));
echo("---");
echo(str("Feature no centro da face (alinha com canal/furo de borda): ", c == sec / 2 ? "SIM" : "VERIFICAR"));