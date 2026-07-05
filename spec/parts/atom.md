# ATOM

Unidade estrutural cúbica do sistema. Bloco base de construção.

## Geometria

- Forma: cubo `atom_size × atom_size × atom_size`
- Tamanho padrão: `20 × 20 × 20 mm`
- `border_radius` opcional para cantos arredondados (padrão: `0`)

## Furos

- **6 faces** — furo passante central em cada face
- Diâmetro do furo: `hole_d = 10mm`
- Rebaixo em ambas as extremidades de cada furo:
  - Diâmetro: `relief_d = hole_d + (relief_margin × 2) = 14mm`
  - Profundidade: `relief_depth = 2mm`

O rebaixo aloja o flange do LINK, garantindo face plana após montagem.

## Instâncias múltiplas

Suporta grade `qty_x × qty_y × qty_z` de ATOMs unidos, com furos alinhados entre unidades adjacentes.

## Restrições

- `hole_d` deve ser menor que `atom_size / 2`
- `relief_d` deve caber dentro da face: `relief_d < atom_size`
- `border_radius` máximo: `atom_size / 2 - ε`
