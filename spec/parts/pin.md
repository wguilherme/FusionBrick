# PIN

Viga conectora universal da interface de borda. Parente do [CORNER](corner.md), mas totalmente configurável: cada grupo de faces (topo, base, laterais, pontas) pode ter **pino**, **furo** ou nada.

## Geometria

- **Corpo**: prisma `sec_w × sec_h × (cells × cell_size)` — padrão `5 × 5 × 20mm` (seção = espessura da PLATE)
- **Posições**: nas extremidades de cada célula, a `edge_inset = 2.5mm` dos limites — mesmas posições de toda a interface de borda
- **Pino**: colar `Ø3.6 × 1mm` na raiz + haste `Ø2.8`, total `3.5mm`
- **Furo**: bore `Ø3 × 4mm` + rebaixo do colar `Ø3.8 × 1mm` na boca
- Pontas (±Y): 1 feature axial centrado na seção
- **Acabamento**: `border_radius` (padrão `0`) + `border_style` `round`/`chamfer` nas arestas da viga
- Furos opostos se encontram (4+4 > 5) e viram furo passante — esperado

## Configuração

| Grupo | Parâmetro | Opções |
| --- | --- | --- |
| Topo (+Z) | `face_top` | `pin` / `hole` / `none` |
| Base (−Z) | `face_bottom` | `pin` / `hole` / `none` |
| Laterais (±X) | `face_sides` | `pin` / `hole` / `none` |
| Pontas (±Y) | `face_ends` | `pin` / `hole` / `none` |

## Presets

| `preset` | Topo | Base | Laterais | Pontas | Uso |
| --- | --- | --- | --- | --- | --- |
| `full_pins_hole_bottom` | pino | furo | pino | pino | espalhar conexões a partir de uma base |
| `full_holes` | furo | furo | furo | furo | hub fêmea universal — recebe pinos de qualquer peça |
| `custom` (padrão) | `face_*` | `face_*` | `face_*` | `face_*` | qualquer combinação |

## Compatibilidade

- Pinos entram em qualquer furo de borda do sistema (PLATE, ATOM, CORNER via canal, outro PIN)
- Furos recebem pinos de CORNER, dowels de BRIDGE e pinos de outro PIN
- Encaixe em L igual ao CORNER: feature da ponta fica no centro da seção
