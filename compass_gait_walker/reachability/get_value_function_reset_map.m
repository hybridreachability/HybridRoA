function [reset_map, xs_switching_surface, xs_post_assigned] = get_value_function_reset_map(grid, reset_option)
if nargin < 2
    reset_option = 'foot';
end
if strcmp(reset_option, 'angle')
    error("Not implemented. TODO.");
elseif ~strcmp(reset_option, 'foot')
    error("Unknown reset_option.");
end

eps = 1e-5;
N = grid.N;
ind = 1:prod(N);
[Iq1, Iq2, Idq1, Idq2] = ind2sub(N, ind);

reset_map_threshold = -0.03;
idx_q1_negative = find(grid.vs{1} < reset_map_threshold);

Iq1_reset = Iq1;
Iq2_reset = Iq2;
Idq1_reset = Idq1;
Idq2_reset = Idq2;
xs_switching_surface = [];
xs_post_assigned = [];
%% Scanning all the grid points and if it's the reset map condition, apply it.
for j = ind
    iq1 = Iq1(j);
    iq2 = Iq2(j);
    idq1 = Idq1(j);
    idq2 = Idq2(j);
    q1 = grid.vs{1}(iq1);
    q2 = grid.vs{2}(iq2);
    dq1 = grid.vs{3}(idq1);
    dq2 = grid.vs{4}(idq2);
    % reset map is applied when q1 <=0 and q2 = -2*q1 and 2dq1 + dq2 <= 0(which defines the
    % switching surface).
    if abs(q2 + 2 * q1) < eps && any(iq1 == idx_q1_negative) && (2 * dq1 + dq2 <= 0)
        dq1 = grid.vs{3}(idq1);
        dq2 = grid.vs{4}(idq2);
        x_pre = [q1; q2; dq1; dq2];
        x_post_true = reset_map_condensed(x_pre);
        [iq1_post, iq2_post, idq1_post, idq2_post] = ...
            assign_state_to_grid(grid, x_post_true);
        Iq1_reset(j) = iq1_post;
        Iq2_reset(j) = iq2_post;
        Idq1_reset(j) = idq1_post;
        Idq2_reset(j) = idq2_post;
        x_post_assigned = [grid.vs{1}(iq1_post);
            grid.vs{2}(iq2_post);
            grid.vs{3}(idq1_post);
            grid.vs{4}(idq2_post)];
        xs_switching_surface = [xs_switching_surface, x_pre];
        xs_post_assigned = [xs_post_assigned, x_post_assigned];
    end
end % end of the main for loop.

reset_map = sub2ind(N, Iq1_reset, Iq2_reset, Idq1_reset, Idq2_reset);
end

function [iq1, iq2, idq1, idq2] = assign_state_to_grid(grid, x)
    [~, iq1] = min(abs(grid.vs{1} - x(1)));
    [~, iq2] = min(abs(grid.vs{2} - x(2)));
    [~, idq1] = min(abs(grid.vs{3} - x(3)));
    [~, idq2] = min(abs(grid.vs{4} - x(4)));
end