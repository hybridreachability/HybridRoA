function vis_level_set_2d_compare(data_id_strs, caption_strs, ...
    line_colors, line_styles, ...
    t_max, fig_name, reset_option, reset_q1_threshold)

if nargin < 7
    reset_option = 'foot';
end
if nargin < 8
    reset_q1_threshold = -0.03;
end
level = -0.001;

n_vis = length(data_id_strs);


grid_file_str = strcat(data_id_strs{1}, 'grid');
gait_file_str = strcat(data_id_strs{1}, 'gait');
load(grid_file_str, 'grid');
load(gait_file_str, 'gait_params', 'gait');

q1_tick = grid.min(1):4*grid.dx(1):grid.max(1);
q2_tick = grid.min(2):4*grid.dx(2):grid.max(2);
dq1_tick = grid.min(3):4*grid.dx(3):grid.max(3);
dq2_tick = grid.min(4):4*grid.dx(4):grid.max(4);

% Load BRT data to visualize
palette = get_palette_colors();
data_brts = cell(n_vis, 1);
for i_vis = 1:n_vis
    data_i_id_str = strcat(data_id_strs{i_vis}, num2str(1000*t_max), '.mat');
    load(data_i_id_str, 'data');
    data_brts{i_vis} = squeeze(data(:, :, :, :, end));
end

fig = open_figure('font_size', 14, 'margin', 'tight');

ax = subplot(2, 2, 1);
dims_remove = [0 0 1 1];
data_brts_2d = cell(n_vis, 1);
for i_vis = 1:n_vis
    % Project data to the corresponding axes.
    [g2d, data_brt_i_2d] = proj(grid, data_brts{i_vis}, dims_remove, 'min');
    data_brts_2d{i_vis} = data_brt_i_2d;    
    % Visualize data.
    [~, h] = contour(g2d.xs{1}, g2d.xs{2}, data_brt_i_2d, [level, level], 'color', line_colors{i_vis});
    if i_vis == n_vis
        h.LineWidth = 2.0;
    else
        h.LineWidth = 1.5;
    end
    h.LineStyle = line_styles{i_vis};
    hold on;
end

if ~isempty(gait)
    p_q_gait = plot(gait(:, 1), gait(:, 2), 'k-.');
    p_q_gait.LineWidth = 1.5;
end
if strcmp(reset_option, 'foot')
    syms q1
    p_reset = fplot(-2 * q1, [grid.min(1), reset_q1_threshold]);
    p_reset.Color = palette.magenta;
    p_reset.LineWidth = 1.5;
    % To indicate that this line is below the ground
    p_reset = fplot(-2 * q1 + 0.075 * sign(q1), [grid.min(1), reset_q1_threshold]); 
    p_reset.Color = palette.magenta;
    p_reset.LineWidth = 1;
    p_reset = fplot(-2 * q1 + 0.15 * sign(q1), [grid.min(1), reset_q1_threshold]); 
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
axis([grid.min(1), grid.max(1), grid.min(2), grid.max(2)]);


ax = subplot(2, 2, 2);
dims_remove = [1 0 1 0];
data_brts_2d = cell(n_vis, 1);
for i_vis = 1:n_vis
    % Project data to the corresponding axes.
    [g2d, data_brt_i_2d] = proj(grid, data_brts{i_vis}, dims_remove, 'min');
    data_brts_2d{i_vis} = data_brt_i_2d;    
    % Visualize data.
    [~, h] = contour(g2d.xs{2}, g2d.xs{1}, data_brt_i_2d, [level, level], 'color', line_colors{i_vis});
    if i_vis == n_vis
        h.LineWidth = 2.0;
    else
        h.LineWidth = 1.5;
    end
    h.LineStyle = line_styles{i_vis};
    hold on;
end
if ~isempty(gait)
    p_qdq_gait = plot(gait(:, 4), gait(:, 2), 'k-.');
    p_qdq_gait.LineWidth = 1.5;
end
xlabel('$\dot{q}_2$');
ylabel('$q_2$');
ax.XTick = dq2_tick;
ax.YTick = q2_tick;
axis([grid.min(4), grid.max(4), grid.min(2), grid.max(2)]);

ax = subplot(2, 2, 3);
dims_remove = [0 1 0 1];
data_brts_2d = cell(n_vis, 1);
for i_vis = 1:n_vis
    % Project data to the corresponding axes.
    [g2d, data_brt_i_2d] = proj(grid, data_brts{i_vis}, dims_remove, 'min');
    data_brts_2d{i_vis} = data_brt_i_2d;    
    % Visualize data.
    [~, h] = contour(g2d.xs{1}, g2d.xs{2}, data_brt_i_2d, [level, level], 'color', line_colors{i_vis});
    if i_vis == n_vis
        h.LineWidth = 2.0;
    else
        h.LineWidth = 1.5;
    end
    h.LineStyle = line_styles{i_vis};
    hold on;
end
if ~isempty(gait)
    p_ydy_gait = plot(gait(:, 1), gait(:, 3), 'k-.');
    p_ydy_gait.LineWidth = 1.5;
end
xlabel('$q_1$');
ylabel('$\dot{q}_1$');
ax.XTick = q1_tick;
ax.YTick = dq1_tick;
axis([grid.min(1), grid.max(1), grid.min(3), grid.max(3)]);

ax = subplot(2, 2, 4);
dims_remove = [1 1 0 0];
data_brts_2d = cell(n_vis, 1);
for i_vis = 1:n_vis
    % Project data to the corresponding axes.
    [g2d, data_brt_i_2d] = proj(grid, data_brts{i_vis}, dims_remove, 'min');
    data_brts_2d{i_vis} = data_brt_i_2d;    
    % Visualize data.
    [~, h] = contour(g2d.xs{2}, g2d.xs{1}, data_brt_i_2d, [level, level], 'color', line_colors{i_vis});
    if i_vis == n_vis
        h.LineWidth = 2.0;
    else
        h.LineWidth = 1.5;
    end
    h.LineStyle = line_styles{i_vis};
    hold on;
end
if ~isempty(gait)
    p_dq_gait = plot(gait(:, 4), gait(:, 3), 'k-.');
    p_dq_gait.LineWidth = 1.5;
end
xlabel('$\dot{q}_2$', 'Interpreter', 'latex');
ylabel('$\dot{q}_1$', 'Interpreter', 'latex');
ax.XTick = dq2_tick;
ax.YTick = dq1_tick;
axis([grid.min(4), grid.max(4), grid.min(3), grid.max(3)]);

save_figure('file_name', fig_name, ...
        'file_format', 'png');