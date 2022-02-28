function fig = plot_main_phase_plot_for_comparison(trajOpt, trajFL, varargin)
xRec = [];
tRec = [];
if ~isempty(trajOpt)
xRec = trajOpt.xRec;
tRec = trajOpt.tRec;
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
if ~isempty(trajOpt) && isfield(trajOpt.extraOuts, 'index_io')
    index_io = trajOpt.extraOuts.index_io;
end

if isfield(kwargs, 'ax_dx')
    dx = kwargs.ax_dx;
else
    dx = [0.08; 0.08; 0.4; 0.8];
end

if isfield(kwargs, 'ax_min')
    ax_min = kwargs.ax_min;
else
%     q1_min = min([min(xRec(:, 3)), min(gait(:, 1))])-dx(1);
%     q2_min = min([min(xRec(:, 4)), min(gait(:, 2))])-dx(2);
    q1_min = -0.2;
%     q2_min = -0.8;
    q2_min = -0.6;
    ax_min = [q1_min; q2_min];
end

if isfield(kwargs, 'ax_max')
    ax_max = kwargs.ax_max;
else
    
%     q1_max = max([max(xRec(:, 3)), max(gait(:, 1))])+dx(1);
%     q2_max = max([max(xRec(:, 4)), max(gait(:, 2))])+dx(2);
%     q1_max = max([max(xRec(:, 3)), max(gait(:, 1)), max(trajFL.xRec(:, 3))])+dx(1);
%     q2_max = max([max(xRec(:, 4)), max(gait(:, 2)), max(trajFL.xRec(:, 4))])+dx(2);
%     q1_max = 0.4;
    q2_max = 0.6;
    q1_max = 0.3;
    q2_max = 0.4;

    ax_max = [q1_max; q2_max];
end

t_fl_max = [];
if isfield(kwargs, 't_fl_max')
    t_fl_max = kwargs.t_fl_max;
end

q1_range = [ax_min(1), ax_max(1)];
q2_range = [ax_min(2), ax_max(2)];
q1_tick = ax_min(1):dx(1):ax_max(1);
q1_tick = [q1_tick, 0];
q1_tick = sort(q1_tick);
q2_tick = ax_min(2):dx(2):ax_max(2);

length_traj = length(tRec);
palette = get_palette_colors();
fig = open_figure('font_size', 14, 'size', [400, 600]);


palette.final_color = 0.1 * palette.orange + 0.9 * palette.white;

%% Plot FL trajectory
if ~isempty(trajFL) && ~isempty(trajFL.tRec)
    if isempty(t_fl_max)
        index_t_max_fl = length(trajFL.tRec);
    else
        index_t_max_fl = length(trajFL.tRec(trajFL.tRec<t_fl_max));
    end
    history_size = linspace(10, 5, index_t_max_fl);
    history_color_map_fl = get_color_map([palette.orange; palette.white], index_t_max_fl-1);
    s_fl = scatter(trajFL.xRec(1:index_t_max_fl, 3), trajFL.xRec(1:index_t_max_fl, 4), history_size, history_color_map_fl, 'filled');
    hold on;
end

%% Plot Optimal trajectory
if ~isempty(trajOpt) && ~isempty(trajOpt.tRec)
if isempty(index_io) || index_io == 1
   history_color_map =  get_color_map([palette.orange; palette.yellow; palette.green], ...
    length_traj-1);
else
   ratio_opt = (index_io -1) / length_traj;
   history_color_map_opt = get_color_map([palette.blue; ratio_opt * palette.final_color + (1-ratio_opt) * palette.blue], ...
       index_io-2);
   history_color_map_opt = get_color_map([0.5 * palette.navy + 0.5 * palette.blue; palette.blue], ...
       index_io-2);
   if ratio_opt < 0.5
       history_color_map_io =  get_color_map([ratio_opt * palette.final_color + (1-ratio_opt) * palette.orange;
           2 * ratio_opt * palette.final_color + (1-2 * ratio_opt) * palette.yellow; palette.final_color], ...
        length_traj-index_io);
       history_color_map_io =  get_color_map([palette.orange; palette.final_color], ...
        length_traj-index_io);
   else
       history_color_map_io =  get_color_map([ratio_opt * palette.final_color + (1-ratio_opt) * palette.orange; palette.final_color], ...
        length_traj-index_io);       
   end
   history_color_map = [history_color_map_opt; history_color_map_io];
end
history_size = linspace(30, 15, length_traj);
s = scatter(flip(xRec(:, 3)), flip(xRec(:, 4)), flip(history_size), flip(history_color_map), 'filled');
hold on;
end

if ~isempty(gait)
    p_q_gait = plot(gait(:, 1), gait(:, 2), 'k-.');
    p_q_gait.LineWidth = 1.5;
    hold on;
end
if strcmp(reset_option, 'foot')
    syms q1
    p_reset = fplot(-2 * q1, [ax_min(1), reset_q1_threshold]);
    p_reset.Color = palette.magenta;
    p_reset.LineWidth = 1.5;
    hold on;
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

if save_file
    save_figure('file_name', fig_name, 'figure_size', [4, 6]);
    save_figure('file_name', fig_name, 'file_format', 'pdf', 'figure_size', [4, 6]);    
end