function fig = plot_main_state_history(tRec, xRec, varargin)

kwargs = parse_function_args(varargin{:});
save_file = false;
if isfield(kwargs, 'fig_name')
    save_file = true;
    fig_name = kwargs.fig_name;
end
index_io = [];
if isfield(kwargs, 'index_io')
    index_io = kwargs.index_io;
end
plot_opt_io = ~isempty(index_io);
gait = [];
if isfield(kwargs, 'gait')
    gait = kwargs.gait;
end
indices_reset = [];
if isfield(kwargs, 'indices_reset')
    indices_reset = kwargs.indices_reset;
end

gait_state_else = [];
if plot_opt_io && ~isempty(gait)
    q1_switch = xRec(index_io-1, 3);
    if q1_switch >= gait(end, 1) && q1_switch <= gait(1, 1)
    gait_state_else = [interp1(gait(:, 1), gait(:, 2), q1_switch), ...
        interp1(gait(:, 1), gait(:, 3), q1_switch), ...
        interp1(gait(:, 1), gait(:, 4), q1_switch)];
    end
end
palette = get_palette_colors();
pStRec = pSt_gen(xRec')';
pSwRec = pSw_gen(xRec')';
fig = open_figure('size', 'half-full-width', 'font_size', 14, 'margin', 'tight');
subplot(7, 1, 1)
plot(tRec, xRec(:, 1), 'Color', palette.orange, 'LineWidth', 2); hold on;
plot(tRec, pStRec(:, 1), ':', 'Color', palette.green, 'LineWidth', 1.5);
plot(tRec, pSwRec(:, 1), 'Color', palette.blue, 'LineWidth', 1.5);
legend('torso', 'stance foot', 'swing foot')
ylabel('$p_x$')
set_history_grid(tRec, 'dt', 0.2);
subplot(7, 1, 2)
plot(tRec, xRec(:, 2), 'Color', palette.orange,  'LineWidth', 2);
ylabel('$p_y (torso)$')
set_history_grid(tRec, 'dt', 0.2);
subplot(7, 1, 3)
plot(tRec, pSwRec(:, 2), 'Color', palette.blue, 'LineWidth', 1.5);
ylabel('$p_{swing}$')
set_history_grid(tRec, 'dt', 0.2);
subplot(7, 1, 4)
if ~plot_opt_io
    plot(tRec, xRec(:, 3), 'Color', palette.orange, 'LineWidth', 2)
else
    plot(tRec(1:index_io-1), xRec(1:index_io-1, 3), ...
        'Color', palette.blue, 'LineWidth', 2);
    hold on;
    plot(tRec(index_io:end), xRec(index_io:end, 3), ...
        'Color', palette.orange, 'LineWidth', 2);
    line([tRec(index_io-1), tRec(index_io-1)],get(gca,'YLim'),'Color',palette.magenta, 'LineWidth', 1);
end
if ~isempty(indices_reset)
    for i = 1:length(indices_reset)
        line([tRec(indices_reset(i)), tRec(indices_reset(i))],get(gca,'YLim'),'Color',palette.grey, 'LineWidth', 0.5);        
    end
end
ylabel('$q_1$')
set_history_grid(tRec, 'dt', 0.2, 'index_io', index_io);

subplot(7, 1, 5)
if ~plot_opt_io
    plot(tRec, xRec(:, 4), 'Color', palette.orange, 'LineWidth', 2)
else
    plot(tRec(1:index_io-1), xRec(1:index_io-1, 4), 'Color', palette.blue, 'LineWidth', 2);
    hold on;
    plot(tRec(index_io:end), xRec(index_io:end, 4), 'Color', palette.orange, 'LineWidth', 2);
    line([tRec(index_io-1), tRec(index_io-1)],get(gca,'YLim'),'Color',palette.magenta, 'LineWidth', 1);
    if ~isempty(gait_state_else)
        plot(tRec(index_io-1), gait_state_else(1), 'x', 'Color', palette.grey);
    end
end
if ~isempty(indices_reset)
    for i = 1:length(indices_reset)
        line([tRec(indices_reset(i)), tRec(indices_reset(i))],get(gca,'YLim'),'Color',palette.grey, 'LineWidth', 0.5);        
    end
end
ylabel('$q_2$')
set_history_grid(tRec, 'dt', 0.2, 'index_io', index_io);
subplot(7, 1, 6)
if ~plot_opt_io
    plot(tRec, xRec(:, 7),  'Color', palette.orange, 'LineWidth', 2);
else
    plot(tRec(1:index_io-1), xRec(1:index_io-1, 7), 'Color', palette.blue, 'LineWidth', 2);
    hold on;
    plot(tRec(index_io:end), xRec(index_io:end, 7), 'Color', palette.orange, 'LineWidth', 2);
    line([tRec(index_io-1), tRec(index_io-1)],get(gca,'YLim'),'Color',palette.magenta, 'LineWidth', 1);
    if ~isempty(gait_state_else)
        plot(tRec(index_io-1), gait_state_else(2), 'x', 'Color', palette.grey);
    end
end
if ~isempty(indices_reset)
    for i = 1:length(indices_reset)
        line([tRec(indices_reset(i)), tRec(indices_reset(i))],get(gca,'YLim'),'Color',palette.grey, 'LineWidth', 0.5);        
    end
end
ylabel('$\dot{q}_1$')
set_history_grid(tRec, 'dt', 0.2, 'index_io', index_io);

subplot(7, 1, 7)
if ~plot_opt_io
    plot(tRec, xRec(:, 8), 'Color', palette.orange, 'LineWidth', 2);
else
    plot(tRec(1:index_io-1), xRec(1:index_io-1, 8), 'Color', palette.blue, 'LineWidth', 2);
    hold on;
    plot(tRec(index_io:end), xRec(index_io:end, 8), 'Color', palette.orange, 'LineWidth', 2);
    line([tRec(index_io-1), tRec(index_io-1)],get(gca,'YLim'),'Color',palette.magenta, 'LineWidth', 1);
    if ~isempty(gait_state_else)
        plot(tRec(index_io-1), gait_state_else(3), 'x', 'Color', palette.grey);
    end
end
if ~isempty(indices_reset)
    for i = 1:length(indices_reset)
        line([tRec(indices_reset(i)), tRec(indices_reset(i))],get(gca,'YLim'),'Color',palette.grey, 'LineWidth', 0.5);        
    end
end
ylabel('$\dot{q}_2$')
xlabel('$t$');
set_history_grid(tRec, 'dt', 0.2, 'index_io', index_io);
if save_file
    save_figure('file_name', fig_name);
    save_figure('file_name', fig_name, 'file_format', 'png');    
end

end
