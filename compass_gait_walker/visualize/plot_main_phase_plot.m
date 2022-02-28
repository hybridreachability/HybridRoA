function fig = plot_main_phase_plot(tRec, xRec, xRec_tilde, varargin)
if nargin >= 3
    plot_tilde = true;
end

kwargs = parse_function_args(varargin{:});
save_file = false;
if isfield(kwargs, 'fig_name')
    save_file = true;
    fig_name = kwargs.fig_name;
end
gait = [];
if isfield(kwargs, 'gait')
    gait = kwargs.gait;
end
if isfield(kwargs, 'reset_option')
    reset_option = kwargs.reset_option;
else
    reset_option = 'foot';
end
if isfield(kwargs, 'reset_q1_threshold')
    reset_q1_threshold = kwargs.reset_q1_threshold;
else
    reset_q1_threshold = -0.03;
end

index_io = [];
if isfield(kwargs, 'index_io')
    index_io = kwargs.index_io;
end

if isfield(kwargs, 'ax_dx')
    dx = kwargs.ax_dx;
else
    dx = [0.08; 0.08; 0.4; 0.8];
end

if isfield(kwargs, 'ax_min')
    ax_min = kwargs.ax_min;
else
    q1_min = min([min(xRec(:, 3)), min(gait(:, 1))])-dx(1);
    q2_min = min([min(xRec(:, 4)), min(gait(:, 2))])-dx(2);
    dq1_min = min([min(xRec(:, 7)), min(gait(:, 3))])-dx(3);
    dq2_min = min([min(xRec(:, 8)), min(gait(:, 4))])-dx(4);
    ax_min = [q1_min; q2_min; dq1_min; dq2_min];
end

if isfield(kwargs, 'ax_max')
    ax_max = kwargs.ax_max;
else
    q1_max = max([max(xRec(:, 3)), max(gait(:, 1))])+dx(1);
    q2_max = max([max(xRec(:, 4)), max(gait(:, 2))])+dx(2);
    dq1_max = max([max(xRec(:, 7)), max(gait(:, 3))])+dx(3);
    dq2_max = max([max(xRec(:, 8)), max(gait(:, 4))])+dx(4);
    ax_max = [q1_max; q2_max; dq1_max; dq2_max];
end

q1_range = [ax_min(1), ax_max(1)];
q2_range = [ax_min(2), ax_max(2)];
dq1_range = [ax_min(3), ax_max(3)];
dq2_range = [ax_min(4), ax_max(4)];
q1_tick = ax_min(1):dx(1):ax_max(1);
q1_tick = [q1_tick, 0];
q1_tick = sort(q1_tick);
q2_tick = ax_min(2):dx(2):ax_max(2);
dq1_tick = ax_min(3):dx(3):ax_max(3);
dq2_tick = ax_min(4):dx(4):ax_max(4);

length_traj = length(tRec);
palette = get_palette_colors();
% history_color_map =  get_color_map([palette.blue; palette.yellow; palette.magenta], ...
%     [floor(length_traj/2), length_traj-1-floor(length_traj/2)]);
if isempty(index_io) || index_io == 1
   history_color_map =  get_color_map([palette.orange; palette.yellow; palette.green], ...
    length_traj-1);
else
%    history_color_map_opt = repmat(palette.blue, index_io-1, 1);
   history_color_map_opt = get_color_map([palette.blue; 0.25 * palette.white + 0.75 * palette.blue], ...
       index_io-2);
   history_color_map_io =  get_color_map([palette.orange; palette.yellow; palette.green], ...
    length_traj-index_io);
   history_color_map = [history_color_map_opt; history_color_map_io];
end
history_size = linspace(20, 5, length_traj);
fig = open_figure('font_size', 14, 'margin', 'tight');
ax = subplot(2, 2, 1);
s = scatter(xRec(:, 3), xRec(:, 4), history_size, history_color_map, 'filled');
hold on;
if ~isempty(gait)
    p_q_gait = plot(gait(:, 1), gait(:, 2), 'k-.');
    p_q_gait.LineWidth = 1.5;
end
if strcmp(reset_option, 'foot')
    syms q1
    p_reset = fplot(-2 * q1, [ax_min(1), reset_q1_threshold]);
    p_reset.Color = palette.grey;
    p_reset.LineWidth = 1.5;
    % To indicate that this line is below the ground
    p_reset = fplot(-2 * q1 + 0.075 * sign(q1), [ax_min(1), reset_q1_threshold]); 
    p_reset.Color = palette.grey;
    p_reset.LineWidth = 1;
    p_reset = fplot(-2 * q1 + 0.15 * sign(q1), [ax_min(1), reset_q1_threshold]); 
    p_reset.Color = palette.grey;
    p_reset.LineWidth = 0.5;
elseif strcmp(reset_option, 'angle')
    p_reset = line([gait(end, 1), gait(end, 1)], ...
        get(gca, 'YLim'), 'Color', palette.grey);
    p_reset.LineWidth = 1.5;
    p_reset = line([gait(end, 1) - 0.02, gait(end, 1) - 0.02], ...
        get(gca, 'YLim'), 'Color', palette.grey);
    p_reset.LineWidth = 1;
    p_reset = line([gait(end, 1) - 0.04, gait(end, 1) - 0.04], ...
        get(gca, 'YLim'), 'Color', palette.grey);
    p_reset.LineWidth = 0.5;
else
    error("Unknown reset_option.");
end
xlabel('$q_1$');
ylabel('$q_2$');
ax.XTick = q1_tick;
ax.YTick = q2_tick;
axis([q1_range, q2_range]);
grid on;

ax = subplot(2, 2, 2);
s = scatter(xRec(:, 8), xRec(:, 4), history_size, history_color_map, 'filled');
hold on;
if ~isempty(gait)
    p_qdq_gait = plot(gait(:, 4), gait(:, 2), 'k-.');
    p_qdq_gait.LineWidth = 1.5;
end
xlabel('$\dot{q}_2$');
ylabel('$q_2$');
ax.XTick = dq2_tick;
ax.YTick = q2_tick;
axis([dq2_range, q2_range]);
grid on;

ax = subplot(2, 2, 3);
s = scatter(xRec(:, 3), xRec(:, 7), history_size, history_color_map, 'filled');
hold on;
if ~isempty(gait)
    p_ydy_gait = plot(gait(:, 1), gait(:, 3), 'k-.');
    p_ydy_gait.LineWidth = 1.5;
end
xlabel('$q_1$');
ylabel('$\dot{q}_1$');
ax.XTick = q1_tick;
ax.YTick = dq1_tick;
axis([q1_range, dq1_range]);
grid on;

ax = subplot(2, 2, 4);
s = scatter(xRec(:, 8), xRec(:, 7), history_size, history_color_map, 'filled');
hold on;
if ~isempty(gait)
    p_dq_gait = plot(gait(:, 4), gait(:, 3), 'k-.');
    p_dq_gait.LineWidth = 1.5;
end
xlabel('$\dot{q}_2$');
ylabel('$\dot{q}_1$');
ax.XTick = dq2_tick;
ax.YTick = dq1_tick;
axis([dq2_range, dq1_range]);
grid on;
% plot(xRec_tilde(:, 4), xRec_tilde(:, 8));
% xlabel('$q_1$'); ylabel('dq1');
% subplot(2, 2, 2);
% plot(xRec_tilde(:, 3), xRec_tilde(:, 7));
% xlabel('y'); ylabel('dy');

if save_file
    save_figure('file_name', fig_name, 'figure_size', [16, 12]);
    save_figure('file_name', fig_name, 'file_format', 'png', 'figure_size', [16, 12]);    
end