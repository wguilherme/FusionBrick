# LINK

Conector universal. Une quaisquer dois furos do sistema — ATOM↔ATOM, PLATE↔PLATE, ATOM↔PLATE.

## Geometria

Peça simétrica em dois sentidos, composta por dois semi-links espelhados:

```text
[flange] [pin →] [spacer?] [← pin] [flange]
```

- **Flange**: assenta no rebaixo (`relief_d`), mantém face plana
  - Diâmetro: `flange_d = relief_d - tolerance`
  - Altura: `relief_depth`
- **Pin**: entra no furo passante
  - Diâmetro: `pin_d = hole_d - tolerance`
  - Profundidade: `pin_depth` (varia por contexto — ver abaixo)
- **Spacer** (opcional): haste entre os dois flanges para conectar peças com gap
  - Comprimento: `spacer` (padrão: `0`)
- **Canal** (padrão aberto): furo axial para passagem de fio/cabo
  - Diâmetro: `canal_d` (padrão: `6mm` — passagem confortável para fios/cabos)
  - Zerar (`canal_d = 0`) fecha o canal; aumentar para cabos mais grossos

## Tolerância

`tolerance = 0.2mm` subtraída de `flange_d` e `pin_d` para press-fit.  
Aumentar se apertar; diminuir se folgar.

## pin_depth por contexto

| Contexto | pin_depth recomendado |
| --- | --- |
| ATOM ↔ ATOM | `3mm` |
| ATOM ↔ PLATE | `3mm` |
| PLATE ↔ PLATE (empilhadas) | `3mm` |

Junções coplanares e a 90° não usam LINK — ver [BRIDGE](bridge.md) e [CORNER](corner.md) (interface de borda).

## Comprimento total

`total_length = (relief_depth + pin_depth) × 2 + spacer`
