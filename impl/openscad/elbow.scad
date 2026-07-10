// ============================================================
// ELBOW — Design System 3D Modular
// ============================================================
// Curva 90° da interface de borda. Liga duas vigas (CORNER/PIN)
// ou furos de borda perpendiculares com o canto externo
// ARREDONDADO — substitui a quina viva do encaixe em L.
//
// Vista de cima (plano X-Y):
//
//        ╭──────┐
//       ╱       │ ← porta B (pino → canal da viga em X)
//      │   ◜    │
//      │  ╱     │
//      └──┴─────┘
//         ↑ porta A (pino → canal da viga em Y)
//
// Corpo: varredura de 90° da seção sec × sec, raio externo =
// sec (ocupa exatamente o volume 5×5×5 da quina). Faces planas
// em Y=0 (porta A, aponta -Y) e X=0 (porta B, aponta -X).
//
// Cada porta pode ser PINO (entra no canal/furo da outra peça)
// ou FURO (recebe pino). Com as duas portas em "hole", um canal
// curvo Ø3 atravessa a peça — fio vira a esquina por dentro.
//
// Parâmetros:
// - sec             : seção da curva (= thickness da PLATE)
// - port_a / port_b : "pin" ou "hole" em cada ponta
// - edge_*          : interface de borda (igual ao sistema)
// ============================================================

/* [Portas] */

// Porta A — face Y=0 (aponta -Y)
port_a = "pin"; // [pin, hole]

// Porta B — face X=0 (aponta -X)
port_b = "pin"; // [pin, hole]

/* [Tamanho] */

// Seção da curva (= thickness da PLATE / seção do CORNER)
sec = 5; // [3:0.5:20]

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

/* [Bordas] */

// Raio de acabamento das arestas curvas (0 = arestas vivas)
// Aplica-se às 4 arestas que acompanham a curva; as faces das
// portas ficam planas para manter o encaixe flush
border_radius = 0; // [0:0.1:2]

// Estilo do acabamento das arestas: round (raio) ou chamfer (chanfro 45°)
border_style = "round"; // [round, chamfer]

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

// Centro das portas (= centro da seção)
c = sec / 2;

// Raio seguro — limitado pela seção
safe_radius = min(border_radius, sec / 2 - 0.01);

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
// Módulo: ELBOW completo
// Corpo ocupa o quarto de cilindro r=sec, z ∈ [0, sec]
// ------------------------------------------------------------
// Perfil da seção com acabamento nos cantos (round/chamfer)
module elbow_profile() {
    if (safe_radius <= 0) {
        square([sec, sec]);
    } else if (border_style == "chamfer") {
        offset(delta = safe_radius, chamfer = true)
            offset(delta = -safe_radius)
                square([sec, sec]);
    } else {
        offset(r = safe_radius)
            offset(delta = -safe_radius)
                square([sec, sec]);
    }
}

module elbow() {
    difference() {
        union() {
            // Corpo — varredura de 90° da seção (canto externo redondo)
            rotate_extrude(angle = 90)
                elbow_profile();

            // Pinos nas portas
            if (port_a == "pin")
                translate([c, 0, c]) rotate([90, 0, 0]) edge_pin();
            if (port_b == "pin")
                translate([0, c, c]) rotate([0, -90, 0]) edge_pin();
        }

        // Furos nas portas
        if (port_a == "hole")
            translate([c, 0, c]) rotate([-90, 0, 0]) rotate([180, 0, 0]) edge_hole_cut();
        if (port_b == "hole")
            translate([0, c, c]) rotate([0, 90, 0]) rotate([180, 0, 0]) edge_hole_cut();

        // Canal curvo — quando as duas portas são furo, o fio
        // vira a esquina por dentro da peça (arco de raio c
        // ligando os centros das duas portas, no plano z = c)
        if (port_a == "hole" && port_b == "hole")
            rotate_extrude(angle = 90)
                translate([c, c]) circle(d = edge_hole_d);
    }
}

// ============================================================
// RENDER
// ============================================================
part_color = [0.35, 0.38, 0.42];
color(part_color) elbow();

// ============================================================
// INFO — dimensões no console
// ============================================================
echo("=== ELBOW ===");
echo(str("Seção              : ", sec, " × ", sec, "mm, raio externo ", sec, "mm"));
echo(str("Portas             : A=", port_a, " B=", port_b));
echo(str("Pino               : Ø", edge_pin_d, "mm × ", edge_pin_len, "mm + colar Ø", collar_d, "mm × ", edge_collar_depth, "mm"));
echo(str("Canal curvo        : ", port_a == "hole" && port_b == "hole" ? str("Ø", edge_hole_d, "mm (fio vira a esquina)") : "não (precisa das 2 portas em hole)"));
echo(str("Tolerância         : ", tolerance, "mm"));
echo("---");
echo(str("Porta no centro da seção: ", c == sec / 2 ? "SIM" : "VERIFICAR"));