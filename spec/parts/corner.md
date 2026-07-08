# CORNER

Viga de canto. Preenche a lacuna `wall_thickness × plate_thickness` que sobra quando duas PLATEs se encontram a 90° borda-com-borda. Conecta via **furos de borda** — furos de face e rebaixos ficam 100% livres para LINKs e ATOMs.

## Geometria

```text
      │ │ parede
      │ │
      └┬┘ ← borda inferior da parede
   ┌─┐ ▲ pinos ↑ furos de borda da parede
   │▓├►┌──────────── base
   └─┘ └──────────── pinos → furos de borda da base
    ↑ viga preenche a lacuna (thickness × thickness)
```

- **Corpo**: prisma `wall_thickness × plate_thickness × (cells × cell_size)`
- **Pinos** em 2 faces perpendiculares: `edge_pin_d = edge_hole_d - tolerance = 2.8mm`, comprimento `3.5mm` (< profundidade do furo de borda, para não bater no fundo)
- **Posições**: 2 pinos por célula, centro da célula ± `cell_size/4` → passo uniforme `cell_size/2 = 10mm` (ver [interface de borda](../rules.md))
- **Nervuras** (padrão ativas): preenchem os rebaixos de borda das duas PLATEs — `9.8 × 1.3 × 1.8mm` por célula em cada face; + cisalhamento e anti-deslizamento
- **Canal**: `canal_d = 3mm` axial ao longo da viga — passa jumper Dupont (0 = fechado)

## Lei do Grid — preservada

- Face interna da parede num plano do grid; borda inferior no plano da superfície da base
- Furo da parede a `cell_size/2` da superfície → ATOM assentado na base alinha
- **Nada protrui**: faces externas da viga ficam flush com a base (embaixo) e a parede (fora)
- Furos de face intocados → LINK/ATOM conectam em qualquer furo, inclusive nas células do canto

## Alternativas

- **ATOM como corner** (zero peças novas): ATOM na célula do canto + 2 LINKs — custo: célula ocupada
- Bracket externo em L: descartado — protruía sob a base e consumia furos de face

## Restrições

- Requer PLATE com furos de borda (`edge_hole_d = 3mm`, padrão)
- `cells` da viga deve corresponder ao comprimento da junção
- Pinos Ø2.8 em FDM são finos — a resistência vem da quantidade (2 por célula) e do corpo da viga preenchendo a lacuna
