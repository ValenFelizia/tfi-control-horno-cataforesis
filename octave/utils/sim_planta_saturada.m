function sim = sim_planta_saturada(p, t, dr, dqL)
%SIM_PLANTA_SATURADA Simula el lazo con PI, saturacion y sin anti-windup.
%
%  Estados x = [xi; qh; theta]. Integracion RK4. Sin anti-windup.

  n = numel(t);
  if n < 2
    error('t debe tener al menos dos muestras');
  end
  dt = t(2) - t(1);

  theta = zeros(n, 1);
  qh = zeros(n, 1);
  u = zeros(n, 1);
  v = zeros(n, 1);
  e = zeros(n, 1);
  sat_active = false(n, 1);

  x = [0; 0; 0];  % xi, qh, theta

  for k = 1:n
    [e_k, u_k, v_k, sat_k] = outputs(x, p, dr);
    e(k) = e_k;
    u(k) = u_k;
    v(k) = v_k;
    sat_active(k) = sat_k;
    qh(k) = x(2);
    theta(k) = x(3);

    if k < n
      k1 = f_dot(x, p, dr, dqL);
      k2 = f_dot(x + 0.5 * dt * k1, p, dr, dqL);
      k3 = f_dot(x + 0.5 * dt * k2, p, dr, dqL);
      k4 = f_dot(x + dt * k3, p, dr, dqL);
      x = x + (dt / 6) * (k1 + 2 * k2 + 2 * k3 + k4);
    end
  end

  sim.t = t;
  sim.theta = theta;
  sim.qh = qh;
  sim.u = u;
  sim.v = v;
  sim.e = e;
  sim.sat_active = sat_active;
  sim.any_sat = any(sat_active);
end

function [e, u, v, sat_flag] = outputs(x, p, dr)
  xi = x(1);
  th = x(3);
  e = dr - th;
  v_star = p.Kp * e + p.Ki * xi;
  u_cmd = p.u0_pu + v_star;
  u = saturate(u_cmd, p.u_min_pu, p.u_max_pu);
  v = u - p.u0_pu;
  sat_flag = abs(u - u_cmd) > 10 * eps;
end

function dx = f_dot(x, p, dr, dqL)
  [e, ~, v] = outputs(x, p, dr);
  xi = x(1);
  qh = x(2);
  th = x(3);
  dx = zeros(3, 1);
  dx(1) = e;   % sin anti-windup
  dx(2) = (-qh + p.Ka_W_per_pu * v) / p.tau_a_s;
  dx(3) = (qh - p.UA_W_per_K * th - dqL) / p.Cth_J_per_K;
end
