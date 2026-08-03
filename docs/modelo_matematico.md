# Cuaderno de modelado matemático

## Sistema de control de temperatura para una zona equivalente de un horno de cataforesis

**Estado:** modelo base cerrado (parámetros congelados como supuestos)  
**Año de cursado:** segundo semestre de 2025  
**Fecha de revisión:** 1 de agosto de 2026

> Este documento concentra la matemática del proyecto antes de llevarla al
> informe final. Los valores numéricos son supuestos académicos de diseño: no
> son datos reales del horno ni un modelo validado experimentalmente.

## 1. Definición del sistema

El horno real se representa mediante una única zona térmica equivalente. El
objetivo del lazo es mantener la temperatura del aire de esa zona ante cambios
de referencia y perturbaciones térmicas.

La calidad del curado depende de la temperatura de la pieza y del tiempo de
permanencia. Sin embargo, modelar una carrocería móvil dentro de varias zonas
exigiría un sistema distribuido. En este TFI, la energía absorbida por
carrocerías, carriers y renovación de aire se agrupa en una perturbación de
carga.

### 1.1 Variables

| Símbolo | Descripción | Unidad |
|---|---|---:|
| \(T_z(t)\) | Temperatura del aire de la zona | °C |
| \(T_{amb}(t)\) | Temperatura ambiente | °C |
| \(T_r(t)\) | Referencia de temperatura | °C |
| \(u(t)\) | Orden normalizada al quemador | p.u. |
| \(Q_h(t)\) | Potencia térmica efectiva entregada | W |
| \(Q_L(t)\) | Carga térmica agrupada | W |
| \(C_{th}\) | Capacitancia térmica equivalente | J/K |
| \(R_{th}\) | Resistencia térmica equivalente | K/W |
| \(UA\) | Conductancia térmica equivalente | W/K |
| \(K_a\) | Ganancia estática del actuador | W/p.u. |
| \(\tau_a\) | Constante de tiempo del actuador | s |

Por definición:

\[
UA=\frac{1}{R_{th}}
\]

## 2. Arquitectura funcional

La referencia se compara con la temperatura medida. El controlador ordena una
posición normalizada al sistema de modulación del quemador. El quemador entrega
potencia térmica a la zona. Una PT100 con transmisor 4-20 mA mide la temperatura
y el sistema de adquisición la reconvierte a grados Celsius.

En el modelo en unidades de ingeniería, la cadena sensor-acondicionador se
aproxima por:

\[
H_s(s)=1
\]

La aproximación se justifica porque su dinámica es mucho más rápida que la
constante térmica de la zona. El offset de 4 mA desaparece al trabajar con
variables incrementales.

## 3. Modelo del actuador

La dinámica equivalente de la válvula modulante y el quemador se representa
mediante un primer orden:

\[
\tau_a\frac{dQ_h(t)}{dt}+Q_h(t)=K_a u(t)
\]

Con condiciones iniciales nulas en variables incrementales:

\[
G_a(s)=\frac{Q_h(s)}{U(s)}
=\frac{K_a}{\tau_a s+1}
\]

La orden debe satisfacer:

\[
0\leq u(t)\leq 1
\]

La saturación es una no linealidad del sistema completo y no forma parte de la
función de transferencia lineal.

## 4. Balance energético de la zona

Se aplica conservación de energía al volumen equivalente:

\[
C_{th}\frac{dT_z(t)}{dt}
=Q_h(t)-UA[T_z(t)-T_{amb}(t)]-Q_L(t)
\]

Los términos representan:

1. energía acumulada en la zona;
2. potencia aportada por el quemador;
3. pérdidas equivalentes hacia el ambiente;
4. potencia absorbida por carga y renovación de aire.

Esta ecuación conserva la temperatura ambiente. No se adopta la simplificación
\(T_{amb}=0\), porque el punto nominal se establece con temperaturas físicas
(no incrementales) de operación. Las diferencias de temperatura tienen el mismo
valor numérico en °C y en K.

## 5. Punto de operación

Para valores constantes, la derivada se anula:

\[
0=Q_{h0}-UA(T_{z0}-T_{amb0})-Q_{L0}
\]

Por lo tanto:

\[
Q_{h0}=UA(T_{z0}-T_{amb0})+Q_{L0}
\]

Y, usando el modelo estático del actuador:

\[
u_0=\frac{Q_{h0}}{K_a}
\]

### 5.1 Valores congelados (supuestos académicos de diseño)

Estos parámetros quedan fijados para el resto del TFI como supuestos de diseño.
No representan mediciones del horno ni validación experimental.

| Parámetro | Valor | Procedencia |
|---|---:|---|
| \(T_{z0}\) | 180 °C | supuesto de diseño (congelado) |
| \(T_{amb0}\) | 25 °C | supuesto de diseño (congelado) |
| \(Q_{L0}\) | 40 kW | supuesto de diseño (congelado) |
| \(UA\) | 2000 W/K | supuesto de diseño (congelado) |
| \(C_{th}\) | 1,2 MJ/K | supuesto de diseño (congelado) |
| \(K_a\) | 500 kW/p.u. | supuesto de diseño (congelado) |
| \(\tau_a\) | 10 s | supuesto de diseño (congelado) |

De estos valores se obtiene:

\[
R_{th}=\frac{1}{UA}=5\times10^{-4}\;K/W
\]

\[
\tau_T=R_{th}C_{th}=600\;s
\]

\[
Q_{h0}=2000(180-25)+40000=350000\;W
\]

\[
u_0=\frac{350000}{500000}=0{,}70
\]

El equilibrio deja 30 % de reserva ascendente de potencia, equivalente a
150 kW. Esto permite ensayar un aumento de carga de 50 kW sin saturación
estacionaria, aunque la acción transitoria todavía debe verificarse.

## 6. Modelo incremental

Se definen desviaciones respecto del punto nominal:

\[
\theta=T_z-T_{z0},\qquad
\theta_{amb}=T_{amb}-T_{amb0}
\]

\[
q_h=Q_h-Q_{h0},\qquad
q_L=Q_L-Q_{L0},\qquad
v=u-u_0
\]

Al reemplazar en el balance y restar la ecuación de equilibrio:

\[
C_{th}\frac{d\theta(t)}{dt}
=q_h(t)-UA\theta(t)+UA\theta_{amb}(t)-q_L(t)
\]

El actuador incremental queda:

\[
\tau_a\frac{dq_h(t)}{dt}+q_h(t)=K_a v(t)
\]

El modelo es lineal mientras la orden total \(u=u_0+v\) no alcance sus
límites y los parámetros equivalentes se mantengan aproximadamente constantes.

## 7. Funciones de transferencia

Aplicando Laplace con condiciones iniciales nulas:

\[
(C_{th}s+UA)\Theta(s)
=Q_h(s)+UA\Theta_{amb}(s)-Q_L(s)
\]

### 7.1 Potencia térmica a temperatura

\[
G_{th}(s)=\frac{\Theta(s)}{Q_h(s)}
=\frac{1}{C_{th}s+UA}
=\frac{R_{th}}{\tau_Ts+1}
\]

### 7.2 Orden a temperatura

\[
G_p(s)=\frac{\Theta(s)}{V(s)}
=G_a(s)G_{th}(s)
\]

\[
G_p(s)=
\frac{K_aR_{th}}
{(\tau_as+1)(\tau_Ts+1)}
\]

Definiendo \(K=K_aR_{th}\):

\[
G_p(s)=
\frac{K}
{(\tau_as+1)(\tau_Ts+1)}
\]

Con los valores provisionales:

\[
K=500000(5\times10^{-4})=250\;^\circ C/\mathrm{p.u.}
\]

\[
G_p(s)=
\frac{250}
{(10s+1)(600s+1)}
\]

\[
G_p(s)=
\frac{250}
{6000s^2+610s+1}
\]

### 7.3 Carga térmica a temperatura

\[
G_L(s)=\frac{\Theta(s)}{Q_L(s)}
=-\frac{1}{C_{th}s+UA}
=-\frac{R_{th}}{\tau_Ts+1}
\]

### 7.4 Temperatura ambiente a temperatura de zona

\[
G_{amb}(s)=
\frac{\Theta(s)}{\Theta_{amb}(s)}
=\frac{UA}{C_{th}s+UA}
=\frac{1}{\tau_Ts+1}
\]

## 8. Análisis inicial de la planta

Los polos del camino orden-temperatura son:

\[
p_1=-\frac{1}{\tau_a}=-0{,}1\;s^{-1}
\]

\[
p_2=-\frac{1}{\tau_T}=-1{,}667\times10^{-3}\;s^{-1}
\]

Por lo tanto:

- ambos polos están en el semiplano izquierdo;
- la planta es absolutamente estable;
- no tiene ceros;
- es de tipo 0;
- el polo térmico \(p_2\) es dominante;
- la ganancia estática es \(G_p(0)=250\;^\circ C/\mathrm{p.u.}\).

Escrita en forma canónica de segundo orden,

\[
G_p(s)=\frac{K\,\omega_n^2}{s^2+2\zeta\omega_n s+\omega_n^2},
\]

con \(K=250\;^\circ C/\mathrm{p.u.}\) y

\[
\omega_n=\sqrt{\frac{1}{6000}}=0{,}0129099\;\mathrm{rad/s},
\qquad
\zeta=\frac{610}{2\sqrt{6000}}=3{,}93753.
\]

Como \(\zeta>1\), la planta es de **segundo orden sobreamortiguada**.

La separación entre polos es de un factor 60. El actuador es mucho más rápido
que el recinto, pero se conserva en el modelo para obtener una planta de
segundo orden y analizar su influencia sobre la acción de control.

Para comparar con la dinámica dominante se define la reducción de primer orden

\[
G_{\mathrm{red}}(s)=\frac{250}{600s+1}.
\]

## 9. Ensayos y especificaciones provisionales de lazo cerrado

### 9.1 Ensayo nominal de referencia

El ensayo de seguimiento queda definido como un incremento de referencia

\[
\Delta r=+10\;^\circ\mathrm{C}
\]

alrededor del punto nominal (\(T_{z0}=180\;^\circ\mathrm{C}\)). Equivale, por
ejemplo, a pasar de 180 °C a 190 °C en temperatura física, pero la definición
operativa del ensayo es el escalón incremental \(\Delta r\).

Objetivos de lazo cerrado para este ensayo (verificados con el PI adoptado):

- error estacionario: 0 °C;
- sobrepasamiento máximo: 5 % (el nominal resulta 0 %);
- tiempo de establecimiento: no más de 600 s con banda de ±5 %;
- acción de control total: entre 0 y 100 %, sin saturación sostenida.

### 9.2 Ensayo de perturbación

La perturbación queda definida como un aumento sostenido de carga térmica
equivalente

\[
\Delta q_L=+50\;\mathrm{kW}.
\]

No representa el ingreso puntual de una única carrocería, sino una carga
agrupada sostenida (carrocerías, carriers y renovación de aire).

Objetivos de lazo cerrado para este ensayo (verificados con el PI adoptado):

- desviación máxima de temperatura menor o igual a 5 °C;
- retorno permanente a la banda de ±2 °C en no más de 600 s;
- visualización explícita de la orden de control.

## 10. Diseño del controlador PI

Se adopta un PI en la forma

\[
C(s)=K_p+\frac{K_i}{s}
=K_p\frac{T_is+1}{T_is}.
\]

### 10.1 Parámetros adoptados

\[
T_i=\tau_T=600\;\mathrm{s},\qquad
K_p=0{,}025\;\mathrm{p.u./^\circ C},\qquad
K_i=\frac{K_p}{T_i}=4{,}1666666667\times10^{-5}\;\mathrm{p.u./(^\circ C\cdot s)}.
\]

El cero del PI queda en \(-1/T_i=-1/600\;\mathrm{s^{-1}}\) y cancela
**nominalmente** el polo térmico dominante estable de \(G_p\). La cancelación
vale para el modelo asumido: no elimina físicamente la dinámica térmica ni
demuestra robustez sobre el horno real.

### 10.2 Lazo abierto compensado tras la cancelación nominal

\[
L(s)=C(s)G_p(s)
=\frac{250K_p}{600s(10s+1)}.
\]

El integrador del PI hace que el lazo abierto compensado sea de **tipo 1**, lo
que garantiza error estacionario nulo ante escalones de referencia y de carga
constante (en el modelo lineal no saturado).

La ecuación característica del **lazo nominal reducido** (tras la cancelación
nominal del polo térmico) es

\[
6000s^2+600s+250K_p=0
\qquad\Leftrightarrow\qquad
s^2+0{,}1s+\frac{K_p}{24}=0.
\]

Con \(K_p=0{,}025\):

\[
\omega_n=\sqrt{\frac{K_p}{24}}=0{,}03227486\;\mathrm{rad/s},\qquad
\zeta=\frac{0{,}1}{2\omega_n}=1{,}549193.
\]

Como \(\zeta>1\), la **realización mínima** de la transferencia nominal
referencia–temperatura \(T(s)\) es de **segundo orden sobreamortiguada**. Sus
polos son

\[
s_{1,2}=-0{,}08818813\;\mathrm{s^{-1}},\qquad
-0{,}01181187\;\mathrm{s^{-1}}.
\]

Estos no son los únicos modos internos del sistema completo. El modelo
aumentado con estados \(q_h\), \(\theta\) y \(\xi\) tiene los tres autovalores

\[
-0{,}08818813\;\mathrm{s^{-1}},\qquad
-0{,}01181187\;\mathrm{s^{-1}},\qquad
-\frac{1}{600}=-0{,}00166667\;\mathrm{s^{-1}}.
\]

El modo \(-1/600\) queda cancelado únicamente en el canal nominal
referencia–temperatura; permanece estable internamente y aparece en la
transferencia de perturbación \(T_d(s)\).

### 10.3 Justificación de \(K_p\) por la acción de control

Ante \(\Delta r=10\;^\circ\mathrm{C}\),

\[
v(0^+)=K_p\Delta r=0{,}25,\qquad
u(0^+)=u_0+v(0^+)=0{,}95.
\]

Queda un margen de 0,05 p.u. hasta la saturación superior. La simulación
confirma \(u_{\max}\approx 0{,}95035\) y \(u_{\mathrm{final}}=0{,}74\).

### 10.4 Lugar de raíces del lazo nominal reducido

Se define la planta de diseño sin la ganancia variable, correspondiente al
lazo nominal **reducido tras la cancelación**:

\[
L_0(s)=\frac{250}{600s(10s+1)}.
\]

El lugar tiene polos en \(0\) y \(-0{,}1\), con punto de separación en
\(-0{,}05\). La ganancia crítica correspondiente es \(K_p=0{,}06\).

Para el polo lento de la realización mínima de \(T(s)\),
\(s_d=-0{,}01181187\), la condición de módulo da

\[
K_p=\frac{1}{|L_0(s_d)|}=0{,}025.
\]

Los dos polos marcados en la figura son los de esa realización mínima
referencia–temperatura, no el conjunto completo de autovalores internos.
### 10.5 Funciones de transferencia de lazo cerrado

\[
T(s)=\frac{C(s)G_p(s)}{1+C(s)G_p(s)},\qquad
S(s)=\frac{1}{1+C(s)G_p(s)},\qquad
T_d(s)=G_L(s)S(s).
\]

\[
\frac{V(s)}{R(s)}=\frac{C(s)}{1+C(s)G_p(s)},\qquad
\frac{V(s)}{Q_L(s)}=-\frac{C(s)G_L(s)}{1+C(s)G_p(s)}.
\]

La realización mínima de \(T(s)\) tiene sólo los dos polos del lazo reducido.
\(T_d(s)\) conserva además el polo térmico \(-1/600\), coherente con el modo
interno no eliminado físicamente.
### 10.6 Modelo con saturación (sin anti-windup)

Además del modelo lineal se simula

\[
e=\Delta r-\theta,\quad
v^*=K_pe+K_i\xi,\quad
u=\mathrm{sat}(u_0+v^*,0,1),
\]

\[
v=u-u_0,\quad
\dot\xi=e,\quad
\tau_a\dot q_h+q_h=K_av,\quad
C_{th}\dot\theta=q_h-UA\theta-q_L.
\]

En los ensayos obligatorios la saturación permanece inactiva; lineal y
saturado coinciden dentro de tolerancia numérica.

### 10.7 Comparación con P puro

Con el mismo \(K_p=0{,}025\) y sin integral, ante \(\Delta r=10\;^\circ\mathrm{C}\)

\[
e_\infty=\frac{10}{1+K_pG_p(0)}=1{,}37931\;^\circ\mathrm{C},
\]

y ante \(\Delta q_L=50\;\mathrm{kW}\)

\[
\theta_\infty=-3{,}44828\;^\circ\mathrm{C}.
\]

La acción integral es la que anula ambos errores estacionarios.

### 10.8 Márgenes frecuenciales nominales de \(L(s)\)

- frecuencia de cruce de ganancia: \(0{,}0103612\;\mathrm{rad/s}\);
- margen de fase: \(84{,}0846^\circ\);
- margen de ganancia: infinito (no hay cruce finito de fase por \(-180^\circ\)).

Estos valores caracterizan únicamente el modelo nominal asumido; no prueban
robustez industrial del horno real.

## 11. No linealidades y límites

- Saturación de la orden entre 0 y 100 %.
- Posible potencia mínima estable del quemador.
- Retardos de transporte y mezcla no representados.
- Dependencia de pérdidas por radiación con la temperatura.
- Cambios de \(C_{th}\) y \(UA\) con la carga.
- Lógica discreta de seguridad del quemador.

La simulación de lazo cerrado incorpora saturación. No se agrega anti-windup en
esta etapa. Las demás no linealidades se documentan y sólo se agregan si
mejoran el análisis sin desviar el alcance.

## 12. Próximas verificaciones

1. Incorporar figuras y métricas del PI al informe según la Guía TFI V5.
2. Redactar conclusiones técnicas comparando planta abierta, P y PI.
3. Revisar unidades, bibliografía y procedencia de todos los parámetros.

## 13. Fuentes académicas usadas en esta etapa

- Guía de Elaboración del Trabajo Final Integrador de Sistemas de Control,
  versión 5.0, agosto de 2025.
- Agüero, Adrián. *Modelo matemático de sistema térmico*. Material de Sistemas
  de Control I.
- Material de cátedra: *La función de transferencia de sistemas lineales*.
- Material de cátedra: *Sistemas de segundo orden*.
- Ortega, M. G. *Análisis de la respuesta transitoria*.
- Material de cátedra sobre lugar de raíces y compensadores.
