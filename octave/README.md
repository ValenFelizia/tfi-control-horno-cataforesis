# Octave

Modelo nominal de planta abierta y controlador PI de lazo cerrado.

## Estructura

```text
run_all.m
parametros.m
modelo_planta.m
analisis_planta.m
respuesta_planta.m
diseno_controlador_pi.m
simulacion_lazo_cerrado.m
utils/
  save_fig.m
  settling_time.m
  settling_time_abs.m
  rise_time_10_90.m
  saturate.m
  sim_planta_saturada.m
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
- convenciones explícitas: rise time 10–90 %, settling time ±5 %;
- la cancelación del polo térmico del PI es nominal (modelo asumido);
- no agregar anti-windup en esta etapa.
