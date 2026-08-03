function met = respuesta_planta(p, m)
%RESPUESTA_PLANTA Respuestas temporales abiertas, metricas y figuras.
%
%  Convenciones explicitas de metricas:
%    - rise time 10-90 %: tiempo entre 10 % y 90 % de la amplitud del escalon
%    - settling time ±5 %: primer instante tras el cual la respuesta permanece
%      dentro de ±5 % de la amplitud del escalon respecto del valor final
%    - overshoot %: 100 * max(0, (ymax - y_final) / |amplitud|)

  fprintf('\n=== Respuesta temporal de la planta abierta ===\n');
  fprintf('Convencion rise time: 10-90 %% de la amplitud del escalon\n');
  fprintf('Convencion settling time: banda ±5 %% de la amplitud del escalon\n');

  t = (0:p.dt_s:p.t_final_s)';

  % --- Verificacion matematica normalizada: dcgain + aproximación por step ---
  K0 = dcgain(m.Gp);
  fprintf('\nVerificacion matematica (dcgain algebraico + escalon unitario NO fisico):\n');
  fprintf('  dcgain(Gp) = %.10f degC/p.u. (esperado 250)\n', K0);
  assert_rel_local(K0, 250, p.tol_algebraic, 'dcgain(Gp)');

  [y_unit, ~] = step(m.Gp, t);
  tol_trunc = max(1e-3, exp(-p.t_final_s / p.tau_T_s)); % truncacion temporal
  fprintf('  theta(t_final) @v=1 = %.6f degC (tol truncacion relativa=%.3e)\n', ...
          y_unit(end), tol_trunc);
  assert_rel_local(y_unit(end), 250, tol_trunc, 'step unitario en t_final');

  % --- Ensayo fisico: Delta v = 0.04 p.u. ---
  dv = p.dv_phys_pu;
  theta_inf = K0 * dv;                 % analitico: 10 degC
  qh_inf_W = dcgain(m.Ga) * dv;        % analitico: 20 kW
  u_final = p.u0_pu + dv;

  [theta_v, ~] = step(dv * m.Gp, t);
  [qh_v, ~] = step(dv * m.Ga, t);

  amp = theta_inf - 0;
  ymax = max(theta_v);
  if abs(amp) < 10 * eps
    OS_pct = 0;
  else
    OS_pct = 100 * max(0, (ymax - theta_inf) / abs(amp));
  end
  % Metricas respecto del valor final analitico (no el muestreado truncado)
  tr = rise_time_10_90(t, theta_v, 0, theta_inf);
  ts = settling_time(t, theta_v, theta_inf, 0.05);

  fprintf('\nEnsayo fisico Delta v = %.2f p.u. (u0=%.2f -> u_final=%.2f):\n', ...
          dv, p.u0_pu, u_final);
  fprintf('  Delta T(inf) analitico  = %.6f degC (esperado 10)\n', theta_inf);
  fprintf('  Delta T(t_final) sim    = %.6f degC\n', theta_v(end));
  fprintf('  Delta Qh(inf) analitico = %.6f kW  (esperado 20)\n', qh_inf_W / 1000);
  fprintf('  Delta Qh(t_final) sim   = %.6f kW\n', qh_v(end) / 1000);
  fprintf('  overshoot     = %.4f %% (ref ~ %.1f %%)\n', OS_pct, p.OS_pct_ref);
  fprintf('  rise time 10-90 %% = %.2f s (ref ~ %.1f s)\n', tr, p.tr_10_90_s_ref);
  fprintf('  settling time ±5 %% = %.2f s (ref ~ %.1f s)\n', ts, p.ts_5pct_s_ref);

  assert_rel_local(theta_inf, 10, p.tol_algebraic, 'Delta T(inf) analitico');
  assert_rel_local(qh_inf_W, 20e3, p.tol_algebraic, 'Delta Qh(inf) analitico');
  assert_rel_local(u_final, 0.74, p.tol_algebraic, 'u_final');
  assert_rel_local(theta_v(end), theta_inf, tol_trunc, 'Delta T simulado vs analitico');
  assert_rel_local(qh_v(end), qh_inf_W, tol_trunc, 'Delta Qh simulado vs analitico');

  check_metric(OS_pct, p.OS_pct_ref, 0.05, 'overshoot %%');
  check_metric(tr, p.tr_10_90_s_ref, p.tol_metric_s, 'rise time 10-90');
  check_metric(ts, p.ts_5pct_s_ref, p.tol_metric_s, 'settling time ±5%%');

  % --- Perturbacion abierta: Delta qL = 50 kW ---
  theta_L_inf = dcgain(m.GL) * p.dqL_W;  % analitico: -25 degC
  [theta_L, ~] = step(p.dqL_W * m.GL, t);
  fprintf('\nPerturbacion abierta Delta qL = %.0f kW:\n', p.dqL_W / 1000);
  fprintf('  theta(inf) analitico = %.6f degC (esperado -25)\n', theta_L_inf);
  fprintf('  theta(t_final) sim   = %.6f degC\n', theta_L(end));
  assert_rel_local(theta_L_inf, -25, p.tol_algebraic, 'theta(inf) analitico por qL');
  assert_rel_local(theta_L(end), theta_L_inf, tol_trunc, 'theta simulado vs analitico por qL');

  % --- Figuras ---
  fig_dir_note = 'Parametros: supuestos academicos de diseno (congelados)';

  % 01: step planta Gp con Delta v = 0.04
  fig1 = figure();
  band = 0.05 * abs(amp);
  plot(t, theta_v, 'b-', 'LineWidth', 1.4);
  hold on;
  plot([t(1), t(end)], [theta_inf + band, theta_inf + band], 'k--', 'LineWidth', 1.0);
  plot([t(1), t(end)], [theta_inf - band, theta_inf - band], 'k--', 'LineWidth', 1.0, ...
       'HandleVisibility', 'off');
  grid on;
  xlabel('t [s]');
  ylabel('\theta [°C]');
  title(sprintf('Planta abierta G_p: \\Delta v = %.2f p.u. (%s)', dv, fig_dir_note));
  legend('\theta(t)', 'banda settling \pm5 %', 'Location', 'southeast');
  xlim([0, min(p.t_final_s, 5000)]);
  save_fig(fig1, '01_step_planta_Gp');
  close(fig1);

  % 02: mapa de polos
  fig2 = figure();
  pz = pole(m.Gp);
  plot(real(pz), imag(pz), 'rx', 'MarkerSize', 10, 'LineWidth', 2);
  hold on;
  plot(0, 0, 'k+', 'HandleVisibility', 'off');
  grid on;
  axis equal;
  xlabel('Re [1/s]');
  ylabel('Im [1/s]');
  title(sprintf('Polos de G_p (%s)', fig_dir_note));
  legend('polos', 'Location', 'northeast');
  save_fig(fig2, '02_polos_planta');
  close(fig2);

  % 03: perturbacion GL
  fig3 = figure();
  plot(t, theta_L, 'r-', 'LineWidth', 1.4);
  hold on;
  plot([t(1), t(end)], [theta_L_inf, theta_L_inf], 'k--', 'LineWidth', 1.0);
  grid on;
  xlabel('t [s]');
  ylabel('\theta [°C]');
  title(sprintf('Perturbacion abierta: \\Delta q_L = +50 kW (%s)', fig_dir_note));
  legend('\theta(t)', '\theta(\infty)', 'Location', 'northeast');
  xlim([0, min(p.t_final_s, 5000)]);
  save_fig(fig3, '03_step_perturbacion_GL');
  close(fig3);

  % 04: Gp vs Gred
  [theta_red, ~] = step(dv * m.Gred, t);
  fig4 = figure();
  plot(t, theta_v, 'b-', 'LineWidth', 1.4);
  hold on;
  plot(t, theta_red, 'Color', [0.85 0.45 0.0], 'LineStyle', '--', 'LineWidth', 1.4);
  grid on;
  xlabel('t [s]');
  ylabel('\theta [°C]');
  title(sprintf('G_p vs G_{red}=250/(600s+1), \\Delta v=%.2f p.u.', dv));
  legend('G_p completa', 'G_{red} primer orden', 'Location', 'southeast');
  xlim([0, min(p.t_final_s, 5000)]);
  save_fig(fig4, '04_Gp_vs_Gred');
  close(fig4);

  met.theta_inf = theta_inf;
  met.qh_inf_W = qh_inf_W;
  met.u_final = u_final;
  met.OS_pct = OS_pct;
  met.tr_10_90_s = tr;
  met.ts_5pct_s = ts;
  met.theta_L_inf = theta_L_inf;
  met.dc_unit = K0;
end

function assert_rel_local(got, expected, tol, name)
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

function check_metric(got, expected, tol_abs, name)
  err = abs(got - expected);
  fprintf('  check %s: |got-ref|=%.4f (tol abs=%.4f)\n', name, err, tol_abs);
  if err > tol_abs
    error('Diferencia en %s fuera de tolerancia de muestreo: got=%.4f ref=%.4f', ...
          name, got, expected);
  end
end
