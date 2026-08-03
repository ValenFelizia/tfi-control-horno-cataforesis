# TFI de Sistemas de Control I

Sistema de control de temperatura para una zona equivalente de un horno de
curado de cataforesis automotriz.

## Estado

El modelo matemático base y los parámetros están cerrados como supuestos
académicos de diseño. El modelo nominal de planta abierta y el controlador PI
están implementados y verificados en Octave (`octave/run_all.m`). El siguiente
paso es la redacción del informe final.

El año que debe figurar en el nombre del informe es el año de cursado:

`Felizia.TFI.SCI2025.pdf`

La fecha límite informada es el segundo semestre de 2027.

## Estructura

```text
docs/        Fuente matemática y cuaderno Word
octave/      Código de análisis y simulación
figuras/     Gráficos generados por Octave
informe/     Informe final y exportación PDF
fuentes/     Índice de apuntes y bibliografía
scripts/     Herramientas reproducibles para documentos
```

## Flujo de trabajo

1. Cerrar la matemática y los supuestos de diseño.
2. Actualizar `docs/modelo_matematico.md` y el cuaderno Word.
3. Implementar los scripts de Octave sin alterar ecuaciones ni parámetros
   sin documentar el cambio.
4. Generar desde Octave todas las métricas y figuras del informe.
5. Diseñar el PI y verificar las especificaciones.
6. Redactar el informe final siguiendo la guía V5 de la cátedra.

## Ejecución del modelo nominal

Requisitos: GNU Octave con el paquete `control`.

```bash
cd octave
octave-cli --no-gui run_all.m
```

Las figuras se regeneran en `figuras/`. Los valores numéricos del informe deben
poder reconstruirse desde estos scripts.
