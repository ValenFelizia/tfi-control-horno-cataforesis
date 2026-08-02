%RUN_ALL Orquesta la verificacion del modelo nominal en Octave.
%
%  Uso:
%    cd octave
%    octave-cli --no-gui run_all.m
%
%  No incluye PI, lazo cerrado ni saturacion dinamica.

clear; close all; clc;

this_dir = fileparts(mfilename('fullpath'));
if isempty(this_dir)
  this_dir = pwd;
end
cd(this_dir);
addpath(fullfile(this_dir, 'utils'));

fprintf('TFI SCI — modelo nominal (planta abierta)\n');
fprintf('Paquete control requerido.\n');

pkg load control;

% En esta instalacion CLI solo hay fltk/gnuplot; las figuras deben ser visibles
% para poder exportar PNG con fltk.
set(0, 'defaultfigurevisible', 'on');

p = parametros();
m = modelo_planta(p);
info = analisis_planta(p, m);
met = respuesta_planta(p, m);

fprintf('\n=== Resumen modelo nominal ===\n');
fprintf('dcgain(Gp)           = %.6f degC/p.u.\n', info.dcgain);
fprintf('wn                   = %.7f rad/s\n', info.wn);
fprintf('zeta                 = %.6f\n', info.zeta);
fprintf('clasificacion        = %s\n', info.classification);
fprintf('Delta T(inf) @dv=0.04= %.6f degC\n', met.theta_inf);
fprintf('Delta Qh(inf)        = %.6f kW\n', met.qh_inf_W / 1000);
fprintf('u_final              = %.4f p.u.\n', met.u_final);
fprintf('overshoot            = %.4f %%\n', met.OS_pct);
fprintf('rise time 10-90 %%    = %.2f s\n', met.tr_10_90_s);
fprintf('settling time ±5 %%   = %.2f s\n', met.ts_5pct_s);
fprintf('theta(inf) @dqL=50kW = %.6f degC\n', met.theta_L_inf);
fprintf('\nModelo nominal verificado.\n');
