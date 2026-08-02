# Octave

Implementación del modelo nominal de planta abierta. Sin PI ni lazo cerrado.

## Estructura

```text
run_all.m
parametros.m
modelo_planta.m
analisis_planta.m
respuesta_planta.m
utils/
  save_fig.m
  settling_time.m
  rise_time_10_90.m
```

## Ejecución

```bash
cd octave
octave-cli --no-gui run_all.m
```

## Reglas

- usar el paquete `control`;
- centralizar parámetros en `parametros.m` (congelados, supuestos académicos);
- guardar figuras de forma determinista en `../figuras/`;
- etiquetar ejes con nombre y unidad;
- ensayo físico de mando: `Δv = 0,04 p.u.` (no `v = 1`);
- escalón unitario solo para verificar `dcgain(Gp) = 250`;
- convenciones explícitas: rise time 10–90 %, settling time ±5 %;
- no introducir PI, seguimiento cerrado, rechazo cerrado ni saturación dinámica.
