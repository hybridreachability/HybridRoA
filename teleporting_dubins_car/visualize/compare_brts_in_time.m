clear all

% load('data_with_iden_reset_map_t_3');
load('data_with_diverge_reset_map_t_3');

%% Precalculation of slice of value function at initial state and the periodic orbit.
theta_slice = -pi/4;
x_max = 5 * params.R;
grid_min = [-x_max; -x_max; -pi];
grid_max = [x_max; x_max; pi];
M = 140;
N = [M+1, M+1, M+1];
grid_original = createGrid(grid_min, grid_max, N, 3);    
grid2D_original = createGrid(grid_min(1:2), grid_max(1:2), [M+1, M+1]);
xs_orbit = get_hybrid_orbit(params);

figure;
ts_idx = length(tau)-2:length(tau);

magenta = [0.937, 0.004, 0.584];
orange = [0.965, 0.529, 0.255];

extraArgs.LineWidth = 1.5;
for i = 1:length(ts_idx)
    data_original_2D = convert_data_2D_modified_to_original(...
    squeeze(data(:, :, :, ts_idx(i))), grid, grid_original, theta_slice, params);
    color = (i * magenta + (length(ts_idx)-i) * orange) / length(ts_idx);
    h  = visSetIm(grid2D_original, data_original_2D, color, 0, extraArgs);
    hold on;
    t = tau(ts_idx(i));
    str_t = strcat(strcat('t=-', num2str(t)), 'sec');
    h.DisplayName = str_t;
    
end
hold off;
legend
ylim([-1, 3*params.R]);
xlabel('x','interpreter','latex');
ylabel('y','interpreter','latex');
set(gca,'FontSize',15);