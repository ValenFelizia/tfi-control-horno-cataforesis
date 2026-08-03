function met = simulacion_lazo_cerrado(p, m, ctl)
%SIMULACION_LAZO_CERRADO Ensayos de referencia y perturbacion (P vs PI).
%
%  Compara respuesta lineal con la simulacion que incluye saturador.
%  No hay anti-windup en esta etapa.

  fprintf('\n=== Simulacion de lazo cerrado ===\n');
  fprintf('Convencion rise time: 10-90 %% de la amplitud del escalon\n');
  fprintf('Convencion settling time referencia: banda ±5 %%\n');
  fprintf('Convencion retorno perturbacion: banda absoluta ±%.0f degC\n', p.dist_band_C);

  t = (0:p.dt_s:p.t_final_cl_s)';
  dr = p.dr_C;
  dqL = p.dqL_W;
  note = 'Parametros: supuestos academicos de diseno (congelados)';

  % ---------- Referencia: lineal PI / P y saturado PI ----------
  [th_pi, ~] = step(dr * ctl.T, t);
  [v_pi, ~] = step(dr * ctl.Vr, t);
  u_pi = p.u0_pu + v_pi;

  [th_p, ~] = step(dr * ctl.Tp, t);
  [v_p, ~] = step(dr * ctl.Vrp, t);
  u_p = p.u0_pu + v_p;

  sat_ref = sim_planta_saturada(p, t, dr, 0);

  th_inf = 1 * dr;  % dcgain(T)=1
  amp = th_inf;
  OS_pct = 100 * max(0, (max(th_pi) - th_inf) / abs(amp));
  tr = rise_time_10_90(t, th_pi, 0, th_inf);
  ts = settling_time(t, th_pi, th_inf, 0.05);
  e_inf = th_inf - th_pi(end);
  u_max = max(u_pi);
  u_final = p.u0_pu + dcgain(ctl.Vr) * dr;

  fprintf('\nEnsayo referencia Delta r = +%.0f degC (PI):\n', dr);
  fprintf('  e_inf ~ %.3e degC\n', abs(dr - th_pi(end)));
  fprintf('  overshoot = %.4f %% (ref %.1f)\n', OS_pct, p.ref_OS_pct_ref);
  fprintf('  rise time 10-90 %% = %.2f s (ref %.1f)\n', tr, p.ref_tr_10_90_s_ref);
  fprintf('  settling ±5 %% = %.2f s (ref %.1f)\n', ts, p.ref_ts_5pct_s_ref);
  fprintf('  u_max = %.6f (ref %.5f)\n', u_max, p.ref_umax_ref);
  fprintf('  u_final analitico = %.6f (ref %.2f)\n', u_final, p.ref_ufinal_ref);
  fprintf('  saturacion activa = %d\n', sat_ref.any_sat);

  assert_rel(dcgain(ctl.T), 1, p.tol_algebraic, 'dcgain(T) en sim');
  assert_abs(abs(dr - th_pi(end)), 0, max(1e-2, 5 * p.dt_s), 'error estacionario sim');
  check_metric(OS_pct, p.ref_OS_pct_ref, 0.05, 'ref overshoot');
  check_metric(tr, p.ref_tr_10_90_s_ref, p.tol_metric_s, 'ref rise time');
  check_metric(ts, p.ref_ts_5pct_s_ref, p.tol_metric_s, 'ref settling');
  check_metric(u_max, p.ref_umax_ref, p.tol_metric_u, 'ref u_max');
  assert_rel(u_final, p.ref_ufinal_ref, p.tol_algebraic, 'ref u_final');
  assert(~sat_ref.any_sat, 'Saturacion inesperada en ensayo de referencia');
  assert_abs(max(abs(th_pi - sat_ref.theta)), 0, p.tol_lin_sat, 'ref theta lin vs sat');
  assert_abs(max(abs(u_pi - sat_ref.u)), 0, p.tol_lin_sat, 'ref u lin vs sat');

  % ---------- Perturbacion ----------
  [th_d, ~] = step(dqL * ctl.Td, t);
  [v_d, ~] = step(dqL * ctl.Vq, t);
  u_d = p.u0_pu + v_d;

  [th_d_p, ~] = step(dqL * ctl.Tdp, t);

  sat_dist = sim_planta_saturada(p, t, 0, dqL);

  [theta_min, idx_min] = min(th_d);
  t_min = t(idx_min);
  t_pm2 = settling_time_abs(t, th_d, 0, p.dist_band_C);
  u_final_d = p.u0_pu + dcgain(ctl.Vq) * dqL;

  fprintf('\nEnsayo perturbacion Delta qL = +%.0f kW (PI):\n', dqL / 1000);
  fprintf('  theta_min = %.5f degC (ref %.4f)\n', theta_min, p.dist_theta_min_ref);
  fprintf('  t_min = %.2f s (ref %.1f)\n', t_min, p.dist_t_min_s_ref);
  fprintf('  retorno a ±%.0f degC = %.2f s (ref %.1f)\n', p.dist_band_C, t_pm2, p.dist_t_pm2_s_ref);
  fprintf('  theta(inf) sim = %.5f degC\n', th_d(end));
  fprintf('  u_final analitico = %.6f (ref %.2f)\n', u_final_d, p.dist_ufinal_ref);
  fprintf('  saturacion activa = %d\n', sat_dist.any_sat);

  check_metric(theta_min, p.dist_theta_min_ref, p.tol_metric_C, 'dist theta_min');
  check_metric(t_min, p.dist_t_min_s_ref, p.tol_metric_s, 'dist t_min');
  check_metric(t_pm2, p.dist_t_pm2_s_ref, p.tol_metric_s, 'dist retorno ±2');
  assert_abs(abs(th_d(end)), 0, max(1e-2, 5 * p.dt_s), 'dist theta(inf)');
  assert_rel(u_final_d, p.dist_ufinal_ref, p.tol_algebraic, 'dist u_final');
  assert_abs(dcgain(ctl.Td) * dqL, 0, 1e-8, 'dcgain(Td)*dqL');
  assert(theta_min >= -5 - p.tol_metric_C, 'Desviacion maxima excede 5 degC');
  assert(t_pm2 <= 600 + p.tol_metric_s, 'Retorno a ±2 degC excede 600 s');
  assert(~sat_dist.any_sat, 'Saturacion inesperada en ensayo de perturbacion');
  assert_abs(max(abs(th_d - sat_dist.theta)), 0, p.tol_lin_sat, 'dist theta lin vs sat');
  assert_abs(max(abs(u_d - sat_dist.u)), 0, p.tol_lin_sat, 'dist u lin vs sat');

  % ---------- Figura 06: referencia P vs PI (+ control) ----------
  fig6 = figure();
  subplot(2, 1, 1);
  plot(t, th_pi, 'b-', 'LineWidth', 1.4);
  hold on;
  plot(t, sat_ref.theta, 'c--', 'LineWidth', 1.1);
  plot(t, th_p, 'Color', [0.7 0.2 0.2], 'LineStyle', '-', 'LineWidth', 1.2);
  plot([t(1), t(end)], [dr, dr], 'k:', 'LineWidth', 1.0);
  grid on;
  ylabel('\theta [°C]');
  title(sprintf('Referencia \\Delta r=+10 °C: P vs PI (%s)', note));
  legend('PI lineal', 'PI + sat', 'P puro', '\Delta r', 'Location', 'southeast');
  xlim([0, 1500]);

  subplot(2, 1, 2);
  plot(t, u_pi, 'b-', 'LineWidth', 1.4);
  hold on;
  plot(t, sat_ref.u, 'c--', 'LineWidth', 1.1);
  plot(t, u_p, 'Color', [0.7 0.2 0.2], 'LineWidth', 1.2);
  plot([t(1), t(end)], [p.u_max_pu, p.u_max_pu], 'r:', 'LineWidth', 1.0);
  plot([t(1), t(end)], [p.u_min_pu, p.u_min_pu], 'r:', 'LineWidth', 1.0, ...
       'HandleVisibility', 'off');
  grid on;
  xlabel('t [s]');
  ylabel('u [p.u.]');
  legend('u PI lineal', 'u PI + sat', 'u P', 'limites', 'Location', 'northeast');
  xlim([0, 1500]);
  ylim([-0.05, 1.05]);
  save_fig(fig6, '06_referencia_P_vs_PI');
  close(fig6);

  % ---------- Figura 07: perturbacion PI ----------
  fig7 = figure();
  subplot(2, 1, 1);
  plot(t, th_d, 'b-', 'LineWidth', 1.4);
  hold on;
  plot(t, sat_dist.theta, 'c--', 'LineWidth', 1.1);
  plot([t(1), t(end)], [p.dist_band_C, p.dist_band_C], 'k--', 'LineWidth', 1.0);
  plot([t(1), t(end)], [-p.dist_band_C, -p.dist_band_C], 'k--', 'LineWidth', 1.0, ...
       'HandleVisibility', 'off');
  plot([t(1), t(end)], [0, 0], 'k:', 'LineWidth', 1.0, 'HandleVisibility', 'off');
  grid on;
  ylabel('\theta [°C]');
  title(sprintf('Perturbacion \\Delta q_L=+50 kW (PI) (%s)', note));
  legend('\theta PI lineal', '\theta PI + sat', 'banda \pm2 °C', 'Location', 'southeast');
  xlim([0, 1500]);

  subplot(2, 1, 2);
  plot(t, u_d, 'b-', 'LineWidth', 1.4);
  hold on;
  plot(t, sat_dist.u, 'c--', 'LineWidth', 1.1);
  plot([t(1), t(end)], [p.u_max_pu, p.u_max_pu], 'r:', 'LineWidth', 1.0);
  plot([t(1), t(end)], [p.u_min_pu, p.u_min_pu], 'r:', 'LineWidth', 1.0, ...
       'HandleVisibility', 'off');
  grid on;
  xlabel('t [s]');
  ylabel('u [p.u.]');
  legend('u PI lineal', 'u PI + sat', 'limites', 'Location', 'southeast');
  xlim([0, 1500]);
  ylim([0.65, 1.05]);
  save_fig(fig7, '07_perturbacion_PI');
  close(fig7);

  met.ref.OS_pct = OS_pct;
  met.ref.tr = tr;
  met.ref.ts = ts;
  met.ref.u_max = u_max;
  met.ref.u_final = u_final;
  met.ref.any_sat = sat_ref.any_sat;
  met.dist.theta_min = theta_min;
  met.dist.t_min = t_min;
  met.dist.t_pm2 = t_pm2;
  met.dist.u_final = u_final_d;
  met.dist.any_sat = sat_dist.any_sat;
  met.P.einf = dr - th_p(end);
  met.P.theta_inf_dist = th_d_p(end);
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

function assert_abs(got, expected, tol, name)
  err = abs(got - expected);
  if err > tol
    error('Fallo %s: got=%.10g expected=%.10g abs_err=%.3e tol=%.3e', ...
          name, got, expected, err, tol);
  end
end

function check_metric(got, expected, tol_abs, name)
  err = abs(got - expected);
  fprintf('  check %s: |got-ref|=%.4f (tol abs=%.4f)\n', name, err, tol_abs);
  if err > tol_abs
    error('Diferencia en %s fuera de tolerancia: got=%.6f ref=%.6f', name, got, expected);
  end
end
