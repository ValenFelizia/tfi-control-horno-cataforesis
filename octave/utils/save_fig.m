function save_fig(fig, name)
%SAVE_FIG Guarda una figura PNG de forma determinista en ../figuras/

  this_dir = fileparts(mfilename('fullpath'));
  out_dir = fullfile(this_dir, '..', '..', 'figuras');
  if ~exist(out_dir, 'dir')
    mkdir(out_dir);
  end
  out_path = fullfile(out_dir, [name '.png']);
  print(fig, out_path, '-dpng', '-r150');
  fprintf('Figura guardada: %s\n', out_path);
end
