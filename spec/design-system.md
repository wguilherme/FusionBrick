# Design System — Premissas

Princípios que governam o FusionBrick. Toda peça nova, mudança de parâmetro ou nova implementação deve respeitar todos eles. Se uma proposta viola qualquer premissa, a proposta muda — não a premissa.

## 1. O grid é sagrado

O passo do grid (`cell_size = 20mm`) nunca muda por causa de uma junção.

- Peças auxiliares (LINK, BRIDGE, CORNER e futuras) conectam furos existentes **sem inserir espaçamento**
- A espessura de PLATEs vive **fora** do volume do grid ([Lei do Grid](rules.md))
- Teste canônico: em qualquer montagem, um ATOM deve entrar em qualquer célula interior e alinhar com todos os furos vizinhos

## 2. Circuito elétrico passa por padrão

Toda peça e todo conector nascem com passagem para fio/jumper — fechar é opt-in, nunca default.

- Furos de face (`hole_d = 10mm`) são passantes
- Conectores têm canal axial: LINK `6mm`, CORNER `3mm` (mínimo: jumper Dupont, `2.5mm`)
- Quando a seção não comporta canal (ex: BRIDGE, pinos `Ø2.8`), a peça não pode bloquear as passagens existentes — a BRIDGE vive na borda justamente para deixar os furos de face livres
- `canal_d = 0` fecha o canal — escolha do usuário, nunca da spec

## 3. Compatibilidade é permanente

Tudo conecta com tudo, sempre — inclusive com peças impressas antes.

- Parâmetros globais ([params.md](params.md)) idênticos em todas as peças; divergiu, quebrou
- Peça nova deve usar as interfaces existentes ([rules.md](rules.md)); interface nova só quando nenhuma existente resolve — e vira contrato do sistema, documentada em `spec/`
- Mudança de interface é mudança de sistema: propaga para todas as peças, specs, implementações e exemplos de uma vez
- Nada de pares exclusivos: se a peça A conecta na B, deve conectar em qualquer peça com a mesma interface

## 4. Interfaces não competem

Cada interface tem seu papel; junções não consomem o recurso das outras.

| Interface | Onde | Serve para |
| --- | --- | --- |
| Face (furo `Ø10` + rebaixo `Ø14×2`) | faces de ATOM e PLATE | LINK, empilhamento, fixação de módulos |
| Borda (furo `Ø3` + rebaixo `10×1.5×2`) | bordas de PLATE | BRIDGE, CORNER — junções estruturais |

Consequência: montar uma junção nunca impede montar um módulo — ATOM assenta sobre qualquer junção.

## 5. Press-fit primeiro

- Sem ferramentas, sem parafusos, sem cola (cola é opção do usuário para montagem permanente)
- `tolerance = 0.2mm` subtraída sempre do conector, nunca da peça receptora — peças receptoras são nominais
- Ajuste fino por impressora acontece no conector (peça pequena, reimpressão barata)

## 6. Spec-first

- `spec/` é o contrato; `impl/` implementa. Divergência entre os dois é bug na implementação — ou proposta de mudança que deve começar pela spec
- Toda implementação (OpenSCAD, Fusion 360, …) que respeite a spec produz peças intercompatíveis
