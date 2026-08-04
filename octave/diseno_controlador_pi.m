function ctl = diseno_controlador_pi(p, m)
%DISENO_CONTROLADOR_PI Construye el PI, analiza L(s) y genera figs. 05 y 08.
%
%  La cancelacion del polo termico es nominal (modelo asumido): no elimina
%  fisicamente la dinamica termica ni prueba robustez industrial.
%
%  Los polos -0.08818813 y -0.01181187 son de la realizacion minima de T(s).
%  El modelo aumentado (qh, theta, xi) conserva ademas -1/tau_T, visible en Td.

  fprintf('\n=== Diseno del controlador PI ===\n');
  fprintf('Cancelacion: nominal del polo termico estable -1/tau_T.\n');
  fprintf('No se afirma eliminacion fisica ni robustez del horno real.\n');

  C = tf(p.Kp * [p.Ti_s, 1], [p.Ti_s, 0]);
  Cp = tf(p.Kp, 1);
  L = minreal(C * m.Gp);
  L0 = tf(250, conv([600, 0], [10, 1]));

  % T minima (canal referencia-temperatura tras cancelacion nominal)
  T = minreal(feedback(C * m.Gp, 1));
  % Sensibilidad minima del lazo nominal. Al multiplicarla por GL, Td conserva
  % exactamente un polo termico adicional: el modo interno no cancelado.
  S = minreal(feedback(1, C * m.Gp));
  Td = minreal(m.GL * S);
  Vr = minreal(C / (1 + C * m.Gp));
  Vq = minreal(-(C * m.GL) / (1 + C * m.Gp));

  Tp = minreal(feedback(Cp * m.Gp, 1));
  Sp = minreal(feedback(1, Cp * m.Gp));
  Tdp = minreal(m.GL * Sp);
  Vrp = minreal(Cp / (1 + Cp * m.Gp));

  % --- Algebra del lazo reducido / T minima ---
  poles_L = pole(L);
  zeros_L = zero(L);
  n_int = sum(abs(real(poles_L)) < 1e-12 & abs(imag(poles_L)) < 1e-12);
  type_L = n_int;  % polos en el origen

  wn = sqrt(p.Kp / 24);
  zeta = 0.1 / (2 * wn);
  poles_Tmin = roots([1, 0.1, p.Kp / 24]);
  poles_Tmin = sort(real(poles_Tmin));  % mas negativo primero

  fprintf('Kp=%.6g  Ti=%.6g s  Ki=%.10g\n', p.Kp, p.Ti_s, p.Ki);
  fprintf('Tipo de L(s): %d\n', type_L);
  fprintf('Polos de T(s) minima (ref-temp): %.8f  %.8f\n', ...
          poles_Tmin(1), poles_Tmin(2));
  fprintf('wn=%.8f rad/s  zeta=%.6f  (T minima %s)\n', wn, zeta, ...
          ternary(zeta > 1, 'sobreamortiguada', 'no sobreamortiguada'));

  assert_rel(p.Ki, p.Kp / p.Ti_s, p.tol_algebraic, 'Ki=Kp/Ti');
  assert_rel(type_L, 1, p.tol_algebraic, 'tipo de L');
  assert_rel(wn, p.cl_wn_ref, 1e-5, 'wn de T minima');
  assert_rel(zeta, p.cl_zeta_ref, 1e-5, 'zeta de T minima');
  assert_rel(poles_Tmin(1), p.cl_poles_Tmin_ref(1), 1e-5, 'polo Tmin rapido');
  assert_rel(poles_Tmin(2), p.cl_poles_Tmin_ref(2), 1e-5, 'polo Tmin lento');
  assert(zeta > 1, 'Se esperaba T(s) minima sobreamortiguada');

  poles_T = sort(real(pole(T)));
  assert(numel(poles_T) == 2, 'T minima debe tener exactamente 2 polos');
  assert_rel(poles_T(1), poles_Tmin(1), 1e-4, 'pole(T) rapido');
  assert_rel(poles_T(2), poles_Tmin(2), 1e-4, 'pole(T) lento');

  % Autovalores del modelo aumentado lineal (estados xi, qh, theta)
  A = [
    0,                                 0,                -1;
    p.Ka_W_per_pu * p.Ki / p.tau_a_s, -1 / p.tau_a_s, ...
      -p.Ka_W_per_pu * p.Kp / p.tau_a_s;
    0,                                 1 / p.Cth_J_per_K, ...
      -p.UA_W_per_K / p.Cth_J_per_K
  ];
  eigs_aug = sort(real(eig(A)));
  eigs_ref = sort(p.aug_eigs_ref);
  fprintf('Autovalores aumentados (xi,qh,theta): %.8f  %.8f  %.8f\n', ...
          eigs_aug(1), eigs_aug(2), eigs_aug(3));
  for k = 1:3
    assert_rel(eigs_aug(k), eigs_ref(k), 1e-5, sprintf('eig aumentado %d', k));
  end

  poles_Td = sort(real(pole(Td)));
  fprintf('Polos Td(s): ');
  fprintf('%.8f ', poles_Td);
  fprintf('\n');
  assert(numel(poles_Td) == 3, ...
         'La realizacion minima de Td(s) debe tener exactamente 3 polos');
  for k = 1:3
    assert_rel(poles_Td(k), eigs_ref(k), 1e-4, sprintf('polo Td %d', k));
  end

  % Condicion de modulo en s_d (polo lento de T minima)
  sd = p.sd_ref;
  [n0, d0] = tfdata(L0);
  if iscell(n0); n0 = n0{1}; end
  if iscell(d0); d0 = d0{1}; end
  % Algunas versiones de Octave/control rellenan el numerador con ceros
  % lideres hasta igualar el orden del denominador (p. ej. [0 0 250]).
  % Quitarlos antes de comprobar que L0 tiene numerador constante.
  n0 = n0(:).';
  d0 = d0(:).';
  n0_tol = 100 * eps * max(1, norm(n0, Inf));
  first_n0 = find(abs(n0) > n0_tol, 1, 'first');
  assert(~isempty(first_n0), 'L0 no puede tener numerador nulo');
  n0 = n0(first_n0:end);
  L0_sd = polyval(n0(:).', sd) / polyval(d0(:).', sd);
  Kp_mod = 1 / abs(L0_sd);
  fprintf('|L0(sd)|=%.10g  => Kp=%.10g (ref 0.025)\n', abs(L0_sd), Kp_mod);
  assert_rel(Kp_mod, p.Kp_modulus_ref, 1e-4, 'condicion de modulo');

  % Punto de dispersion: K(s)=-D(s)/N(s), con dK/ds=0. Para L0 el
  % numerador es constante, por lo que basta derivar -D(s)/N.
  assert(numel(n0) == 1, 'L0 debe tener numerador constante');
  dK_num = -polyder(d0) / n0(1);
  dispersion_candidates = roots(dK_num);
  poles_L0_real = sort(real(pole(L0)));
  dispersion_candidates = real(dispersion_candidates(
    abs(imag(dispersion_candidates)) < 1e-10 & ...
    real(dispersion_candidates) > poles_L0_real(1) & ...
    real(dispersion_candidates) < poles_L0_real(end)));
  assert(numel(dispersion_candidates) == 1, ...
         'Se esperaba un unico punto de dispersion entre los polos de L0');
  s_dispersion = dispersion_candidates(1);
  Kp_dispersion = -polyval(d0, s_dispersion) / polyval(n0, s_dispersion);
  fprintf('Punto de dispersion: s=%.8f  Kp=%.8f\n', ...
          s_dispersion, Kp_dispersion);
  assert_rel(s_dispersion, p.dispersion_s_ref, p.tol_algebraic, ...
             'punto de dispersion');
  assert_rel(Kp_dispersion, p.Kp_dispersion_ref, p.tol_algebraic, ...
             'Kp en punto de dispersion');

  v0 = p.Kp * p.dr_C;
  u0p = p.u0_pu + v0;
  fprintf('v(0+)=%.6f  u(0+)=%.6f\n', v0, u0p);
  assert_rel(v0, p.ref_v0_ref, p.tol_algebraic, 'v(0+)');
  assert_rel(u0p, p.ref_u0plus_ref, p.tol_algebraic, 'u(0+)');

  assert_rel(dcgain(T), 1, p.tol_algebraic, 'dcgain(T)');
  einf_P = p.dr_C / (1 + p.Kp * dcgain(m.Gp));
  theta_inf_P_dist = dcgain(Tdp) * p.dqL_W;
  fprintf('P: e_inf=%.6f degC (ref %.5f)\n', einf_P, p.P_einf_ref);
  fprintf('P: theta_inf@dqL=%.6f degC (ref %.5f)\n', theta_inf_P_dist, p.P_theta_inf_dist_ref);
  assert_rel(einf_P, p.P_einf_ref, 1e-5, 'e_inf P');
  assert_rel(theta_inf_P_dist, p.P_theta_inf_dist_ref, 1e-5, 'theta_inf P dist');

  [Gm, Pm, Wcg, Wcp] = margin(L);
  w_gain_cross = Wcp;
  fprintf('Wcg(phase cross)=%.7g  Wcp(gain cross)=%.7g\n', Wcg, Wcp);
  fprintf('w_cg=%.7f rad/s (ref %.7f)\n', w_gain_cross, p.wcg_ref);
  fprintf('Pm=%.4f deg (ref %.4f)\n', Pm, p.Pm_deg_ref);
  if isinf(Gm) || (~isfinite(Wcg) && isfinite(Pm)) || Gm > 1e6
    fprintf('Gm = infinito (sin cruce de fase -180)\n');
    Gm_ok = true;
  else
    fprintf('Gm = %.4f (Wcg=%.7g)\n', Gm, Wcg);
    Gm_ok = isinf(Gm);
  end
  assert_rel(w_gain_cross, p.wcg_ref, 1e-3, 'frecuencia cruce ganancia');
  assert_rel(Pm, p.Pm_deg_ref, 1e-3, 'margen de fase');
  assert(Gm_ok, 'Se esperaba margen de ganancia infinito');

  note = 'Parametros: supuestos academicos de diseno (congelados)';

  fig5 = figure();
  rlocus(L0);
  hold on;
  plot(real(poles_Tmin), imag(poles_Tmin), 'ks', 'MarkerSize', 9, ...
       'MarkerFaceColor', 'y', 'LineWidth', 1.5);
  plot(s_dispersion, 0, 'md', 'MarkerSize', 8, 'MarkerFaceColor', 'm');
  grid on;
  title(sprintf(['Lugar de raices del lazo nominal reducido L_0(s)\n', ...
                 '(tras cancelacion; polos de T minima) (%s)'], note));
  xlabel('Re [1/s]');
  ylabel('Im [1/s]');
  legend('lugar de raices', 'polos de T_{min} (Kp=0.025)', ...
         'punto de dispersion (-0.05)', ...
         'Location', 'southwest');
  save_fig(fig5, '05_lugar_raices_PI');
  close(fig5);

  fig8 = figure();
  bode(L);
  grid on;
  title(sprintf('Bode de L(s)=C(s)G_p(s) (%s)', note));
  save_fig(fig8, '08_bode_lazo_abierto_PI');
  close(fig8);

  ctl.C = C;
  ctl.Cp = Cp;
  ctl.L = L;
  ctl.L0 = L0;
  ctl.T = T;
  ctl.S = S;
  ctl.Td = Td;
  ctl.Vr = Vr;
  ctl.Vq = Vq;
  ctl.Tp = Tp;
  ctl.Tdp = Tdp;
  ctl.Vrp = Vrp;
  ctl.poles_Tmin = poles_Tmin;
  ctl.eigs_aug = eigs_aug;
  ctl.wn = wn;
  ctl.zeta = zeta;
  ctl.type_L = type_L;
  ctl.Pm = Pm;
  ctl.Gm = Gm;
  ctl.w_gain_cross = w_gain_cross;
  ctl.zeros_L = zeros_L;
  ctl.poles_L = poles_L;
end

function out = ternary(cond, a, b)
  if cond
    out = a;
  else
    out = b;
  end
end

function assert_rel(got, expected, tol, name)
  if abs(expected) < 10 * eps
    err = abs(got - expected);
  else
    err = abs(got - expected) / abs(expected);
  end
  if err > tol
    error('Fallo %s: got=%.10g expected=%.10g rel_err=%.3e tol=%.3e', ...
          name, got, expected, err, tol);
  end
end
