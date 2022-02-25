clear; close all;

load('data_rimless_wheel_t_30.mat')

%% Colors for plotting
alpha = 0.3;
color_full = (1-alpha)*[213 85 178]/255 + alpha*[1 1 1];
color_line = [81 232 57]/255;

%% Linewidths
linewidth = 2.0;
fontsize = 15;

f = figure;
f.Color = 'white';

hold on;

% Set the box linmewidth
hAx = gca;
hAx.LineWidth=1.4;

% Plot the zero level set
[c, h] = contourf(g.xs{1}, g.xs{2}, -squeeze(data(:, :, end)), [-0.1 10000], 'linewidth', linewidth, 'linecolor', color_line);
colormap(color_full);

% Plot the hybrid limit cycle
xs = g.vs{1};
ys = sqrt(2*(1.132 - cos(xs)));
plot(xs, ys, 'linewidth', linewidth+3, 'color', 'k');

% Set the figure axes size
xlim([-0.195, 0.58]);
ylim([-0.58, 1.28]);

% Set the axes ticks and lines
set(gca,'xtick',[-0.1, 0, 0.1, 0.2, 0.3, 0.4, 0.5], 'fontsize', fontsize)
set(gca,'ytick',[-0.4, -0.2, 0, 0.2, 0.4, 0.6, 0.8, 1, 1.2], 'fontsize', fontsize)

% Set the labels
ylabel('d$\theta$/dt (radians/s)', 'Interpreter','latex', 'fontsize', fontsize+5, 'fontweight','bold');
xlabel('$\theta$ (radians)', 'Interpreter','latex', 'fontsize', fontsize+5, 'fontweight','bold');

% Set square axes
box on; 
hold off;

% Save the marked version
set(gcf,'InvertHardcopy','off');
