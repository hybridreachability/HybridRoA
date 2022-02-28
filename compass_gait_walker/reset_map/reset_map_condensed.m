function xs_post = reset_map_condensed(xs_pre)
% INPUTS: xs_pre: 4 * N array of condensed states before reset.
% OUTPUTS: xs_post: 4 * N array of condensed states after reset.

R = [1, 1;
     0, -1];
q_post = R * xs_pre(1:2, :); 
dq_post = R * dq_post_impact_condensed(xs_pre);
xs_post = [q_post; dq_post];
end

