// ============================================================
// BRIDGE — Design System 3D Modular
// ============================================================
// Dowel de junção coplanar: pino duplo que atravessa a junção
// entre duas PLATEs (ou PLATE↔ATOM) encostadas borda a borda,
// entrando nos furos de borda de cada lado.
//
// Vista de cima (junção vertical no centro):
//
//   PLATE A      │      PLATE B
//        ━━━━━━━━┿━━━━━━━━      ← dowel Ø2.8 (metade em cada furo)
//                │ ← peças ENCOSTADAS — gap zero
//
// Junção 100% invisível: nenhum furo de face consumido, nada
// acima ou abaixo da superfície. Usar 2 dowels por junção
// (um em cada furo de borda do par de células) para travar
// rotação.
//
// Sem canal de fio: a seção Ø2.8 não comporta canal — fios
// atravessam a junção pelos furos de face, que ficam livres.
//
// Parâmetros:
// - edge_hole_d     : furo de borda da PLATE/ATOM (igual às peças)
// - edge_hole_depth : profundidade do furo de borda
// - tolerance       : folga de encaixe
// ============================================================

/* [Interface de borda — manter igual à PLATE/ATOM] */

// Diâmetro do furo de borda (mm)
edge_hole_d = 3; // [1:0.1:5]

// Profundidade do furo de borda (mm)
edge_hole_depth = 4; // [1:0.5:10]

// Rebaixo do colar na boca dos furos (manter igual à PLATE/ATOM)
// Colar central no dowel: trava de profundidade — divide 50/50
edge_collar_w = 0.4; // [0:0.1:1]

// Profundidade do rebaixo / meia-altura do colar (mm)
edge_collar_depth = 1; // [0.5:0.25:2]

/* [Tolerância de impressão] */

// Folga de encaixe — reduz o pino para caber no furo de borda
tolerance = 0.2; // [0:0.05:0.5]

/* [Qualidade] */
$fn = 32;

// ============================================================
// CALCULADOS
// ============================================================

// Diâmetro efetivo do pino (com tolerância)
pin_d = edge_hole_d - tolerance;

// Diâmetro do colar central (assenta nos rebaixos das duas bocas)
collar_d = edge_hole_d + 2 * edge_collar_w - tolerance;

// Meio-comprimento em cada furo — menor que a profundidade
// do furo para não bater no fundo
pin_half_len = edge_hole_depth - 0.5;

// Comprimento total do dowel
pin_len = pin_half_len * 2;

// ============================================================
// MÓDULOS
// ============================================================

// ------------------------------------------------------------
// Módulo: BRIDGE — dowel centrado na origem, eixo X
// (junção fica no plano X = 0)
// ------------------------------------------------------------
module bridge() {
    // Corpo do dowel
    translate([-pin_half_len, 0, 0])
        rotate([0, 90, 0])
            cylinder(d = pin_d, h = pin_len);

    // Colar central — 1 edge_collar_depth para cada lado da junção,
    // assenta nos rebaixos das bocas dos dois furos
    if (edge_collar_w > 0)
        translate([-edge_collar_depth, 0, 0])
            rotate([0, 90, 0])
                cylinder(d = collar_d, h = edge_collar_depth * 2);
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
echo(str("Dowel              : Ø", pin_d, "mm × ", pin_len, "mm (", pin_half_len, "mm em cada peça)"));
echo(str("Colar central      : ", edge_collar_w > 0 ? str("Ø", collar_d, "mm × ", edge_collar_depth * 2, "mm (trava 50/50)") : "sem colar"));
echo(str("Tolerância         : ", tolerance, "mm"));
echo("Uso                : 2 dowels por junção (um por furo de borda do par de células)");
echo("---");
echo(str("Pino cabe no furo (prof. ", edge_hole_depth, "mm): ", pin_half_len < edge_hole_depth ? "SIM" : "VERIFICAR"));
