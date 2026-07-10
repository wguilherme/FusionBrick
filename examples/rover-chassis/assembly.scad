// ============================================================
// ASSEMBLY — Rover de rally (carroceria aberta + gaiola)
// ============================================================
// Buggy de rally construído com as peças default do sistema:
// piso de PLATEs, capô e deck traseiro de PLATEs empilhadas
// via LINK, e gaiola tubular de PINs — com ELBOWs arredondando
// os 4 cantos do chassi e VERTEXes nos cantos 3-vias do teto.
//
// Vista lateral (X-Z):
//
//        ╭────────────────╮        ← gaiola z=50 (VERTEX nos cantos)
//        │                │
//        │    cockpit     │        ← postes de PIN duplo
//   ▄▄▄▄▄│    aberto      │▄▄▄▄▄   ← capô / deck z=10
//   ═════╧════════════════╧═════   ← piso 4×3 células, z=5
//  ╰ elbow                elbow ╯  ← cantos arredondados
//
// Grid: piso 4×3 (80×60mm). Trilhos laterais de CORNER fora do
// grid (Lei do Grid), postes de PIN sobre os pinos dos trilhos,
// para-choques de PIN nas bordas frente/trás, ELBOWs fechando
// os cantos com curva. Tudo pelas interfaces do sistema.
// ============================================================

use <../../impl/openscad/plate.scad>
use <../../impl/openscad/link.scad>
use <../../impl/openscad/bridge.scad>
use <../../impl/openscad/corner.scad>
use <../../impl/openscad/pin.scad>
use <../../impl/openscad/elbow.scad>
use <../../impl/openscad/vertex.scad>

/* [Montagem] */

// Explodir a montagem (mm de afastamento entre camadas)
explode = 0; // [0:1:30]

// Renderizar interseções entre peças (vermelho = colisão)
// IMPORTANTE: só funciona com render completo (F6 / --render)
check_collisions = false;

// Ocultar as peças e mostrar SÓ as colisões
collisions_only = false;

// ============================================================
// CONSTANTES DO LAYOUT
// ============================================================
// Piso x 0..80, y 0..60, z 0..5
// Trilhos laterais em y -5..0 e 60..65 (fora do grid)
// Postes da gaiola em x=17.5 e x=62.5 (pinos dos trilhos)
// Teto da gaiola z 45..50

ez1 = explode;        // nível 1 (capô/deck, trilhos, bumpers)
ez2 = explode * 2;    // nível 2 (postes)
ez3 = explode * 3;    // nível 3 (teto da gaiola)

// ============================================================
// PISO + CAPÔ + DECK
// ============================================================

// Piso 4×3 — 12 plates 1×1
module floor_plates() {
    for (cx = [0 : 3], cy = [0 : 2])
        translate([cx * 20 + 10, cy * 20 + 10, 2.5])
            plate();
}

// Dowels das junções do piso
module floor_dowels() {
    for (sx = [1 : 3], cy = [0 : 2], y = [2.5, 17.5])
        translate([sx * 20, cy * 20 + y, 2.5]) bridge();
    for (sy = [1 : 2], cx = [0 : 3], x = [2.5, 17.5])
        translate([cx * 20 + x, sy * 20, 2.5]) rotate([0, 0, 90]) bridge();
}

// Capô — 3 plates empilhadas sobre a frente do piso (via LINK)
module hood_plates() {
    for (cy = [0 : 2])
        translate([10, cy * 20 + 10, 7.5 + ez1]) plate();
}

// Deck traseiro — 3 plates empilhadas sobre a traseira
module deck_plates() {
    for (cy = [0 : 2])
        translate([70, cy * 20 + 10, 7.5 + ez1]) plate();
}

// LINKs do capô e do deck (piso ↔ plate de cima)
module hood_deck_links() {
    for (cy = [0 : 2]) {
        translate([10, cy * 20 + 10, 5 + ez1 / 2]) link();
        translate([70, cy * 20 + 10, 5 + ez1 / 2]) link();
    }
}

// ============================================================
// TRILHOS LATERAIS + PARA-CHOQUES + ELBOWS (nível do chassi)
// ============================================================

// Trilhos laterais — CORNERs ao longo das bordas y=0 e y=60,
// pinos horizontais nos furos de borda do piso, pinos verticais
// para cima (recebem os postes da gaiola)
module side_rails() {
    // Modelo do corner: viga x -5..0, comprimento em Y, pinos
    // +X (horizontais) e +Z (verticais). Rz(90) → viga ao longo
    // de X em y -5..0, pinos +Y (entram na borda do piso) e +Z.
    for (cx = [0 : 3]) {
        // Lado y=0
        translate([cx * 20 + 20, -ez1, 0])
            rotate([0, 0, 90]) corner();
        // Lado y=60 — espelhado
        translate([cx * 20 + 20, 60 + ez1, 0])
            mirror([0, 1, 0]) rotate([0, 0, 90]) corner();
    }
}

// Para-choques — PINs deitados nas bordas x=0 e x=80,
// presos por dowels nos furos de borda do piso
module bumpers() {
    for (cy = [0 : 2]) {
        translate([-2.5 - ez1, cy * 20, 2.5]) pin();
        translate([82.5 + ez1, cy * 20, 2.5]) pin();
    }
}

// Dowels dos para-choques (furos laterais do PIN ↔ borda do piso)
module bumper_dowels() {
    for (cy = [0 : 2], y = [2.5, 17.5]) {
        translate([-ez1 / 2, cy * 20 + y, 2.5]) bridge();
        translate([80 + ez1 / 2, cy * 20 + y, 2.5]) bridge();
    }
}

// ELBOWs — arredondam os 4 cantos do chassi, ligando a ponta
// do para-choque ao canal axial do trilho lateral
module chassis_elbows() {
    // frente-esquerda: corpo em x -5..0, y -5..0
    translate([-ez1, -ez1, 0]) mirror([1, 0, 0]) mirror([0, 1, 0]) elbow();
    // frente-direita
    translate([-ez1, 60 + ez1, 0]) mirror([1, 0, 0]) elbow();
    // trás-esquerda
    translate([80 + ez1, -ez1, 0]) mirror([0, 1, 0]) elbow();
    // trás-direita
    translate([80 + ez1, 60 + ez1, 0]) elbow();
}

// ============================================================
// GAIOLA (roll cage)
// ============================================================

// Postes — PIN duplo empilhado (z 5..45) sobre os pinos
// verticais dos trilhos, em x=17.5 e x=62.5
post_xs = [17.5, 62.5];
post_ys = [-2.5, 62.5];

// PIN em pé: Rx(90) leva a viga (eixo Y) para +Z; os studs do
// topo apontam -Y — espelha no lado direito pra ficarem pra fora
module cage_posts() {
    for (px = post_xs, pz = [5, 25]) {
        // Lado esquerdo (y=-2.5) — studs pra fora (-Y)
        translate([px, -2.5 - ez1, pz + ez2 + (pz > 5 ? ez1 : 0)])
            rotate([90, 0, 0]) pin();
        // Lado direito (y=62.5) — espelhado, studs pra fora (+Y)
        translate([px, 62.5 + ez1, pz + ez2 + (pz > 5 ? ez1 : 0)])
            mirror([0, 1, 0]) rotate([90, 0, 0]) pin();
    }
}

// Dowels axiais entre os dois PINs de cada poste (z=25)
module post_dowels() {
    for (px = post_xs, py = post_ys)
        translate([px, py, 25 + ez2 + ez1 / 2])
            rotate([0, -90, 0]) bridge();
}

// VERTEXes — cantos 3-vias do teto da gaiola (z 45..50):
// pino pra baixo (poste), pino longitudinal (trilho do teto)
// e pino transversal (travessa)
module cage_vertices() {
    // frente-esquerda: cubo em 15..20, -5..0 — pinos +X, +Y, -Z
    translate([20, 0, 45 + ez3]) mirror([1, 0, 0]) mirror([0, 1, 0]) vertex();
    // frente-direita: pinos +X, -Y, -Z
    translate([20, 60, 45 + ez3]) mirror([1, 0, 0]) vertex();
    // trás-esquerda: pinos -X, +Y, -Z
    translate([60, 0, 45 + ez3]) mirror([0, 1, 0]) vertex();
    // trás-direita: pinos -X, -Y, -Z
    translate([60, 60, 45 + ez3]) vertex();
}

// Travessas do teto — 3 PINs ao longo de Y em cada arco
module cage_cross_beams() {
    for (x = [17.5, 62.5], cy = [0 : 2])
        translate([x, cy * 20, 47.5 + ez3]) pin();
}

// Dowels entre as travessas (y=20 e y=40)
module cross_dowels() {
    for (x = [17.5, 62.5], sy = [1 : 2])
        translate([x, sy * 20, 47.5 + ez3])
            rotate([0, 0, 90]) bridge();
}

// Trilhos longitudinais do teto — 2 PINs (x 20..60) por lado
module cage_long_rails() {
    for (py = post_ys, cx = [0 : 1])
        translate([20 + cx * 20, py, 47.5 + ez3])
            rotate([0, 0, -90]) pin();
}

// Dowels dos trilhos longitudinais (x=40)
module long_rail_dowels() {
    for (py = post_ys)
        translate([40, py, 47.5 + ez3]) bridge();
}

// ============================================================
// MONTAGEM
// ============================================================

if (!collisions_only) {
    // Piso — grafite escuro
    color([0.25, 0.27, 0.30]) floor_plates();

    // Capô e deck — cinza claro (carroceria)
    color([0.75, 0.77, 0.80]) { hood_plates(); deck_plates(); }

    // Gaiola + trilhos + bumpers + curvas — laranja rally
    color([0.85, 0.45, 0.15]) {
        side_rails(); bumpers(); chassis_elbows();
        cage_posts(); cage_vertices();
        cage_cross_beams(); cage_long_rails();
    }

    // Conectores
    color([0.85, 0.75, 0.20]) hood_deck_links();
    color([0.10, 0.65, 0.45]) {
        floor_dowels(); bumper_dowels();
        post_dowels(); cross_dowels(); long_rail_dowels();
    }
}

// ============================================================
// TESTE DE COLISÃO — interseções par a par em vermelho
// ============================================================
if (check_collisions || collisions_only) {
    color([1, 0, 0]) {
        intersection() { floor_plates(); side_rails(); }
        intersection() { floor_plates(); bumpers(); }
        intersection() { floor_plates(); hood_plates(); }
        intersection() { floor_plates(); deck_plates(); }
        intersection() { side_rails(); chassis_elbows(); }
        intersection() { bumpers(); chassis_elbows(); }
        intersection() { side_rails(); cage_posts(); }
        intersection() { cage_posts(); cage_vertices(); }
        intersection() { cage_vertices(); cage_cross_beams(); }
        intersection() { cage_vertices(); cage_long_rails(); }
        intersection() { cage_posts(); post_dowels(); }
    }
}
