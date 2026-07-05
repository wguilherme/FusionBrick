# PLATE

Superfície plana modular. Grid de furos alinhado ao ATOM.

## Geometria

- Forma: placa plana `(cell_size × qty_x) × (cell_size × qty_y) × thickness`
- `cell_size` deve ser igual ao `atom_size` do ATOM para garantir alinhamento
- `thickness` mínima: `(relief_depth × 2) + 1mm` → padrão mínimo: `5mm`
- `border_radius` opcional (padrão: `0`)

## Furos

- Grid `qty_x × qty_y` de furos, um por célula, centralizado em cada célula
- Diâmetro: `hole_d = 10mm`
- Rebaixo em **ambas as faces**:
  - Diâmetro: `relief_d = 14mm`
  - Profundidade: `safe_relief = min(relief_depth, thickness/2 - 0.5)`

## Compatibilidade

Ao encostar duas PLATEs lado a lado, a distância entre furos na junção é `cell_size/2 + cell_size/2 = cell_size` — mesma distância do grid interno. Furos coincidem matematicamente com qualquer peça do sistema.

## Restrições

- `thickness < relief_depth × 2` invalida a peça — implementação deve aplicar `safe_relief` automaticamente
- `border_radius` máximo: `min(thickness/2, cell_size/2) - ε`
