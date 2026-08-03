function u = saturate(u_cmd, u_min, u_max)
%SATURATE Saturacion elementwise entre u_min y u_max.
  u = min(max(u_cmd, u_min), u_max);
end
