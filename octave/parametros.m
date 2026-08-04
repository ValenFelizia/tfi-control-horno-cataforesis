function p = parametros()
%PARAMETROS Parametros congelados del modelo nominal y del PI.
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

  % Ensayos
  p.dv_phys_pu = 0.04;
  p.dqL_W = 50e3;
  p.dr_C = 10;

  % Controlador PI adoptado (cancelacion nominal del polo termico)
  p.Kp = 0.025;                         % p.u. / degC
  % Limite de actuacion para Delta r = 10 C: Kp*dr <= 1-u0 => Kp <= 0.03
  p.Kp_max_actuation = (1 - p.u0_pu) / p.dr_C;
  p.Ti_s = p.tau_T_s;                   % 600 s
  p.Ki = p.Kp / p.Ti_s;                 % p.u. / (degC * s)
  p.u_min_pu = 0;
  p.u_max_pu = 1;

  % Forma canonica planta abierta (refs)
  p.wn_rad_per_s_ref = 0.0129099;
  p.zeta_ref = 3.93753;
  p.OS_pct_ref = 0;
  p.tr_10_90_s_ref = 1318.3;
  p.ts_5pct_s_ref = 1807.5;

  % Lazo cerrado: realizacion minima de T(s) (refs)
  p.cl_poles_Tmin_ref = [-0.08818813; -0.01181187];
  p.cl_wn_ref = 0.03227486;
  p.cl_zeta_ref = 1.549193;
  p.aug_eigs_ref = [-0.08818813; -0.01181187; -1/600];
  p.dispersion_s_ref = -0.05;
  p.Kp_dispersion_ref = 0.06;
  p.sd_ref = -0.01181187;
  p.Kp_modulus_ref = 0.025;

  % Ensayo referencia PI
  p.ref_OS_pct_ref = 0;
  p.ref_tr_10_90_s_ref = 188.9;
  p.ref_ts_5pct_s_ref = 265.8;
  p.ref_umax_ref = 0.95035;
  p.ref_ufinal_ref = 0.74;
  p.ref_v0_ref = 0.25;
  p.ref_u0plus_ref = 0.95;

  % Ensayo perturbacion PI
  p.dist_theta_min_ref = -2.8987;
  p.dist_t_min_s_ref = 194.6;
  p.dist_t_pm2_s_ref = 504.9;
  p.dist_ufinal_ref = 0.80;
  p.dist_band_C = 2;

  % Bode / margenes
  p.wcg_ref = 0.0103612;
  p.Pm_deg_ref = 84.0846;

  % Comparacion P puro
  p.P_einf_ref = 1.37931;
  p.P_theta_inf_dist_ref = -3.44828;

  % Tolerancias y grilla temporal
  p.tol_algebraic = 1e-6;               % identidades exactas (equilibrio, dcgain)
  % 1e-4 / 1e-5: refs redondeadas del cuaderno vs float de Octave
  p.tol_rounded_ref = 1e-4;
  p.tol_derived = 1e-5;
  p.dt_s = 0.1;
  p.tol_metric_s = 5 * p.dt_s;          % ~5 muestras de la grilla temporal
  p.tol_metric_C = 0.02;                % resolucion practica de temperatura
  p.tol_metric_u = 5e-4;                % u_max reportado a 5 digitos
  p.tol_lin_sat = 2e-3;                 % RK4 dt=0.1 vs step() exacto del paquete control
  % Residuos admisibles al horizonte finito de simulacion. Los valores
  % estacionarios se verifican por separado mediante dcgain.
  p.tol_ref_horizon_C = 1e-3;
  p.tol_dist_horizon_C = 0.05;
  p.t_final_s = 6000;
  p.t_final_cl_s = 3000;
end
