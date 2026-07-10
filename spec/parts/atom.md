# ATOM

Unidade estrutural cúbica do sistema. Bloco base de construção.

## Geometria

- Forma: cubo `atom_size × atom_size × atom_size`
- Tamanho padrão: `20 × 20 × 20 mm`
- `border_radius` opcional para acabamento das arestas (padrão: `0`) + `border_style`: `round` (raio) ou `chamfer` (chanfro 45°)

## Furos

- **6 faces** — furo passante central em cada face
- Diâmetro do furo: `hole_d = 10mm`
- Rebaixo em ambas as extremidades de cada furo:
  - Diâmetro: `relief_d = hole_d + (relief_margin × 2) = 14mm`
  - Profundidade: `relief_depth = 2mm`

O rebaixo aloja o flange do LINK, garantindo face plana após montagem.

## Furos de borda

Interface lateral compatível com a PLATE — uma PLATE encostada ao lado de um ATOM conecta via dowels do [BRIDGE](bridge.md), respeitando o grid.

- **4 furos por face lateral** (por célula): 2 embaixo + 2 em cima
- Diâmetro `edge_hole_d = 3mm`, profundidade `edge_hole_depth = 4mm`
- Posição: a `edge_inset = 2.5mm` das extremidades (largura e altura) — mesmas posições dos furos de borda da PLATE
- Rebaixo do colar: boca de cada furo com `Ø3.8 × 1mm` — assenta o colar do pino (trava de profundidade)
- Aplicados apenas nas 4 faces laterais externas do grid (`edge_hole_d = 0` desativa)

## Instâncias múltiplas

Suporta grade `qty_x × qty_y × qty_z` de ATOMs unidos, com furos alinhados entre unidades adjacentes.

## Restrições

- `hole_d` deve ser menor que `atom_size / 2`
- `relief_d` deve caber dentro da face: `relief_d < atom_size`
- `border_radius` máximo: `atom_size / 2 - ε`
