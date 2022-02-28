function fig = plot_main_output(tRec, xRec, varargin)
% xRec: full coordinate
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

if size(xRec, 1) ~= 8
    xRec = xRec';
end

beta1 = gait_params(1,:);
beta2 = gait_params(2,:);
beta3 = gait_params(3,:);
beta4 = gait_params(4,:);
th1d = gait_params(5,:);
q1 = xRec(3,:);
q2 = xRec(4,:);
q2_desired = (q1+th1d).*(q1-th1d).*(beta1+beta2.*q1+beta3.*q1.^2+beta4.*q1.^3) - q1.*2.0;
output = q1.*2.0+q2-(q1+th1d).*(q1-th1d).*(beta1+beta2.*q1+beta3.*q1.^2+beta4.*q1.^3);

palette = get_palette_colors();
fig = open_figure('font_size', 14, 'margin', 'tight');
subplot(2, 1, 1)
if ~plot_opt_io
    plot(tRec, output, 'Color', palette.orange, 'LineWidth', 1.5);
else
    plot(tRec(1:index_io-1), output(1:index_io-1), ...
        'Color', palette.blue, 'LineWidth', 2);
    hold on;
    plot(tRec(index_io:end), output(index_io:end), ...
        'Color', palette.orange, 'LineWidth', 2);
    line([tRec(index_io-1), tRec(index_io-1)],get(gca,'YLim'),'Color',palette.grey);
end
ylabel('Output ( $q_2 - q_{2,d}$ )')
set_history_grid(tRec, 'dt', 0.2, 'index_io', index_io);

subplot(2, 1, 2)
if ~plot_opt_io
    plot(tRec, q2, 'Color', palette.orange, 'LineWidth', 2); hold on;
    plot(tRec, q2_desired, 'k--', 'LineWidth', 1.5); 
    legend('$q_2$ (actual)', '$q_2$ (desired)', 'Interpreter', 'latex');
else
    plot(tRec(1:index_io-1), q2(1:index_io-1), ...
        'Color', palette.blue, 'LineWidth', 2);
    hold on;
    plot(tRec(index_io:end), q2(index_io:end), ...
        'Color', palette.orange, 'LineWidth', 2);
    plot(tRec, q2_desired, 'k--', 'LineWidth', 1.5); 
    legend('$q_2$ (actual) (Opt.)', '$q_2$ (actual) (IO-FL.)', '$q_2$ (desired)', 'Interpreter', 'latex');
    line([tRec(index_io-1), tRec(index_io-1)],get(gca,'YLim'),'Color',palette.magenta, 'LineWidth', 1);
end
ylabel('$q_2$')
xlabel('$t$')
set_history_grid(tRec, 'dt', 0.2, 'index_io', index_io);

if save_file
    save_figure('file_name', fig_name);
    save_figure('file_name', fig_name, 'file_format', 'png');    
end