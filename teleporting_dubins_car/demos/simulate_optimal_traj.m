clear all
close all

alpha = 0.5;
% alpha = 1.0;

data_file_str = strcat('data_with_reset_map_alpha_', num2str(100*alpha));
data_file_str = strcat(data_file_str, '_t_6_3');
load(data_file_str);
params.alpha = alpha;
%% Initial state.
% Init states with t=6.3
% x0_original = [3., 2., -pi/4];
% x0_original = [-6., 1.5, -pi/4];
x0_original = [14., 2., -3*pi/4];
% x0_original = [-3., 6., -3*pi/4];
% x0_original = [7.5, 3.0, -3*pi/4];

% x0_original = [0., 2.0, -pi/2];

% x0_original = [-3.8, 1.9, -pi/4]; % for iden reset map
% x0_original = [-1.8, 0.01, -pi/4]; % for iden reset map
% x0_original = [0.72, 3.95, -pi/4]; % for iden reset map
% x0_original = [-2.04, 1.32, -pi/4]; % for iden reset map

% x0_original = [0.72, 3.96, -pi/4]; % for sqrt reset map
% x0_original = [-9.14, 0.28, -pi/4]; % for sqrt reset map - sqrt1
% x0_original = [-6.28, 0.14, -pi/4]; % for sqrt reset map -sqrt 2
% x0_original = [-9.27, 0.57, -pi/4]; % for sqrt reset map - sqrt3
% x0_original = [-4.42, 1.28, -pi/4]; % for sqrt reset map -sqrt4
% x0_original = [-1.65, 0.01, -pi/4]; % for sqrt reset map -sqrt5
% x0_original = [-2.14, 2.5, -pi/4]; % for sqrt reset map -sqrt6
% x0_original = [-2, 1, -pi/4]; % for sqrt reset map -sqrt7
% x0_original = [-0.85, 4, -pi/4]; % for sqrt reset map -sqrt8
% x0_original = [9.57, 0.01, -3*pi/4]; % for sqrt reset map
% x0_original = [-1.43, 0.14, -3*pi/4]; % for sqrt reset map
% x0_original = [-3.41, 1.16, -3*pi/4]; % for sqrt reset map
% x0_original = [-2.42, 0.1, -3*pi/4]; % for sqrt reset map


% x0_original = [0.72, 3.95, -pi/4]; % for diverge reset map
% x0_original = [-2.63, 2.29, -pi/4]; % for diverge reset map
% x0_original = [-3.12, 1.98, -pi/4]; % for diverge reset map
% x0_original = [-3.47, 2.4, -pi/4]; % for diverge reset map
% x0_original = [-3.82, 0.96, -pi/4]; % for diverge reset map
% x0_original = 0.5 * ([-3.47, 2.4, -pi/4] + [-3.82, 0.96, -pi/4]); % for diverge reset map
% x0_original = [-3.8, 0.15, -pi/4]; % for diverge reset map
% x0_original = [-3.24, 0.05, -pi/4]; % for diverge reset map
% x0_original = [-1.92, 1.8, -pi/4]; % for diverge reset map
% x0_original = [-1.8, 1, -pi/4]; % for diverge map
% x0_original = [3.57, 0.58, -3*pi/4]; % for diverge map
% x0_original = [3.57, 0.26, -3*pi/4]; % for diverge map
% x0_original = [-1.7, 2.52, -3*pi/4]; % for diverge map
% x0_original = [-2.15, 2.25, -3*pi/4]; % for diverge map

%% For all cases
% x0_original = 0.5 * ([-3.47, 2.4, -pi/4] + [-3.82, 0.96, -pi/4]); % for diverge reset map
% x0_original = [-2.56, 1.85, -3*pi/4]; % for diverge reset map


%% Precalculation of slice of value function at initial state and the periodic orbit.
theta_slice = x0_original(3);
x_max = 5 * params.R;
grid_min = [-x_max; -x_max; -pi];
grid_max = [x_max; x_max; pi];
M = 140;
N = [M+1, M+1, M+1];
grid_original = createGrid(grid_min, grid_max, N, 3);    

theta_slices = -pi:pi/12:11*pi/12;
[~, theta_index] = min(abs(theta_slices-x0_original(3)));
data_2D_file_str = strcat('data_with_reset_map_alpha_', num2str(100*alpha));
data_2D_file_str = strcat(data_2D_file_str, '_t_6_3');
data_2D_file_str = strcat(data_2D_file_str, '_2D');
load(data_2D_file_str);

xs_orbit = get_hybrid_orbit(params);


reset_map_type = "parametrized"; % options: "identity", "sqrt".

%%%%%%%
x0_modified = convert_original_to_modified(x0_original, params)';
dCar = ModifiedDubinsCar([], x0_modified, params, reset_map_type);

value = eval_u(grid,data(:,:,:,end),x0_modified);
disp("value at initial state");
disp(value);

%% Simulate Optimal controller
dataTraj = flip(data,4);
% tau = 0:0.05: 2 * pi * params.R / params.v;
TrajextraArgs.uMode = 'min';
TrajextraArgs.tMax = 6.3;
TrajextraArgs.ctrlMode = 'opt';
[traj, ts] = ...
      computeHybridOptTraj(grid, dataTraj, tau, dCar, TrajextraArgs);
xs_original = convert_modified_to_original(traj', params)';
xs_length = size(xs_original, 2);

%% Simulate baseline-controller
TrajextraArgs.ctrlMode = 'pid';
t_max = 14;
dCar = ModifiedDubinsCar([], x0_modified, params, reset_map_type);
[traj_compare, ts_compare] = ...
      computeHybridOptTraj(grid, dataTraj, 0:0.1:t_max, dCar, TrajextraArgs);
xs_original_fl = convert_modified_to_original(traj_compare', params)';
xs_fl_length = size(xs_original_fl, 2);

open_figure('size', [1200, 500]);
magenta = [0.937, 0.004, 0.584];
blue = [0.106, 0.588, 0.953];
green = 0.01 * [4.3, 69.4, 63.9];
grey = 0.01 *[19.6, 18.8, 19.2];
palette = get_palette_colors();
navy2 = 0.5 * palette.navy + 0.5 * palette.blue;
blue2 = 0.5 * palette.blue + 0.5 * palette.white;
visSetIm(grid2D_original, squeeze(data_2D(:, :, theta_index)), blue); hold on;
time_color_map = [linspace(green(1), magenta(1), xs_length)', ...
    linspace(green(2), magenta(2), xs_length)', ...
    linspace(green(3), magenta(3), xs_length)'];
time_color_map = [linspace(navy2(1), blue2(1), xs_length)', ...
    linspace(navy2(2), blue2(2), xs_length)', ...
    linspace(navy2(3), blue2(3), xs_length)'];
time_fl_map = get_color_map([0.3, 0.3, 0.3; [0.8, 0.8 0.8]], xs_fl_length-1);
s = scatter(xs_original_fl(1, :), xs_original_fl(2, :), 20, time_fl_map, 'filled'); hold on;
s = scatter(xs_original(1, :), xs_original(2, :), 30, time_color_map, 'filled'); hold on;
plot(xs_orbit(1, :), xs_orbit(2, :), 'b-.', 'LineWidth', 2);
plot_range_unit = 7.5 * params.R;
axis equal;
xlim([-plot_range_unit, plot_range_unit]);
ylim([-1, plot_range_unit]);
% xlim([-7.5, 15]);
% ylim([-1.5, 6.0]);

xlabel('$p_x$','interpreter','latex');
ylabel('$p_y$','interpreter','latex');
set(gca,'FontSize',15);

% create_hybrid_dubins_car_video(ts, xs_original, params)

