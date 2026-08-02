function info = analisis_planta(p, m)
%ANALISIS_PLANTA Polos, ceros, ganancia, tipo, estabilidad, wn y zeta.

  fprintf('\n=== Analisis de la planta (contrato del modelo) ===\n');
  fprintf('Procedencia de parametros: %s\n', p.procedencia);

  poles_p = pole(m.Gp);
  zeros_p = zero(m.Gp);
  K0 = dcgain(m.Gp);

  % Forma monica: Gp = K * wn^2 / (s^2 + 2*zeta*wn*s + wn^2)
  [num, den] = tfdata(m.Gp);
  if iscell(num)
    num = num{1};
  end
  if iscell(den)
    den = den{1};
  end
  num = num(:).';
  den = den(:).';
  den = den / den(1);
  wn = sqrt(den(end));
  if numel(den) < 3
    error('Se esperaba denominador de segundo orden');
  end
  % den = [1, 2*zeta*wn, wn^2]
  zeta = den(2) / (2 * wn);

  p1_ref = -1 / p.tau_a_s;
  p2_ref = -1 / p.tau_T_s;
  poles_sorted = sort(real(poles_p)); % [-1/tau_a, -1/tau_T]

  info.poles = poles_p;
  info.zeros = zeros_p;
  info.dcgain = K0;
  info.wn = wn;
  info.zeta = zeta;
  info.type = 0;
  info.stable = all(real(poles_p) < 0);
  info.classification = 'segundo orden sobreamortiguado';

  fprintf('Qh0 = %.6f W (esperado 350000)\n', p.Qh0_W);
  fprintf('u0  = %.6f p.u. (esperado 0.70)\n', p.u0_pu);
  fprintf('Reserva ascendente = %.2f %% (%.0f kW)\n', ...
          (1 - p.u0_pu) * 100, (1 - p.u0_pu) * p.Ka_W_per_pu / 1000);

  fprintf('Polos Gp: ');
  fprintf('%.6g ', poles_p);
  fprintf('\n');
  fprintf('Ceros Gp: ');
  if isempty(zeros_p)
    fprintf('(ninguno)\n');
  else
    fprintf('%.6g ', zeros_p);
    fprintf('\n');
  end

  fprintf('Ganancia estatica Gp(0) = %.6f degC/p.u.\n', K0);
  fprintf('Tipo = %d\n', info.type);
  if info.stable
    fprintf('Estabilidad: absolutamente estable (polos en SPI)\n');
  else
    fprintf('Estabilidad: NO estable\n');
  end
  fprintf('wn   = %.7f rad/s (ref %.7f)\n', wn, p.wn_rad_per_s_ref);
  fprintf('zeta = %.6f (ref %.5f)\n', zeta, p.zeta_ref);
  fprintf('Clasificacion: %s (zeta > 1)\n', info.classification);
  fprintf('Separacion de polos tau_T/tau_a = %.0f\n', p.tau_T_s / p.tau_a_s);

  % Verificaciones algebraicas
  assert_rel(p.Qh0_W, 350000, p.tol_algebraic, 'Qh0');
  assert_rel(p.u0_pu, 0.70, p.tol_algebraic, 'u0');
  assert_rel(p.K_C_per_pu, 250, p.tol_algebraic, 'K=Ka*Rth');
  assert_rel(K0, 250, p.tol_algebraic, 'dcgain(Gp)');
  assert_rel(p.tau_T_s, 600, p.tol_algebraic, 'tau_T');
  assert_rel(abs(poles_sorted(1) - p1_ref), 0, p.tol_algebraic, 'polo actuador');
  assert_rel(abs(poles_sorted(2) - p2_ref), 0, p.tol_algebraic, 'polo termico');
  assert_rel(wn, p.wn_rad_per_s_ref, 1e-4, 'wn');   % ref redondeada a 7 digitos
  assert_rel(zeta, p.zeta_ref, 1e-4, 'zeta');        % ref redondeada
  assert(isempty(zeros_p), 'Gp no debe tener ceros');
  assert(info.stable, 'Gp debe ser estable');
  assert(zeta > 1, 'Se esperaba planta sobreamortiguada');

  fprintf('OK: identidades algebraicas dentro de tolerancia ~1e-6 (wn/zeta vs ref redondeada).\n');
end

function assert_rel(got, expected, tol, name)
  if abs(expected) < 10 * eps
    err = abs(got - expected);
    ok = err <= tol;
  else
    err = abs(got - expected) / abs(expected);
    ok = err <= tol;
  end
  if ~ok
    error('Fallo %s: got=%.10g expected=%.10g rel_err=%.3e tol=%.3e', ...
          name, got, expected, err, tol);
  end
end
