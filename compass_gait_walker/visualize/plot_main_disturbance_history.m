function fig = plot_main_disturbance_history(tRec, xRec, varargin)

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

gait_params = [];
if isfield(kwargs, 'gait_params')
    gait_params = kwargs.gait_params;
else
    error("gait_params is required.");
end

fig = open_figure('font_size', 14, 'margin', 'tight');
palette = get_palette_colors();

dRec = zeros(length(tRec), 1);
for i=1:length(tRec)
    x = xRec(i, :)';
    d = two_link_disturbance(x, gait_params);
    dRec(i) = d;
end

if ~plot_opt_io
    plot(tRec, dRec(:, 1), 'LineWidth', 2)
else
%     plot(tRec(1:index_io-1), uRec(1:index_io-1, 1), 'Color', palette.blue, 'LineWidth', 2);
    s = scatter(tRec(1:index_io-1), dRec(1:index_io-1, 1), 10, 'filled');
    s.MarkerEdgeColor = 'none';
    s.MarkerFaceColor = palette.blue;
%     s.MarkerSize = 5;
    hold on;
    plot(tRec(index_io:end), dRec(index_io:end, 1), 'Color', palette.orange, 'LineWidth', 2);
    line([tRec(index_io-1), tRec(index_io-1)],get(gca,'YLim'),'Color',palette.magenta, 'LineWidth', 1);
    legend('$u_{opt}$', '$u_{io}$', 'Interpreter', 'latex');
end
    
xlabel('$t$'); ylabel('$u$');
title('Control inputs')
set_history_grid(tRec, 'dt', 0.2, 'index_io', index_io);    
if save_file
    save_figure('file_name', fig_name, 'figure_size', [16, 4]);
    save_figure('file_name', fig_name, 'file_format', 'png', 'figure_size', [16, 4]);    
end