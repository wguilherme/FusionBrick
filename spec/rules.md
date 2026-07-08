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

Duas PLATEs encostadas borda a borda: furos de face ficam a `cell_size/2` de cada lado da junção → distância entre furos através da junção = `cell_size`. O grid se preserva automaticamente. Travamento **invisível** via [BRIDGE](parts/bridge.md) na interface de borda — pinos + alma enterrados, faces 100% livres, ATOM assenta sobre a junção.

## Interface de borda

Segunda interface do sistema, nas bordas das PLATEs — complementa os furos de face sem competir com eles:

- Furos de borda: `edge_hole_d = 3mm`, profundidade `4mm`, centrados na espessura
- 2 por célula, a centro ± `cell_size/4` → **passo uniforme de `cell_size/2 = 10mm`**, inclusive atravessando junções
- Rebaixo de borda: pocket `10 × 1.5 × 2mm` entre os 2 furos de cada célula — recebe alma do BRIDGE e nervura do CORNER
- Pinos receptores: `edge_hole_d - tolerance = 2.8mm`
- Usada por: [BRIDGE](parts/bridge.md) (junção coplanar invisível) e [CORNER](parts/corner.md) (junção 90°)

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
