function fig = vis_level_set_2d(grid_value, value_function, varargin)
%% gait: reference gait as state history
%   level: the level of the value function to slice.
%   reset_option:
%       'angle': Reset is defined as q1 reaching q1_desired.
%       'foot': Reset is defined as foot position reaching the ground (y=0);
kwargs = parse_function_args_with_default_values( ...
    {'gait', 'level', 'reset_option', 'reset_q1_threshold', 'color_option'}, ...
    {[], 0, 'foot', -0.03, 'value'}, varargin{:});

color_option = kwargs.color_option;
gait = kwargs.gait;
level = kwargs.level;
reset_option = kwargs.reset_option;
reset_q1_threshold = kwargs.reset_q1_threshold;
    
size_grid_value = prod(grid_value.N);
%% Convert cells to arrays in appropriate size.
x_temp = reshape(grid_value.xs, [ones(1, 4), 4]);
x_temp = cell2mat(x_temp);
x_temp = permute(x_temp, [5, 1:4]);
xs_array = reshape(x_temp, 4, [])';
ls_array = reshape(value_function, 1, []);
if verLessThan('matlab', '9.4')
min_ls = min(ls_array, [], 1); min_ls = min(min_ls, [], 1); min_ls = min(min_ls, [], 1); min_ls = min(min_ls);
max_ls = max(ls_array, [], 1); max_ls = max(max_ls, [], 1); max_ls = max(max_ls, [], 1); max_ls = max(max_ls);
else
min_ls = min(ls_array, [], 'all');
max_ls = max(ls_array, [], 'all');
end

palette = get_palette_colors();
if strcmp(color_option, 'value')
    color_min = palette.blue;
    color_level = palette.yellow;
    color_max = palette.orange;
    color_ls_array = zeros(size_grid_value, 3);
    for i = 1:size_grid_value
    l_i = ls_array(i);
    if l_i < level
        ratio_min = (level - l_i) / (level - min_ls);
        color_ls_array(i, :) = (ratio_min * color_min + (1 - ratio_min) * color_level);
    elseif l_i >= level
        ratio_max = (l_i - level) / (max_ls - level);
        color_ls_array(i, :) = (ratio_max * color_max + (1 - ratio_max) * color_level);
    end
    end
elseif strcmp(color_option, 'mono')
    color_ls_array = repmat(0.25 * palette.blue + 0.75 * palette.white, size_grid_value, 1);    
else
    error("Unknown color mode.");
end


in_set_indices = find(ls_array <= level);
xs_array_in_set = xs_array(in_set_indices, :);
color_ls_array_in_set = color_ls_array(in_set_indices, :);

if strcmp(color_option, 'value')
    scatter_size = 20;
else
    scatter_size = 50;
end

q1_tick = grid_value.min(1):4*grid_value.dx(1):grid_value.max(1);
q2_tick = grid_value.min(2):4*grid_value.dx(2):grid_value.max(2);
dq1_tick = grid_value.min(3):4*grid_value.dx(3):grid_value.max(3);
dq2_tick = grid_value.min(4):4*grid_value.dx(4):grid_value.max(4);

fig = open_figure('font_size', 14);
ax = subplot(2, 2, 1);
s_q_data = scatter(xs_array_in_set(:, 1), xs_array_in_set(:, 2), ...
    scatter_size, color_ls_array_in_set, 'filled');
% if strcmp(color_option, 'mono')
%     s_q_data.MarkerFaceAlpha = 0.25;
% end
hold on;
if ~isempty(gait)
    p_q_gait = plot(gait(:, 1), gait(:, 2), 'k-.');
    p_q_gait.LineWidth = 1.5;
end
if strcmp(reset_option, 'foot')
    syms q1
    p_reset = fplot(-2 * q1, [grid_value.min(1), reset_q1_threshold]);
    p_reset.Color = palette.magenta;
    p_reset.LineWidth = 1.5;
    % To indicate that this line is below the ground
    p_reset = fplot(-2 * q1 + 0.02 * sign(q1), [grid_value.min(1), reset_q1_threshold]); 
    p_reset.Color = palette.magenta;
    p_reset.LineWidth = 1;
    p_reset = fplot(-2 * q1 + 0.04 * sign(q1), [grid_value.min(1), reset_q1_threshold]); 
    p_reset.Color = palette.magenta;
    p_reset.LineWidth = 0.5;
elseif strcmp(reset_option, 'angle')
    p_reset = line([gait(end, 1), gait(end, 1)], ...
        get(gca, 'YLim'), 'Color', palette.magenta);
    p_reset.LineWidth = 1.5;
    p_reset = line([gait(end, 1) - 0.02, gait(end, 1) - 0.02], ...
        get(gca, 'YLim'), 'Color', palette.magenta);
    p_reset.LineWidth = 1;
    p_reset = line([gait(end, 1) - 0.04, gait(end, 1) - 0.04], ...
        get(gca, 'YLim'), 'Color', palette.magenta);
    p_reset.LineWidth = 0.5;
else
    error("Unknown reset_option.");
end
xlabel('$q_1$');
ylabel('$q_2$');
ax.XTick = q1_tick;
ax.YTick = q2_tick;
axis([grid_value.min(1), grid_value.max(1), grid_value.min(2), grid_value.max(2)]);
grid on

ax = subplot(2, 2, 2);
s_qdq_data = scatter(xs_array_in_set(:, 4), xs_array_in_set(:, 2), ...
    scatter_size, color_ls_array_in_set, 'filled');
hold on;
if ~isempty(gait)
    p_qdq_gait = plot(gait(:, 4), gait(:, 2), 'k-.');
    p_qdq_gait.LineWidth = 1.5;
end
xlabel('$\dot{q}_2$');
ylabel('$q_2$');
ax.XTick = dq2_tick;
ax.YTick = q2_tick;
axis([grid_value.min(4), grid_value.max(4), grid_value.min(2), grid_value.max(2)]);
grid on

ax = subplot(2, 2, 3);
s_ydy_data = scatter(xs_array_in_set(:, 1), xs_array_in_set(:, 3), ...
    scatter_size, color_ls_array_in_set, 'filled');
hold on;
if ~isempty(gait)
    p_ydy_gait = plot(gait(:, 1), gait(:, 3), 'k-.');
    p_ydy_gait.LineWidth = 1.5;
end
xlabel('$q_1$');
ylabel('$\dot{q}_1$');
ax.XTick = q1_tick;
ax.YTick = dq1_tick;
axis([grid_value.min(1), grid_value.max(1), grid_value.min(3), grid_value.max(3)]);
grid on

ax = subplot(2, 2, 4);
s_dq_data = scatter(xs_array_in_set(:, 4), xs_array_in_set(:, 3), ...
    scatter_size, color_ls_array_in_set, 'filled');
hold on;
if ~isempty(gait)
    p_dq_gait = plot(gait(:, 4), gait(:, 3), 'k-.');
    p_dq_gait.LineWidth = 1.5;
end
xlabel('$\dot{q}_2$', 'Interpreter', 'latex');
ylabel('$\dot{q}_1$', 'Interpreter', 'latex');
ax.XTick = dq2_tick;
ax.YTick = dq1_tick;
axis([grid_value.min(4), grid_value.max(4), grid_value.min(3), grid_value.max(3)]);
grid on

fprintf("value function min: %.4f, max: %.4f \t num of grid points in the set: %d\n" , ...
    [min_ls, max_ls, length(in_set_indices)]);