<div align="center">

🌐 **Português** | [English](README.en.md)

# FusionBrick

**Sistema de design modular open-source para makers, engenheiros e construtores.**

*Construa com inteligência. Imprima mais rápido. Conecte tudo.*

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![OpenSCAD](https://img.shields.io/badge/OpenSCAD-v2021+-green.svg)](https://openscad.org)
[![MakerWorld](https://img.shields.io/badge/MakerWorld-FusionBrick-orange.svg)](https://makerworld.com)
[![Version](https://img.shields.io/badge/version-0.1.0-brightgreen.svg)](CHANGELOG.md)

</div>

---

## O que é FusionBrick?

FusionBrick é um **sistema de design modular paramétrico** para impressão 3D. Oferece um conjunto de peças encaixáveis — chamadas **Bricks** — que conectam em qualquer direção, em qualquer face, sem ferramentas.

Inspirado na simplicidade do LEGO e na precisão da engenharia, FusionBrick foi projetado para:

- ⚡ **Prototipagem rápida** de cases para eletrônicos, estruturas e suportes
- 🔩 **Montagem press-fit** — sem parafusos, sem cola
- 📐 **Design paramétrico** — todas as dimensões são variáveis
- 🌐 **Open source** — faça fork, estenda, compartilhe

---

## Conceito Central

FusionBrick é construído em torno de uma regra:

> **Qualquer peça conecta em qualquer outra peça, em qualquer face, em qualquer direção.**

Cada Brick tem furos em todas as 6 faces seguindo o mesmo padrão de grade. Um **Link** (peça conectora separada) une quaisquer dois furos — press-fit para protótipos, colado para montagens permanentes.

![ATOM conectado via LINK](.github/assets/image1.png)

---

## As Peças

| Peça | Descrição | Arquivo |
|---|---|---|
| **ATOM** | Unidade cúbica estrutural. Furos em todas as 6 faces. | `impl/openscad/atom.scad` |
| **PLATE** | Superfície plana modular. Furos alinhados à grade. | `impl/openscad/plate.scad` |
| **LINK** | Conector universal. Une quaisquer dois furos. | `impl/openscad/link.scad` |
| **BRIDGE** | Une dois PLATEs coplanares lado a lado. | `impl/openscad/bridge.scad` |
| **CORNER** | Une dois PLATEs a 90°. | `impl/openscad/corner.scad` |

---

## Parâmetros do Sistema

Todas as peças compartilham os mesmos parâmetros globais. **Mantê-los iguais entre as peças garante compatibilidade.**

```
cell_size     = 20mm   // unidade base da grade
hole_d        = 10mm   // diâmetro do furo
relief_depth  = 2mm    // profundidade do rebaixo
relief_margin = 2mm    // margem do rebaixo
tolerance     = 0.2mm  // tolerância de impressão
```

> **Regra de compatibilidade:** se `cell_size`, `hole_d` e `relief_*` forem iguais entre as peças, todos os furos se alinham perfeitamente — independente de quais peças você combinar.

---

## Início Rápido

### Requisitos

- [OpenSCAD](https://openscad.org/downloads.html) 2021+
- Qualquer impressora FDM (testado na Bambu Lab A1 Mini)
- Filamento PLA ou PETG

### Imprima seu primeiro ATOM

1. Clone o repositório

```bash
git clone https://github.com/yourusername/fusionbrick.git
```

2. Abra no OpenSCAD
```bash
cd fusionbrick
open impl/openscad/atom.scad
```

3. Renderize e exporte STL

```
Pressione F6 para renderizar → File → Export → Export as STL
```

4. Fatie e imprima
   - Altura de camada: `0.2mm`
   - Preenchimento: `20%+`
   - Suportes: `Não`

### Ou use os STLs pré-exportados

Arquivos STL prontos disponíveis na pasta `renders/stl/`.

---

## Estrutura do Projeto

```
fusionbrick/
├── spec/                    ← Especificação genérica (independente de ferramenta)
│   ├── params.md
│   ├── rules.md
│   └── parts/
│       ├── atom.md
│       ├── plate.md
│       ├── link.md
│       ├── bridge.md
│       └── corner.md
│
├── impl/
│   ├── openscad/            ← Implementação OpenSCAD ✅
│   ├── fusion360/           ← Em breve
│   └── manual/              ← Em breve
│
├── renders/
│   └── stl/                 ← Arquivos STL pré-exportados
│
├── examples/                ← Montagens de exemplo
└── docs/                    ← Documentação e renders
```

---

## Roadmap

### v0.1.0 — Fundação ✅

- [x] ATOM — unidade cúbica
- [x] PLATE — superfície plana
- [x] LINK — conector universal
- [x] BRIDGE — junção coplanar
- [x] CORNER — junção 90°
- [x] Implementação OpenSCAD
- [x] Especificação do sistema

### v0.2.0 — Paramétrico

- [ ] Seleção de padrão de furos (todos, bordas, cantos)
- [ ] Suporte multi-escala (grade 10mm, 20mm, 30mm)
- [ ] Upload MakerWorld PMM

### v0.3.0 — Conectado

- [ ] Canais de condução elétrica
- [ ] Conectores magnéticos snap
- [ ] Camada de integração wireless

### v1.0.0 — Plugin

- [ ] Plugin Fusion 360 — aplica padrão em qualquer superfície
- [ ] Auto-split para modelos grandes
- [ ] Biblioteca de blueprints da comunidade

---

## Implementações

FusionBrick segue abordagem **spec-first**. A pasta `spec/` define o contrato do sistema — qualquer ferramenta CAD pode implementá-lo.

| Implementação | Status | Mantenedor |
| --- | --- | --- |
| OpenSCAD | ✅ Ativo | @yourusername |
| Fusion 360 | 🔜 Planejado | — |
| FreeCAD | 🔜 Planejado | — |
| MakerWorld PMM | 🔜 Planejado | — |

Quer adicionar uma nova implementação? Leia [CONTRIBUTING.md](CONTRIBUTING.md).

---

## Contribuindo

FusionBrick é open source e movido pela comunidade.

- 🐛 **Encontrou um bug?** Abra uma [issue](https://github.com/yourusername/fusionbrick/issues)
- 💡 **Tem uma ideia?** Inicie uma [discussão](https://github.com/yourusername/fusionbrick/discussions)
- 🔧 **Quer contribuir?** Leia [CONTRIBUTING.md](CONTRIBUTING.md)
- 🖨️ **Imprimiu algo legal?** Compartilhe no MakerWorld com **#fusionbrick**

---

## Licença

FusionBrick é lançado sob a [Licença MIT](LICENSE).

Livre para usar, modificar e distribuir — uso pessoal e comercial.

---

**FusionBrick** — *Construa com inteligência. Imprima mais rápido. Conecte tudo.*

Feito com ❤️ por makers, para makers.
