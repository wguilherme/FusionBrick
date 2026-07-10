# Regras do Sistema

Regras de compatibilidade que toda peça e toda junção devem respeitar.

## Lei do Grid

> **O volume do grid é delimitado pelas faces internas das PLATEs. A espessura da PLATE vive sempre FORA do grid.**

Consequências:

1. **Superfície da base é plano do grid** — atoms assentam diretamente sobre ela; centro do atom fica a `cell_size/2` da superfície.
2. **Parede perpendicular** assenta com a borda inferior sobre a superfície da base e a face interna num plano do grid; a espessura projeta para fora.
3. **Primeiro furo de qualquer PLATE** fica a `cell_size/2` da borda → furos de parede ficam a `cell_size/2` acima da superfície da base → alinham com os furos laterais de um ATOM assentado na base.
4. Nenhuma junção pode alterar o passo do grid (`cell_size`). Peças de junção (LINK, BRIDGE, CORNER) conectam furos existentes sem inserir espaçamento.

## Junção coplanar (lado a lado)

Duas PLATEs encostadas borda a borda: furos de face ficam a `cell_size/2` de cada lado da junção → distância entre furos através da junção = `cell_size`. O grid se preserva automaticamente. Travamento **invisível** via dowels [BRIDGE](parts/bridge.md) na interface de borda (2 por junção) — faces 100% livres, ATOM assenta sobre a junção.

## Interface de borda

Segunda interface do sistema, nas bordas de PLATEs e faces laterais de ATOMs — complementa os furos de face sem competir com eles. Interface pura pino → furo, sem rebaixos:

- Furos de borda: `edge_hole_d = 3mm`, profundidade `4mm`, centrados na espessura
- 2 por célula, **nas extremidades**: a `edge_inset = 2.5mm` (= `thickness/2`) de cada limite da célula
- Distâncias: `15mm` dentro da célula; `5mm` através de junções — cada furo alinha com o centro da seção do CORNER (`5/2 = 2.5mm`)
- ATOM: 4 furos por face lateral (2 embaixo + 2 em cima), mesmas posições → PLATE ao lado de ATOM conecta direto
- **Rebaixo do colar**: boca de todo furo de borda ganha rebaixo `Ø3.8 × 1mm` (`edge_collar_w = 0.4` radial); todo pino tem colar `Ø3.6 × 1mm` na raiz → trava de profundidade (dowel divide 50/50, pino não afunda) e reforço da raiz
- Pinos receptores: `edge_hole_d - tolerance = 2.8mm`
- Usada por: [BRIDGE](parts/bridge.md) (dowel de junção coplanar), [CORNER](parts/corner.md) (junção 90° e L de corners), [PIN](parts/pin.md) (viga conectora configurável), [ELBOW](parts/elbow.md) (curva 90° arredondada), [VERTEX](parts/vertex.md) (quina 3-vias com ponta arredondada)

Vantagem estrutural: junções por borda deixam furos de face e rebaixos 100% livres — LINK e ATOM conectam em qualquer célula, inclusive nas do canto.

## Junção perpendicular (90°)

Base e parede se encontram borda-com-borda, deixando uma lacuna de `thickness × thickness` no canto externo. A viga [CORNER](parts/corner.md) preenche essa lacuna e pina nos furos de borda das duas PLATEs — nada protrui, interior 100% livre. Alternativa zero-peças: ATOM na célula do canto + 2 LINKs (custo: célula ocupada).

Verificação canônica — U (`|_|`) com base de `n` células e duas paredes: interior = exatamente `n` células livres; um ATOM entra em qualquer célula e conecta na base e nas paredes.

## Passagem elétrica

Todo conector (LINK, BRIDGE, CORNER) tem canal axial `canal_d = 6mm` por padrão em cada ponta de encaixe — fio/jumper atravessa qualquer junção. `canal_d = 0` fecha o canal (opt-out, nunca default).

## Furos laterais em PLATE

Impossíveis por construção: `hole_d (10mm) > thickness (5mm)`. Toda junção envolvendo PLATE usa os furos das faces (topo/base) — os rebaixos existem em ambas as faces exatamente por isso.

## Tolerância

`tolerance = 0.2mm` subtraída de todo pino e flange para press-fit. Ajuste por impressora: aumentar se apertar, diminuir se folgar.
