<div align="center">

🌐 **Português** | [English](README.en.md)

# FusionBrick

**Sistema de design modular open-source para makers, engenheiros e construtores.**

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![OpenSCAD](https://img.shields.io/badge/OpenSCAD-v2021+-green.svg)](https://openscad.org)
[![Version](https://img.shields.io/badge/version-0.1.0-brightgreen.svg)](CHANGELOG.md)

</div>

---

FusionBrick é um sistema de peças modulares paramétricas para impressão 3D. Qualquer peça conecta em qualquer outra — em qualquer face, em qualquer direção — via press-fit, sem ferramentas.

![ATOM conectado via LINK](.github/assets/image1.png)

---

## As Peças

| | **ATOM** | **PLATE** | **LINK** |
| --- | --- | --- | --- |
| | ![ATOM](renders/img/atom.png) | ![PLATE](renders/img/plate.png) | ![LINK](renders/img/link.png) |
| **Função** | Unidade cúbica. Furos passantes em 6 faces. | Superfície plana. Furos alinhados ao ATOM. | Conector universal entre quaisquer dois furos. |
| **Fonte** | `impl/openscad/atom.scad` | `impl/openscad/plate.scad` | `impl/openscad/link.scad` |

---

## Parâmetros Globais

Todos os parâmetros abaixo devem ser iguais entre as peças para garantir compatibilidade.

```
cell_size     = 20mm   // unidade base da grade
hole_d        = 10mm   // diâmetro do furo
relief_depth  = 2mm    // profundidade do rebaixo
relief_margin = 2mm    // margem do rebaixo
tolerance     = 0.2mm  // tolerância de impressão (ajuste por impressora)
```

---

## Início Rápido

**Requisitos:** [OpenSCAD 2021+](https://openscad.org/downloads.html), impressora FDM, PLA ou PETG.

```bash
git clone https://github.com/wguilherme/FusionBrick.git
cd FusionBrick
open impl/openscad/atom.scad   # abre no OpenSCAD
```

Dentro do OpenSCAD: `F6` para renderizar → `File → Export → Export as STL`.

**Gerar todos os previews e STLs via Make:**

```bash
make preview   # gera renders/img/*.png
make build     # gera renders/stl/*.stl
```

---

## Estrutura

```
FusionBrick/
├── spec/          ← especificação independente de ferramenta
├── impl/
│   ├── openscad/  ← implementação OpenSCAD ✅
│   ├── fusion360/ ← planejado
│   └── manual/    ← planejado
├── renders/
│   ├── img/       ← previews PNG
│   └── stl/       ← STLs exportados
└── examples/      ← montagens de exemplo
```

---

## Roadmap

### v0.1.0 — Fundação ✅

- [x] ATOM, PLATE, LINK
- [x] Implementação OpenSCAD
- [x] Especificação do sistema

### v0.2.0 — Paramétrico

- [ ] Seleção de padrão de furos (bordas, cantos, todos)
- [ ] Suporte multi-escala (10mm, 20mm, 30mm)
- [ ] Upload MakerWorld PMM

### v0.3.0+ — Futuro

- [ ] Canais para condução elétrica
- [ ] Conectores magnéticos
- [ ] Plugin Fusion 360

---

## Implementações

| Implementação | Status |
| --- | --- |
| OpenSCAD | ✅ Ativo |
| Fusion 360 | 🔜 Planejado |
| FreeCAD | 🔜 Planejado |
| MakerWorld PMM | 🔜 Planejado |

Quer contribuir? [Abra uma issue](https://github.com/wguilherme/FusionBrick/issues) ou envie um PR.

---

Feito com ❤️ por makers, para makers — [@wguilherme](https://github.com/wguilherme)
