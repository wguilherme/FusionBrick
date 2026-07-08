// ============================================================
// ASSEMBLY — Canal em U (teste de encaixe)
// ============================================================
// Montagem programática: base de 3 PLATEs 1×1 unidas por
// 2 BRIDGEs invisíveis + 2 paredes 1×1 + 2 vigas CORNER +
// 1 ATOM no interior conectado por 2 LINKs.
//
// Verificações da Lei do Grid (spec/rules.md):
//   - junção coplanar: 3 plates encostadas, passo do grid
//     preservado através das 2 junções (BRIDGEs enterradas)
//   - junção 90°: vigas CORNER preenchem as lacunas dos cantos
//   - ATOM entra em qualquer célula interior e alinha
//
// `use` importa apenas os módulos — o render top-level de cada
// peça não executa. Os módulos usam os parâmetros default dos
// próprios arquivos.
//
// Sistema de coordenadas:
//   base    x ∈ [0,60] (3 plates), y ∈ [0,20], z ∈ [0,5]
//   junções x = 20 e x = 40 (BRIDGEs)
//   paredes x ∈ [-5,0] e [60,65], z ∈ [5,25]
//   vigas   preenchem as lacunas dos cantos (5×5×20)
//   atom    primeira célula, centro em (10,10,15)
//
// Teste de colisão: mude check_collisions=true — qualquer
// volume vermelho = interferência entre peças.
// IMPORTANTE: só funciona com render completo (F6 / --render),
// o preview (F5) não calcula intersection() entre módulos.
// ============================================================

use <../../impl/openscad/plate.scad>
use <../../impl/openscad/corner.scad>
use <../../impl/openscad/atom.scad>
use <../../impl/openscad/link.scad>
use <../../impl/openscad/bridge.scad>

/* [Montagem] */

// Mostrar o ATOM + LINKs no interior
show_atom = true;

// Explodir a montagem (mm de afastamento entre peças)
explode = 0; // [0:1:30]

// Renderizar interseções entre peças (vermelho = colisão)
check_collisions = false;

// Ocultar as peças e mostrar SÓ as colisões
// (com --render + export STL: arquivo vazio = sem colisão)
collisions_only = false;

// ============================================================
// PEÇAS POSICIONADAS
// ============================================================

// Base: 3 plates 1×1 lado a lado (células em x ∈ [0,60])
module base_plates() {
    for (i = [0 : 2])
        translate([10 + i * (20 + explode), 10, 2.5])
            plate();
}

// BRIDGEs enterradas nas junções x=20 e x=40
module base_bridges() {
    for (i = [1 : 2])
        translate([i * 20 + (i - 0.5) * explode, 10, 2.5])
            bridge();
}

module wall_left() {
    translate([-2.5 - explode, 10, 15 + explode])
        rotate([0, 90, 0]) plate();
}

module corner_left() {
    translate([-explode / 2, 0, explode / 2]) corner();
}

module wall_right() {
    translate([60 + 2 * explode, 0, 0]) mirror([1, 0, 0]) wall_left();
}

module corner_right() {
    translate([60 + 2.5 * explode, 0, 0]) mirror([1, 0, 0]) corner();
}

module inner_atom() {
    translate([10, 10, 15 + explode * 2]) atom_unit();
}

module inner_links() {
    // LINK vertical — atom ↔ furo da base
    translate([10, 10, 5 + explode]) link();
    // LINK horizontal — atom ↔ furo da parede esquerda
    translate([0 - explode / 2, 10, 15 + explode * 2])
        rotate([0, 90, 0]) link();
}

// ============================================================
// MONTAGEM
// ============================================================

if (!collisions_only) {
    color([0.35, 0.38, 0.42]) base_plates();
    color([0.10, 0.65, 0.45]) base_bridges();
    color([0.45, 0.48, 0.52]) { wall_left(); wall_right(); }
    color([0.85, 0.45, 0.15]) { corner_left(); corner_right(); }

    if (show_atom) {
        color([0.20, 0.55, 0.75]) inner_atom();
        color([0.85, 0.75, 0.20]) inner_links();
    }
}

// ============================================================
// TESTE DE COLISÃO — interseções par a par em vermelho
// ============================================================
if (check_collisions || collisions_only) {
    color([1, 0, 0]) {
        intersection() { base_plates(); base_bridges();  }
        intersection() { base_plates(); corner_left();   }
        intersection() { base_plates(); corner_right();  }
        intersection() { wall_left();   corner_left();   }
        intersection() { wall_right();  corner_right();  }
        intersection() { base_plates(); wall_left();     }
        intersection() { base_plates(); wall_right();    }
        if (show_atom) {
            intersection() { inner_atom(); wall_left();   }
            intersection() { inner_atom(); base_plates(); }
        }
    }
}
