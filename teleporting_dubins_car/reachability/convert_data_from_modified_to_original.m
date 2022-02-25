%% Warning: this script takes a lot of time.
clear all;
close all;
load('data_target_orbit_modified_t15');
tau_data = tau;

params.v = 1;
params.R = 2;
params.u_bound = 1;

load('data0_orbit_original', 'grid_original');
% R = params.R;
% x_max = 3 * R;
% grid_min = [-x_max; -x_max; -pi];
% grid_max = [x_max; x_max; pi];
% M = 100;
% N = [M+1, M+1, M+1];
% grid_original = createGrid(grid_min, grid_max, N, 3);

l = [21, 41, 61, 81, 101, 121];
tau = tau_data(l);
tau_length = length(tau);
data_original = zeros([grid_original.N', tau_length]);

for i = 1:tau_length
    fprintf("evaluating brt data at t = %.3f\n", tau(i));
    data_squeezed = squeeze(data(:, :, :, l(i)));    
    data_original(:, :, :, i) = convert_data_modified_to_original(...
    data_squeezed, grid, grid_original, params);
end
