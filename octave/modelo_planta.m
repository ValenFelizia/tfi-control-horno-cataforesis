function m = modelo_planta(p)
%MODELO_PLANTA Construye las funciones de transferencia del modelo nominal.

  m.Ga = tf(p.Ka_W_per_pu, [p.tau_a_s, 1]);
  m.Gth = tf(p.Rth_K_per_W, [p.tau_T_s, 1]);
  m.Gp = m.Ga * m.Gth;
  m.GL = tf(-p.Rth_K_per_W, [p.tau_T_s, 1]);
  m.Gamb = tf(1, [p.tau_T_s, 1]);
  m.Gred = tf(p.K_C_per_pu, [p.tau_T_s, 1]);
end
