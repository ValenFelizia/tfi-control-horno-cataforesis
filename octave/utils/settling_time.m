function ts = settling_time(t, y, y_final, band_frac)
%SETTLING_TIME Tiempo de establecimiento con banda relativa simetrica.
%
%  Convencion explicita: settling time ± (band_frac*100) %
%  Es el primer instante a partir del cual |y(t) - y_final| permanece
%  dentro de band_frac * |y_final - y(1)| (amplitud del escalon), o si
%  y_final==y(1) se usa |y_final|.
%
%  Para banda del 5 %, llamar con band_frac = 0.05.

  amp = abs(y_final - y(1));
  if amp < 10 * eps
    amp = abs(y_final);
  end
  band = band_frac * amp;
  outside = abs(y - y_final) > band;
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
