# BRIDGE

Dowel de junção coplanar. Pino duplo que atravessa a junção entre duas PLATEs (ou PLATE↔ATOM) encostadas borda a borda, entrando nos furos de borda de cada lado. Só pino → furo: nada acima ou abaixo da superfície, nenhum furo de face consumido.

## Geometria

```text
Vista de cima (junção vertical):

  PLATE A      │      PLATE B
       ━━━━━━━━┿━━━━━━━━      ← dowel Ø2.8 (metade em cada furo)
               │ ← peças ENCOSTADAS — gap zero
```

- **Dowel**: `edge_hole_d - tolerance = Ø2.8mm`, comprimento `7mm` (`edge_hole_depth - 0.5 = 3.5mm` em cada peça — não bate no fundo)
- **Colar central**: `Ø3.6 × 2mm` (1mm para cada lado da junção) — assenta nos rebaixos das duas bocas, garantindo divisão 50/50 da profundidade
- **Uso**: 2 dowels por junção — um em cada furo de borda do par de células (a `2.5mm` de cada extremidade) — para travar rotação

## Papel estrutural

- Cisalhamento e alinhamento entre as peças
- 2 dowels afastados = anti-rotação

## Uso

- Junção 100% invisível: faces de cima e de baixo lisas, ATOM assenta sobre a junção
- Sem canal de fio (seção Ø2.8 não comporta) — fios atravessam pelos furos de face, que ficam livres
- Serve PLATE↔PLATE e PLATE↔ATOM (o ATOM tem os mesmos furos de borda)

## Restrições

- Requer furos de borda nas duas peças (padrão em PLATE e ATOM)
- Não altera o passo do grid: peças encostadas, gap zero

## Histórico

- v1 (dogbone com flanges nos rebaixos de face): descartada — consumia furos de face e protruía `2mm`
- v2 (dowels + alma enterrada em rebaixo de borda): descartada — rebaixo removido em favor de interface pino→furo pura
