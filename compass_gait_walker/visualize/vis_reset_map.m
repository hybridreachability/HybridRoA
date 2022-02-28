function vis_reset_map(grid, gait, reset_option, q1s, add_gait_bound_slices)
% visualization of target set or brt in 3D space of (q1dot, q2dot, and q2),
% sliced by different values of q1.
%   reset_option:
%       'angle': Reset is defined as q1 reaching q1_desired.
%       'foot': Reset is defined as foot position reaching the ground (y=0);
if grid.min(1) ~= -grid.max(1)
    error("this visualization will have error with the grid provided because grid.min(1) ~= -grid.max(1)");
end
if nargin < 2
    gait = [];
end
if nargin < 3
    reset_option = 'foot';
end
if nargin < 4
    q1s = linspace(grid.min(1), grid.max(1), 6);
end

if nargin < 7
    add_gait_bound_slices = true;
end

if add_gait_bound_slices && ~isempty(gait)
    % Add start and end q1 of the reference gait and sort again.
    q1s = [q1s, gait(1, 1), gait(end, 1)];
    q1s = sort(q1s);
end

n_q1s = length(q1s);
grid3d = createGrid(grid.min(2:4), grid.max(2:4), grid.N(2:4));

open_figure('size', 'full', 'font_size', 14);
for i = 1:n_q1s
    vis_reset_map_3d_helper(i, q1s, grid3d, reset_option, gait);
end
end

function vis_reset_map_3d_helper(i, q1s, grid3d, reset_option, gait)
if strcmp(reset_option, 'angle')
    error("Not implemented. TODO.");
elseif ~strcmp(reset_option, 'foot')
    error("Unknown reset_option.");
end
palette = get_palette_colors();

n_q1s = length(q1s);
q1 = q1s(i);

%% Plot the post-reset-map states (state on the switching surface) first.
if (floor(n_q1s/2) == n_q1s/2)
    subplot(2, n_q1s/2, i);
else
    subplot(1, n_q1s, i);
end

% Plot reference gait if it exists.
if q1 >= gait(end, 1) && q1 <= gait(1, 1)
    gait_state_else = [interp1(gait(:, 1), gait(:, 2), q1), ...
        interp1(gait(:, 1), gait(:, 3), q1), ...
        interp1(gait(:, 1), gait(:, 4), q1)];
else
    gait_state_else = [];
end

% If gait_state_else is not empty, plot it.
if ~isempty(gait_state_else)
    p_gait_state = plot3(gait_state_else(1), gait_state_else(2), gait_state_else(3), 'o');
    p_gait_state.MarkerSize = 5;
    p_gait_state.MarkerFaceColor = palette.black;
end
hold on;
% axis([grid3d.min(1), grid3d.max(1), grid3d.min(2), grid3d.max(2), grid3d.min(3), grid3d.max(3)]);
xlabel('$q_2$');
ylabel('$\dot{q}_{1}$');
zlabel('$\dot{q}_{2}$');
title(strcat('$q_1=$', num2str(q1)));
view(38.5, 27);

% switching surface is applied only when q1 <= 0.
if q1 <=0
    q2_switch = -2 * q1;
    grid2d_dq12 = createGrid(grid3d.min(2:3), ...
        grid3d.max(2:3), grid3d.N(2:3));
    dq1s = grid2d_dq12.xs{1};
    dq2s = grid2d_dq12.xs{2};
    dq1_switch = dq1s(dq2s + 2 * dq1s <= 0);
    dq2_switch = dq2s(dq2s + 2 * dq1s <= 0);
    size_switch = size(dq1_switch);
        
    p_switch_surface = plot3(...
        q2_switch * ones(size_switch), dq1_switch, dq2_switch, 'o');
    p_switch_surface.MarkerFaceColor = palette.magenta;
    p_switch_surface.MarkerEdgeColor = 'none';
    p_switch_surface.MarkerSize = 2;

    %% Evaluate post-reset states
    q1_post = -q1; % q1_post = q1_pre + q2_pre = -q1_pre;
    q2_post = -q2_switch;
    dq1_post = zeros(size_switch);
    dq2_post = zeros(size_switch);
    for j = 1:size_switch(1)
        dq1 = dq1_switch(j);
        dq2 = dq2_switch(j);
        xs_pre_temp = [q1; q2_switch; dq1; dq2];
        xs_post = reset_map_condensed(xs_pre_temp);
        dq1_post(j) = xs_post(3);
        dq2_post(j) = xs_post(4);
    end
    if (floor(n_q1s/2) == n_q1s/2)
        subplot(2, n_q1s/2, n_q1s+1-i);
    else
        subplot(1, n_q1s, n_q1s+1-i);
    end
    p_post_reset = plot3(...
        q2_post * ones(size_switch), dq1_post, dq2_post, 'o');
    p_post_reset.MarkerFaceColor =  palette.orange;
    p_post_reset.MarkerEdgeColor = 'none';
    p_post_reset.MarkerSize = 2;
    hold on;
end
end