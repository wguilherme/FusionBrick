# Parâmetros Globais

Valores que devem ser idênticos em todas as peças. Se divergirem, os furos não alinham.

| Parâmetro | Valor | Descrição |
| --- | --- | --- |
| `cell_size` / `atom_size` | `20mm` | Unidade base do grid |
| `hole_d` | `10mm` | Diâmetro do furo passante |
| `relief_depth` | `2mm` | Profundidade do rebaixo |
| `relief_margin` | `2mm` | Margem do rebaixo → `relief_d = hole_d + relief_margin×2 = 14mm` |
| `tolerance` | `0.2mm` | Subtraída de pinos/flanges para press-fit |
| `canal_d` | `6mm` | Canal axial para fios em todo conector (0 = fechado) |
| `thickness` | `5mm` | Espessura padrão da PLATE — mínimo `(relief_depth×2)+1` |
| `pin_depth` | `3mm` | Profundidade do pino — caso mais restrito: PLATE (`thickness−relief_depth`) |
| `edge_hole_d` | `3mm` | Furo de borda da PLATE (0 = desativado) |
| `edge_hole_depth` | `4mm` | Profundidade do furo de borda |
| `edge_relief_depth` | `1.5mm` | Profundidade do rebaixo de borda (0 = desativado) |
| `edge_relief_height` | `2mm` | Altura do rebaixo de borda |
| `$fn` | `32` | Segmentos de cilindro |

## Derivados

```text
relief_d  = hole_d + relief_margin*2      = 14mm
pin_d     = hole_d - tolerance            = 9.8mm
flange_d  = relief_d - tolerance          = 13.8mm
```
