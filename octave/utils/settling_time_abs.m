function ts = settling_time_abs(t, y, y_final, band_abs)
%SETTLING_TIME_ABS Tiempo de retorno permanente a una banda absoluta.
%
%  Primer instante a partir del cual |y(t)-y_final| permanece <= band_abs.

  outside = abs(y - y_final) > band_abs;
  if ~any(outside)
    ts = t(1);
    return;
  end
  idx = find(outside, 1, 'last');
  if idx >= numel(t)
    ts = NaN;
  else
    ts = t(idx + 1);
  end
end
