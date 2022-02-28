function vis_grid_original(grid, gait)

if nargin < 2
    gait = [];       
end
%% Convert cell to array in appropriate size.
x_temp = reshape(grid.xs, [ones(1, 4), 4]);
x_temp = cell2mat(x_temp);
x_temp = permute(x_temp, [5, 1:4]);
xs_array = reshape(x_temp, 4, [])';
palette = get_palette_colors();
colors = [palette.orange; palette.yellow; palette.blue;];
color_array = get_color_map(colors, prod(grid.N)-1);
scatter_size = 20;

figure;
subplot(2, 2, 1);
s_q_data = scatter(xs_array(:, 1), xs_array(:, 2), ...
    scatter_size, color_array, 'filled');
hold on;
if ~isempty(gait)
    p_q_gait = plot(gait(:, 1), gait(:, 2), 'k-.');
    p_q_gait.LineWidth = 1.5;
end
xlabel('$q_1$', 'Interpreter', 'latex');
ylabel('$q_2$', 'Interpreter', 'latex');

subplot(2, 2, 2);
s_dq_data = scatter(xs_array(:, 3), xs_array(:, 4), ...
    scatter_size, color_array, 'filled');
hold on;
if ~isempty(gait)
    p_dq_gait = plot(gait(:, 3), gait(:, 4), 'k-.');
    p_dq_gait.LineWidth = 1.5;
end
xlabel('$\dot{q}_1$', 'Interpreter', 'latex');
ylabel('$\dot{q}_2$', 'Interpreter', 'latex');

subplot(2, 2, 3);
s_ydy_data = scatter(xs_array(:, 1), xs_array(:, 3), ...
    scatter_size, color_array, 'filled');
hold on;
if ~isempty(gait)
    p_ydy_gait = plot(gait(:, 1), gait(:, 3), 'k-.');
    p_ydy_gait.LineWidth = 1.5;
end
xlabel('$q_1$', 'Interpreter', 'latex');
ylabel('$\dot{q}_1$', 'Interpreter', 'latex');

subplot(2, 2, 4);
s_qdq_data = scatter(xs_array(:, 2), xs_array(:, 4), ...
    scatter_size, color_array, 'filled');
hold on;
if ~isempty(gait)
    p_qdq_gait = plot(gait(:, 2), gait(:, 4), 'k-.');
    p_qdq_gait.LineWidth = 1.5;
end
xlabel('$q_2$', 'Interpreter', 'latex');
ylabel('$\dot{q}_2$', 'Interpreter', 'latex');