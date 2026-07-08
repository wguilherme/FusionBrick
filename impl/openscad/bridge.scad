// ============================================================
// BRIDGE — Design System 3D Modular
// ============================================================
// Junção coplanar INVISÍVEL entre duas PLATEs encostadas
// borda a borda. Dois pinos (dowels) atravessam a junção
// entrando nos furos de borda, unidos por uma alma fina que
// fica enterrada nos rebaixos de borda das duas PLATEs.
//
// Vista de cima (junção vertical no centro):
//
//   PLATE A      │      PLATE B
//        ●━━━━━━━┿━━━━━━━●      ← pino Ø2.8 (furos de borda)
//        ┃▒▒▒▒▒▒▒│▒▒▒▒▒▒▒┃      ← alma nos rebaixos de borda
//        ●━━━━━━━┿━━━━━━━●      ← pino Ø2.8
//                │ ← plates ENCOSTADAS — gap zero
//
// A peça fica 100% enterrada: nenhum furo de face consumido,
// nenhuma protrusão. ATOMs assentam sobre a junção normalmente.
//
// Por que pinos + alma:
//   - pinos: cisalhamento e anti-rotação
//   - alma : resiste flexão/abertura da junção (dobradiça)
//
// Sem canal de fio: a seção Ø2.8 não comporta canal — fios
// atravessam a junção pelos furos de face, que ficam livres.
//
// Parâmetros:
// - cell_size         : passo do grid (pinos a cell_size/2)
// - edge_hole_d       : furo de borda da PLATE (igual à PLATE)
// - edge_hole_depth   : profundidade do furo de borda da PLATE
// - edge_relief_depth : profundidade do rebaixo de borda da PLATE
// - edge_relief_height: altura do rebaixo de borda da PLATE
// - tolerance         : folga de encaixe
// ============================================================

/* [Grid — manter igual à PLATE] */

// Passo do grid — pinos ficam a cell_size/2 entre si
cell_size = 20; // [5:1:100]

/* [Interface de borda — manter igual à PLATE] */

// Diâmetro do furo de borda da PLATE (mm)
edge_hole_d = 3; // [1:0.1:5]

// Profundidade do furo de borda da PLATE (mm)
edge_hole_depth = 4; // [1:0.5:10]

// Profundidade do rebaixo de borda da PLATE (mm)
edge_relief_depth = 1.5; // [0.5:0.1:3]

// Altura do rebaixo de borda da PLATE (mm)
edge_relief_height = 2; // [1:0.1:4]

/* [Tolerância de impressão] */

// Folga de encaixe — reduz pinos e alma para caber
tolerance = 0.2; // [0:0.05:0.5]

/* [Qualidade] */
$fn = 32;

// ============================================================
// CALCULADOS
// ============================================================

// Diâmetro efetivo do pino (com tolerância)
pin_d = edge_hole_d - tolerance;

// Meio-comprimento do pino em cada furo — menor que a
// profundidade do furo para não bater no fundo
pin_half_len = edge_hole_depth - 0.5;

// Comprimento total de cada pino (dowel)
pin_len = pin_half_len * 2;

// Alma — dimensões efetivas (com tolerância)
web_len    = cell_size / 2 - tolerance;          // entre os pinos
web_width  = edge_relief_depth * 2 - tolerance;  // através da junção
web_height = edge_relief_height - tolerance;     // na espessura

// ============================================================
// MÓDULOS
// ============================================================

// ------------------------------------------------------------
// Módulo: BRIDGE completa — centrada na origem
// Junção no plano X=0; pinos ao longo de X em Y ± cell_size/4
// ------------------------------------------------------------
module bridge() {
    // Pinos (dowels) — atravessam a junção
    for (y = [-cell_size / 4, cell_size / 4])
        translate([-pin_half_len, y, 0])
            rotate([0, 90, 0])
                cylinder(d = pin_d, h = pin_len);

    // Alma — enterrada nos rebaixos de borda das duas PLATEs
    cube([web_width, web_len, web_height], center = true);
}

// ============================================================
// RENDER
// ============================================================
part_color = [0.35, 0.38, 0.42];
color(part_color) bridge();

// ============================================================
// INFO — dimensões no console
// ============================================================
echo("=== BRIDGE ===");
echo(str("Pinos              : 2 × Ø", pin_d, "mm × ", pin_len, "mm (", pin_half_len, "mm em cada PLATE)"));
echo(str("Passo entre pinos  : ", cell_size / 2, "mm (= cell_size/2)"));
echo(str("Alma               : ", web_width, " × ", web_len, " × ", web_height, "mm"));
echo(str("Tolerância         : ", tolerance, "mm"));
echo("---");
echo(str("Pino cabe no furo (prof. ", edge_hole_depth, "mm): ", pin_half_len < edge_hole_depth ? "SIM" : "VERIFICAR"));
echo(str("Alma cabe no rebaixo             : ", web_height < edge_relief_height && web_width < edge_relief_depth * 2 ? "SIM" : "VERIFICAR"));