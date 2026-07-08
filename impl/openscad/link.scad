// ============================================================
// LINK — Design System 3D Modular
// ============================================================
// Peça de conexão entre dois furos do sistema modular.
// Une ATOM+ATOM, ATOM+PLATE, PLATE+PLATE ou qualquer
// combinação de peças com os mesmos parâmetros de furo.
//
// Estrutura (vista lateral):
//
//  [PEÇA 1]          [PEÇA 2]
//  ─────────┤                ├─────────
//   relevo  │                │  relevo
//  ─────────┤                ├─────────
//           │                │
//   ┌───────┤                ├───────┐
//   │  pin  ├────────────────┤  pin  │
//   │       │    [spacer]    │       │
//   └───────┤                ├───────┘
//
// Compatibilidade defaults:
//   ATOM  : atom_size=20, hole_d=10, relief_depth=2, relief_margin=2
//   PLATE : cell_size=20, thickness=5, hole_d=10, relief_depth=2, relief_margin=2
//
// Cálculo do pin_depth default:
//   PLATE é o caso mais restrito:
//   thickness(5) - relief_depth(2) = 3mm disponíveis → pin_depth = 3mm
//   Se encaixa na PLATE, encaixa no ATOM também ✅
//
// Parâmetros:
// - hole_d        : diâmetro do furo (igual ao ATOM/PLATE)
// - relief_depth  : profundidade do relevo (igual ao ATOM/PLATE)
// - relief_margin : margem ao redor do furo (igual ao ATOM/PLATE)
// - pin_depth     : profundidade que o pino entra no furo
// - spacer        : espaço entre as duas peças (0 = flush)
// - tolerance     : folga de encaixe (ajuste fino de impressão)
// - canal_d       : diâmetro do canal interno para fios (padrão 3mm = jumper Dupont; 0 = sólido)
// ============================================================

/* [Furos — manter igual ao ATOM/PLATE] */

// Diâmetro do furo (mm)
hole_d = 10; // [0.5:0.1:15]

// Profundidade do baixo relevo (mm)
relief_depth = 2; // [0.1:0.05:5]

// Margem do baixo relevo ao redor do furo (mm)
relief_margin = 2; // [0.5:0.1:5]

/* [Conector] */

// Profundidade que o pino entra em cada furo (mm)
// Default calculado para o caso mais restrito (PLATE thickness=5, relief=2 → 3mm disponíveis)
pin_depth = 3; // [1:0.5:20]

// Espaço entre as duas peças (0 = peças encostadas)
spacer = 0; // [0:0.5:20]

/* [Tolerância de impressão] */

// Folga de encaixe — reduz o conector para caber no furo
// Aumente se estiver apertado, reduza se estiver folgado
tolerance = 0.2; // [0:0.05:0.5]

/* [Canal interno para fios] */

// Diâmetro do canal interno para passagem de fios (0 = sólido)
// 6mm = passagem confortável para fios/cabos; zere para fechar
canal_d = 6; // [0:0.1:8]

/* [Qualidade] */
$fn = 32;

// ============================================================
// CALCULADOS
// ============================================================

// Diâmetro efetivo do pino (com tolerância)
pin_d = hole_d - tolerance;

// Diâmetro da flange que encaixa no relevo (com tolerância)
flange_d = hole_d + (relief_margin * 2) - tolerance;

// Altura total de cada metade = flange + pino
half_length = relief_depth + pin_depth;

// Comprimento total do LINK
total_length = (half_length * 2) + spacer;

// ============================================================
// MÓDULOS
// ============================================================

// ------------------------------------------------------------
// Módulo: metade do LINK (uma extremidade)
// Orientada em +Z a partir da origem
// ------------------------------------------------------------
module link_half() {
    // Flange — encaixa no baixo relevo da peça
    cylinder(d = flange_d, h = relief_depth);

    // Pino — entra no furo da peça
    translate([0, 0, relief_depth])
        cylinder(d = pin_d, h = pin_depth);
}

// ------------------------------------------------------------
// Módulo: LINK completo — simétrico, centrado na origem
// ------------------------------------------------------------
module link() {
    difference() {
        union() {
            // Metade superior (+Z)
            translate([0, 0, spacer / 2])
                link_half();

            // Metade inferior (-Z) — espelhada
            translate([0, 0, -spacer / 2])
                mirror([0, 0, 1])
                    link_half();

            // Spacer central (se > 0)
            if (spacer > 0)
                translate([0, 0, -spacer / 2])
                    cylinder(d = flange_d, h = spacer);
        }

        // Canal interno para fios (se canal_d > 0)
        if (canal_d > 0)
            translate([0, 0, -total_length / 2 - 0.01])
                cylinder(d = canal_d, h = total_length + 0.02);
    }
}

// ============================================================
// RENDER
// ============================================================
part_color = [0.35, 0.38, 0.42];
color(part_color) link();

// ============================================================
// INFO — dimensões no console
// ============================================================
echo("=== LINK ===");
echo(str("Comprimento total  : ", total_length, "mm"));
echo(str("Cada metade        : ", half_length, "mm"));
echo(str("Spacer central     : ", spacer, "mm"));
echo(str("Diâmetro do pino   : ", pin_d, "mm (furo receptor: ", hole_d, "mm)"));
echo(str("Diâmetro da flange : ", flange_d, "mm (relevo receptor: ", hole_d + relief_margin*2, "mm)"));
echo(str("Canal interno      : ", canal_d > 0 ? str(canal_d, "mm") : "sólido (canal fechado)"));
echo(str("Tolerância         : ", tolerance, "mm"));
echo("---");
echo(str("Compatível com PLATE thickness=5 : ", pin_depth <= 5 - relief_depth ? "SIM" : "VERIFICAR"));
echo(str("Compatível com ATOM  size=20     : ", pin_depth <= 20 - relief_depth ? "SIM" : "VERIFICAR"));
