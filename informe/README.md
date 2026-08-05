# Informe final

Nombre de entrega obligatorio: `Felizia.TFI.SCI2025.pdf`. El año corresponde
al cursado, no al momento de presentación.

`informe.md` conserva la fuente textual reproducible.
`Felizia.TFI.SCI2025.docx` es el entregable editable maquetado (baseline visual);
no se regenera desde Markdown. `scripts/build_informe.py` escribe únicamente
`Felizia.TFI.SCI2025.generated.docx` como borrador auxiliar.

Para el borrador generado deben existir las figuras de `octave/run_all.m` y el
diagrama funcional `figuras/00_diagrama_bloques.png`.

```bash
python scripts/build_informe.py
```

Requisitos de construcción: Python con `python-docx`, Pandoc y las figuras
regeneradas previamente desde Octave.

Los ajustes finales de portada, índice y maquetación se conservan en
`Felizia.TFI.SCI2025.docx`. La entrega se exporta a PDF desde ese DOCX con
Microsoft Word o LibreOffice y se revisa visualmente antes de su envío.
