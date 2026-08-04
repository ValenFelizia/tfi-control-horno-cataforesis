# Informe final

Nombre de entrega obligatorio: `Felizia.TFI.SCI2025.pdf`. El año corresponde
al cursado, no al momento de presentación.

`informe.md` conserva la fuente textual reproducible y
`Felizia.TFI.SCI2025.docx` es la versión editable maquetada. Para reconstruir
el DOCX deben existir las figuras generadas por `octave/run_all.m` y el
diagrama funcional `figuras/00_diagrama_bloques.png`.

```bash
python scripts/build_informe.py
```

Requisitos de construcción: Python con `python-docx`, Pandoc y las figuras
regeneradas previamente desde Octave.

El script genera una base editable. Los ajustes finales de portada, índice y
maquetación se conservan en `Felizia.TFI.SCI2025.docx`; la entrega se exporta a
PDF con Microsoft Word o LibreOffice y se revisa visualmente antes de su envío.
