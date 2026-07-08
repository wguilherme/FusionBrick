# BRIDGE

Junção coplanar **invisível** entre duas PLATEs encostadas borda a borda. Dois pinos (dowels) + alma fina, tudo enterrado na interface de borda — nenhum furo de face consumido, nenhuma protrusão.

## Geometria

```text
Vista de cima (junção vertical):

  PLATE A      │      PLATE B
       ●━━━━━━━┿━━━━━━━●      ← pino Ø2.8 × 7mm (furos de borda)
       ┃▒▒▒▒▒▒▒│▒▒▒▒▒▒▒┃      ← alma nos rebaixos de borda
       ●━━━━━━━┿━━━━━━━●      ← pino Ø2.8 × 7mm
               │ ← plates ENCOSTADAS — gap zero
```

- **Pinos** (×2): `edge_hole_d - tolerance = 2.8mm`, comprimento `7mm` (`edge_hole_depth - 0.5` em cada PLATE — não bate no fundo)
- **Passo entre pinos**: `cell_size/2 = 10mm` (= passo da interface de borda)
- **Alma**: `2.8 × 9.8 × 1.8mm` — enterrada nos rebaixos de borda das duas PLATEs (`1.4mm` pra cada lado da junção)

## Papel estrutural

- Pinos: cisalhamento e anti-rotação
- Alma: resiste flexão/abertura da junção (sem ela, a junção dobra como dobradiça)

## Uso

- 1 BRIDGE por par de células adjacentes através da junção
- Junção fica invisível: faces de cima e de baixo 100% lisas, ATOMs assentam sobre a junção
- Sem canal de fio (seção Ø2.8 não comporta) — fios atravessam pelos furos de face, que ficam livres

## Restrições

- Requer PLATE com interface de borda completa (furos + rebaixos)
- Não altera o passo do grid: plates encostadas, gap zero

## Histórico

- v1 (dogbone com flanges nos rebaixos de face): descartada — consumia furos de face e protruía `2mm` acima da superfície
