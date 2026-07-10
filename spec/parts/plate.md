# PLATE

Superfície plana modular. Grid de furos alinhado ao ATOM.

## Geometria

- Forma: placa plana `(cell_size × qty_x) × (cell_size × qty_y) × thickness`
- `qty_x` e `qty_y`: padrão `1` (unidade mínima — 1×1 = 20×20mm)
- `cell_size` deve ser igual ao `atom_size` do ATOM para garantir alinhamento
- `thickness` mínima: `(relief_depth × 2) + 1mm` → padrão mínimo: `5mm`
- `border_radius` opcional (padrão: `0`) + `border_style`: `round` (raio) ou `chamfer` (chanfro 45°)

## Furos

- Grid `qty_x × qty_y` de furos, um por célula, centralizado em cada célula
- Diâmetro: `hole_d = 10mm`
- Rebaixo em **ambas as faces**:
  - Diâmetro: `relief_d = 14mm`
  - Profundidade: `safe_relief = min(relief_depth, thickness/2 - 0.5)`

## Furos de borda

Interface lateral nas 4 bordas — recebe os pinos do [CORNER](corner.md) e os dowels do [BRIDGE](bridge.md), sem consumir furos de face nem rebaixos. Só pino → furo, sem rebaixos laterais.

- Diâmetro: `edge_hole_d = 3mm` (máximo seguro: `thickness - 2mm` de parede; `0` desativa)
- Profundidade: `edge_hole_depth = 4mm`
- Posição: centrados na espessura; 2 por célula, **nas extremidades** — a `edge_inset = 2.5mm` (= `thickness/2`) de cada limite da célula
- Distâncias resultantes: `15mm` entre os furos da mesma célula; `5mm` entre furos através de junções — cada furo alinha com o centro da seção do CORNER
- Rebaixo do colar: boca de cada furo com `Ø3.8 × 1mm` — assenta o colar do pino (trava de profundidade)
- Nota: furos perpendiculares próximos ao mesmo canto se cruzam internamente (profundidade 4 > inset 2.5) — esperado; o pino mantém agarre na maior parte da circunferência

## Compatibilidade

Ao encostar duas PLATEs lado a lado, a distância entre furos na junção é `cell_size/2 + cell_size/2 = cell_size` — mesma distância do grid interno. Furos coincidem matematicamente com qualquer peça do sistema.

- Junção coplanar: travar com [BRIDGE](bridge.md)
- Junção perpendicular (90°): travar com [CORNER](corner.md)
- Regras completas: [Lei do Grid](../rules.md)

## Restrições

- `thickness < relief_depth × 2` invalida a peça — implementação deve aplicar `safe_relief` automaticamente
- `border_radius` máximo: `min(thickness/2, cell_size/2) - ε`
