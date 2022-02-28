function fig = plot_main_contact_history(tRec, fRec, varargin)

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

palette = get_palette_colors();
fig = open_figure('font_size', 14, 'margin', 'tight');
subplot(2, 1, 1)
if ~plot_opt_io
    plot(tRec, fRec(:, 1), 'Color', palette.magenta,  'LineWidth', 2)
    hold on
    plot(tRec, fRec(:, 2), 'Color', palette.blue, 'LineWidth', 2)
    legend('Horizontal', 'Vertical')
else
    plot(tRec(1:index_io-1), fRec(1:index_io-1, 1), ...
        'Color', palette.magenta, 'LineWidth', 2);
    hold on
    plot(tRec(index_io:end), fRec(index_io:end, 1), ':', ...
        'Color', palette.magenta, 'LineWidth', 2);
    plot(tRec(1:index_io-1), fRec(1:index_io-1, 2), ...
        'Color', palette.blue, 'LineWidth', 2);
    plot(tRec(index_io:end), fRec(index_io:end, 2), ':', ...
        'Color', palette.blue, 'LineWidth', 2);
    legend('Horizontal (Opt.)', 'Horizontal (IO Linear.)', ...
        'Vertical (Opt.)', 'Vertical (IO Linear.)');
end
set_history_grid(tRec, 'dt', 0.2, 'index_io', index_io);
title('Ground Reaction force')

subplot(2, 1, 2)
plot(tRec, fRec(:, 1) ./ fRec(:, 2), 'Color', palette.orange, 'LineWidth', 2);
ylabel('$F_{H}/F_{V}$');
xlabel('$t$ (s)')
set_history_grid(tRec, 'dt', 0.2, 'index_io', index_io);
grid on

if save_file
    save_figure('file_name', fig_name, 'figure_size', [16, 8]);
    save_figure('file_name', fig_name, 'file_format', 'png', 'figure_size', [16, 8]);    
end