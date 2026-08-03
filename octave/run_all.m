%RUN_ALL Orquesta planta abierta y controlador PI en Octave.
%
%  Uso:
%    cd octave
%    octave-cli --no-gui run_all.m

clear; close all; clc;

this_dir = fileparts(mfilename('fullpath'));
if isempty(this_dir)
  this_dir = pwd;
end
cd(this_dir);
addpath(fullfile(this_dir, 'utils'));

fprintf('TFI SCI — modelo nominal + controlador PI\n');
fprintf('Paquete control requerido.\n');

pkg load control;
set(0, 'defaultfigurevisible', 'on');

p = parametros();
m = modelo_planta(p);
info = analisis_planta(p, m);
met_ol = respuesta_planta(p, m);
ctl = diseno_controlador_pi(p, m);
met_cl = simulacion_lazo_cerrado(p, m, ctl);

fprintf('\n=== Resumen planta abierta ===\n');
fprintf('dcgain(Gp)           = %.6f degC/p.u.\n', info.dcgain);
fprintf('wn                   = %.7f rad/s\n', info.wn);
fprintf('zeta                 = %.6f\n', info.zeta);
fprintf('rise time 10-90 %%    = %.2f s\n', met_ol.tr_10_90_s);
fprintf('settling time ±5 %%   = %.2f s\n', met_ol.ts_5pct_s);

fprintf('\n=== Resumen PI ===\n');
fprintf('Kp=%.6g  Ti=%.6g  Ki=%.10g\n', p.Kp, p.Ti_s, p.Ki);
fprintf('tipo L               = %d\n', ctl.type_L);
fprintf('wn T minima          = %.8f rad/s\n', ctl.wn);
fprintf('zeta T minima        = %.6f\n', ctl.zeta);
fprintf('polos T minima       = %.8f  %.8f\n', ctl.poles_Tmin(1), ctl.poles_Tmin(2));
fprintf('eigs aumentados      = %.8f  %.8f  %.8f\n', ...
        ctl.eigs_aug(1), ctl.eigs_aug(2), ctl.eigs_aug(3));
fprintf('Pm                   = %.4f deg\n', ctl.Pm);
fprintf('w_cg                 = %.7f rad/s\n', ctl.w_gain_cross);
fprintf('ref rise 10-90 %%     = %.2f s\n', met_cl.ref.tr);
fprintf('ref settling ±5 %%    = %.2f s\n', met_cl.ref.ts);
fprintf('ref u_max            = %.6f\n', met_cl.ref.u_max);
fprintf('ref saturacion       = %d\n', met_cl.ref.any_sat);
fprintf('dist theta_min       = %.5f degC\n', met_cl.dist.theta_min);
fprintf('dist retorno ±2 degC  = %.2f s\n', met_cl.dist.t_pm2);
fprintf('dist saturacion      = %d\n', met_cl.dist.any_sat);

fprintf('\nVerificacion planta abierta + PI finalizada.\n');
