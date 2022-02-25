clear all

theta_slice = -3 * pi/4;
M = 140;
N = [M+1, M+1, M+1];

load('data_with_freeze_reset_map_t_3');
%% Precalculation of slice of value function at initial state and the periodic orbit.
x_max = 5 * params.R;
grid_min = [-x_max; -x_max; -pi];
grid_max = [x_max; x_max; pi];
grid_original = createGrid(grid_min, grid_max, N, 3);    
grid2D_original = createGrid(grid_min(1:2), grid_max(1:2), [M+1, M+1]);
xs_orbit = get_hybrid_orbit(params);

data_original_2D_freeze = convert_data_2D_modified_to_original(...
    squeeze(data(:, :, :, end)), grid, grid_original, theta_slice, params);

load('data_with_iden_reset_map_t_3');
data_original_2D_iden = convert_data_2D_modified_to_original(...
    squeeze(data(:, :, :, end)), grid, grid_original, theta_slice, params);

load('data_with_sqrt_reset_map_t_3');
data_original_2D_sqrt = convert_data_2D_modified_to_original(...
    squeeze(data(:, :, :, end)), grid, grid_original, theta_slice, params);

load('data_with_diverge_reset_map_t_3');
data_original_2D_diverge = convert_data_2D_modified_to_original(...
    squeeze(data(:, :, :, end)), grid, grid_original, theta_slice, params);


magenta = [0.937, 0.004, 0.584];
orange = [0.965, 0.529, 0.255];
blue = [0.106, 0.588, 0.953];
green = 0.01 * [4.3, 69.4, 63.9];
yellow = [0.998, 0.875, 0.529];

figure;
extraArgs.LineWidth = 1;
h = visSetIm(grid2D_original, data_original_2D_freeze, blue, 0, extraArgs); hold on;
h.DisplayName = "Freeze";
h = visSetIm(grid2D_original, data_original_2D_iden, magenta, 0, extraArgs); hold on;
h.DisplayName = "Identity";
h = visSetIm(grid2D_original, data_original_2D_sqrt, green, 0, extraArgs); hold on;
h.DisplayName = "Contract";
h = visSetIm(grid2D_original, data_original_2D_diverge, orange, 0, extraArgs); hold on;
h.DisplayName = "Diverge";

plot(xs_orbit(1, :), xs_orbit(2, :), 'b-.', 'DisplayName', 'orbit');
hold off;
legend
ylim([-1, 3*params.R]);
xlabel('x','interpreter','latex');
ylabel('y','interpreter','latex');
set(gca,'FontSize',15);

figure;
extraArgs.LineWidth = 1.5;
h = visSetIm(grid2D_original, data_original_2D_freeze, blue, 0, extraArgs); hold on;
h.DisplayName = "Freeze";
plot(xs_orbit(1, :), xs_orbit(2, :), 'b-.', 'DisplayName', 'orbit');
hold off;
legend
ylim([-1, 3*params.R]);
xlabel('x','interpreter','latex');
ylabel('y','interpreter','latex');
set(gca,'FontSize',15);

figure;
extraArgs.LineWidth = 1;
h = visSetIm(grid2D_original, data_original_2D_iden, magenta, 0, extraArgs); hold on;
h.DisplayName = "Identity";
plot(xs_orbit(1, :), xs_orbit(2, :), 'b-.', 'DisplayName', 'orbit');
hold off;
legend
ylim([-1, 3*params.R]);
xlabel('x','interpreter','latex');
ylabel('y','interpreter','latex');
set(gca,'FontSize',15);

figure;
extraArgs.LineWidth = 1;
h = visSetIm(grid2D_original, data_original_2D_sqrt, green, 0, extraArgs); hold on;
h.DisplayName = "Contract";
plot(xs_orbit(1, :), xs_orbit(2, :), 'b-.', 'DisplayName', 'orbit');
hold off;
legend
ylim([-1, 3*params.R]);
xlabel('x','interpreter','latex');
ylabel('y','interpreter','latex');
set(gca,'FontSize',15);

figure;
extraArgs.LineWidth = 1;
h = visSetIm(grid2D_original, data_original_2D_diverge, orange, 0, extraArgs); hold on;
h.DisplayName = "Diverge";
plot(xs_orbit(1, :), xs_orbit(2, :), 'b-.', 'DisplayName', 'orbit');
hold off;
legend
ylim([-1, 3*params.R]);
xlabel('x','interpreter','latex');
ylabel('y','interpreter','latex');
set(gca,'FontSize',15);

