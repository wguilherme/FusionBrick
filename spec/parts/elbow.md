# ELBOW

Curva 90° da interface de borda. Liga duas vigas ([CORNER](corner.md)/[PIN](pin.md)) ou furos de borda perpendiculares com o canto externo **arredondado** — alternativa estética ao encaixe em L de quinas vivas.

## Geometria

```text
     ╭──────┐
    ╱       │ ← porta B (aponta -X)
   │   ◜    │
   │  ╱     │
   └──┴─────┘
      ↑ porta A (aponta -Y)
```

- **Corpo**: varredura de 90° da seção `sec × sec` (padrão `5×5`), raio externo = `sec` — ocupa exatamente o volume `5×5×5` da quina
- **Portas** (×2, perpendiculares): `pin` (colar Ø3.6×1 + haste Ø2.8, total 3.5mm) ou `hole` (bore Ø3×4 + rebaixo Ø3.8×1), no centro da seção
- **Canal curvo**: com as duas portas em `hole`, um arco Ø3 liga os centros das portas por dentro — **fio vira a esquina dentro da peça**
- **Acabamento**: `border_radius` (padrão `0`) + `border_style` `round`/`chamfer` nas 4 arestas que acompanham a curva; faces das portas ficam planas (flush)

## Compatibilidade

- Pino entra no canal axial de CORNER/PIN e em qualquer furo de borda (PLATE, ATOM)
- Furo recebe pino de CORNER/PIN/VERTEX e dowel de BRIDGE
- Não altera o passo do grid: substitui o volume da quina, faces planas flush com as vigas

## Restrições

- Ângulo fixo 90° — sistema é ortogonal (Lei do Grid)
- Raio externo acompanha `sec`; seções diferentes de `5` exigem vigas de mesma seção
