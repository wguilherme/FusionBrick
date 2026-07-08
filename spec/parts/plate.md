# PLATE

Superfície plana modular. Grid de furos alinhado ao ATOM.

## Geometria

- Forma: placa plana `(cell_size × qty_x) × (cell_size × qty_y) × thickness`
- `qty_x` e `qty_y`: padrão `1` (unidade mínima — 1×1 = 20×20mm)
- `cell_size` deve ser igual ao `atom_size` do ATOM para garantir alinhamento
- `thickness` mínima: `(relief_depth × 2) + 1mm` → padrão mínimo: `5mm`
- `border_radius` opcional (padrão: `0`)

## Furos

- Grid `qty_x × qty_y` de furos, um por célula, centralizado em cada célula
- Diâmetro: `hole_d = 10mm`
- Rebaixo em **ambas as faces**:
  - Diâmetro: `relief_d = 14mm`
  - Profundidade: `safe_relief = min(relief_depth, thickness/2 - 0.5)`

## Furos de borda

Interface lateral nas 4 bordas — recebe pinos do [CORNER](corner.md) e futuros dowels, sem consumir furos de face nem rebaixos.

- Diâmetro: `edge_hole_d = 3mm` (máximo seguro: `thickness - 2mm` de parede; `0` desativa)
- Profundidade: `edge_hole_depth = 4mm`
- Posição: centrados na espessura; 2 por célula, centro da célula ± `cell_size/4`
- Passo resultante: `cell_size/2 = 10mm`, uniforme inclusive atravessando junções entre PLATEs

### Rebaixo de borda

Pocket raso entre os 2 furos de cada célula, em todas as bordas — recebe a alma do [BRIDGE](bridge.md) e a nervura do [CORNER](corner.md):

- Dimensões: `cell_size/2 × edge_relief_depth × edge_relief_height` = `10 × 1.5 × 2mm`
- Centrado na espessura; `edge_relief_depth = 0` desativa

## Compatibilidade

Ao encostar duas PLATEs lado a lado, a distância entre furos na junção é `cell_size/2 + cell_size/2 = cell_size` — mesma distância do grid interno. Furos coincidem matematicamente com qualquer peça do sistema.

- Junção coplanar: travar com [BRIDGE](bridge.md)
- Junção perpendicular (90°): travar com [CORNER](corner.md)
- Regras completas: [Lei do Grid](../rules.md)

## Restrições

- `thickness < relief_depth × 2` invalida a peça — implementação deve aplicar `safe_relief` automaticamente
- `border_radius` máximo: `min(thickness/2, cell_size/2) - ε`
