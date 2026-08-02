function tr = rise_time_10_90(t, y, y0, y_final)
%RISE_TIME_10_90 Tiempo de crecimiento 10-90 %.
%
%  Convencion explicita: rise time 10-90 %
%  tr = t(y=y0+0.90*amp) - t(y=y0+0.10*amp), con interpolacion lineal
%  en el primer cruce de cada umbral.

  amp = y_final - y0;
  if abs(amp) < 10 * eps
    tr = NaN;
    return;
  end
  y10 = y0 + 0.10 * amp;
  y90 = y0 + 0.90 * amp;
  t10 = first_crossing(t, y, y10, sign(amp));
  t90 = first_crossing(t, y, y90, sign(amp));
  tr = t90 - t10;
end

function tc = first_crossing(t, y, level, dir)
  if dir >= 0
    idx = find(y >= level, 1, 'first');
  else
    idx = find(y <= level, 1, 'first');
  end
  if isempty(idx) || idx == 1
    tc = NaN;
    return;
  end
  % Interpolacion lineal entre idx-1 e idx
  y1 = y(idx - 1);
  y2 = y(idx);
  t1 = t(idx - 1);
  t2 = t(idx);
  if abs(y2 - y1) < 10 * eps
    tc = t2;
  else
    tc = t1 + (level - y1) * (t2 - t1) / (y2 - y1);
  end
end
