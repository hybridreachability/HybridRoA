function fig = vis_level_set_3d(grid, value_function, gait, level, reset_option, ...
    q1s, add_gait_bound_slices, params)
% visualization of target set or brt in 3D space of (q1dot, q2dot, and q2),
% sliced by different values of q1.
%   reset_option:
%       'angle': Reset is defined as q1 reaching q1_desired.
%       'foot': Reset is defined as foot position reaching the ground (y=0);
if nargin < 4
    level = 0;
end
if nargin < 5
    reset_option = 'foot';
end
if nargin < 6
    q1s = linspace(grid.min(1), grid.max(2), 6);
end

if nargin < 7
    add_gait_bound_slices = true;
end

if nargin < 8
    params.th1d = -0.13;
    params.reset_q1_threshold = -0.03;
end

if add_gait_bound_slices
    % Add start and end q1 of the reference gait and sort again.
    q1s = [q1s, gait(1, 1), gait(end, 1)];
    q1s = sort(q1s);
end

n_q1s = length(q1s);
grid3d = createGrid(grid.min(2:4), grid.max(2:4), grid.N(2:4));

fig = open_figure('size', 'full');
for i = 1:n_q1s
    if (floor(n_q1s/2) == n_q1s/2)
        subplot(2, n_q1s/2, i);
    else
        subplot(1, n_q1s, i);
    end
    q1 = q1s(i);
    if q1 >= gait(end, 1) && q1 <= gait(1, 1)
        gait_state_else = [interp1(gait(:, 1), gait(:, 2), q1), ...
            interp1(gait(:, 1), gait(:, 3), q1), ...
            interp1(gait(:, 1), gait(:, 4), q1)];
    else
        gait_state_else = [];
    end
    % get the slice of the value function at q1
    [~, value_function_3d] = proj(grid, value_function, [1 0 0 0], q1); 
    vis_set_3d_helper(grid3d, value_function_3d, level, reset_option, q1, gait_state_else, params);
end
end

function vis_set_3d_helper(grid3d, value_function_3d, level, reset_option, q1, gait_state_else, params)
palette = get_palette_colors();
% Plot the level set first.
h = visSetIm(grid3d, value_function_3d, palette.blue, level);
h.FaceAlpha = 0.5;
hold on;
% If gait_state_else is not empty, plot it.
if ~isempty(gait_state_else)
    p_gait_state = plot3(gait_state_else(1), gait_state_else(2), gait_state_else(3), 'o');
    p_gait_state.MarkerSize = 4;
    p_gait_state.MarkerFaceColor = palette.black;
end

if strcmp(reset_option, 'angle')
    error("Not Implemented");
elseif strcmp(reset_option, 'foot')
    % switching surface is applied only when q1 <= 0.
    if q1 <= params.reset_q1_threshold
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
        p_switch_surface = plot3(...
            (q2_switch - 0.075) * ones(size_switch), dq1_switch, dq2_switch, 'o');
        p_switch_surface.MarkerFaceColor = palette.magenta;
        p_switch_surface.MarkerEdgeColor = 'none';
        p_switch_surface.MarkerSize = 1;
    end
else    
    error("Unknown reset_option.");
end

axis([grid3d.min(1), grid3d.max(1), grid3d.min(2), grid3d.max(2), grid3d.min(3), grid3d.max(3)]);
xlabel('$q_2$');
ylabel('$\dot{q}_{1}$');
zlabel('$\dot{q}_{2}$');
title(strcat('$q_1=$', num2str(q1)));
view(38.5, 27);
end
