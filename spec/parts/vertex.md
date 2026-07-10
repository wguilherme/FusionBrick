# VERTEX

Quina 3-vias com ponta arredondada. Une as 3 peças que convergem num vértice — base + 2 paredes de uma caixa, ou 3 vigas [CORNER](corner.md)/[PIN](pin.md) nas arestas.

## Geometria

- **Corpo**: cubo `sec × sec × sec` (padrão `5×5×5`)
- **Ponta externa** (`+X,+Y,+Z`): acabada com `border_radius = 2mm` (padrão do sistema) — `border_style = "round"` (esfera) ou `"chamfer"` (facetas retas 45°). As arestas externas ficam vivas — continuam flush com a seção quadrada das vigas
- **3 faces internas** (`X=0`, `Y=0`, `Z=0`): cada uma com `pin` / `hole` / `none` no **centro da face** (`sec/2 = 2.5mm`)
  - Pino: colar Ø3.6×1 + haste Ø2.8, total 3.5mm
  - Furo: bore Ø3×4 + rebaixo Ø3.8×1

## Alinhamento

O centro da face (`2.5, 2.5`) alinha simultaneamente com:

- o canal axial de uma viga CORNER/PIN encostada na face
- o furo de borda no canto de uma PLATE (que fica a `2.5mm` das duas bordas)

→ o VERTEX pina direto em vigas ou em cantos de PLATEs, sem adaptador.

## Passagem de fio

Com 2+ faces em `hole`, os bores (4mm > sec/2) se encontram no centro do cubo — **fio vira a esquina por dentro** (junção em T/L interna).

## Restrições

- `border_radius` máximo: `sec/2 - ε`
- Não altera o passo do grid: ocupa o volume do vértice que as 3 peças deixam livre
