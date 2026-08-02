function p = parametros()
%PARAMETROS Parametros congelados del modelo nominal de planta abierta.
%
%  Procedencia: supuestos academicos de diseno. No son datos reales del horno
%  ni un modelo validado experimentalmente.

  p.procedencia = 'supuesto academico de diseno (congelado)';

  % Punto de operacion y constantes (unidades SI coherentes)
  p.Tz0_C = 180;          % degC
  p.Tamb0_C = 25;         % degC
  p.QL0_W = 40e3;         % W
  p.UA_W_per_K = 2000;    % W/K
  p.Cth_J_per_K = 1.2e6;  % J/K
  p.Ka_W_per_pu = 500e3;  % W / p.u.
  p.tau_a_s = 10;         % s

  % Derivados
  p.Rth_K_per_W = 1 / p.UA_W_per_K;
  p.tau_T_s = p.Rth_K_per_W * p.Cth_J_per_K;
  p.Qh0_W = p.UA_W_per_K * (p.Tz0_C - p.Tamb0_C) + p.QL0_W;
  p.u0_pu = p.Qh0_W / p.Ka_W_per_pu;
  p.K_C_per_pu = p.Ka_W_per_pu * p.Rth_K_per_W;

  % Ensayos abiertos de referencia
  p.dv_phys_pu = 0.04;
  p.dqL_W = 50e3;

  % Forma canonica de segundo orden (valores de referencia del cuaderno)
  p.wn_rad_per_s_ref = 0.0129099;
  p.zeta_ref = 3.93753;

  % Metricas abiertas de referencia ante dv = 0.04 p.u.
  p.OS_pct_ref = 0;
  p.tr_10_90_s_ref = 1318.3;
  p.ts_5pct_s_ref = 1807.5;

  % Tolerancias
  p.tol_algebraic = 1e-6;
  p.dt_s = 0.1;                 % paso temporal de muestreo
  p.tol_metric_s = 5 * p.dt_s;  % coherente con el muestreo (0.5 s)
  p.t_final_s = 6000;
end
