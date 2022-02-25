clear; clc; close all;

%% Grid
grid_min = [-0.2; -0.6]; % Lower corner of computation domain
grid_max = [0.6; 1.3];    % Upper corner of computation domain
N = [201; 201];         % Number of grid points per dimension
g = createGrid(grid_min, grid_max, N);

%% target set
eps = 0.01;
% data0_invariant_orbit = abs(cos(g.xs{1}) + 0.5 * g.xs{2}.^2 - 1.1) - eps;
data0_invariant_orbit = abs(cos(g.xs{1}) + 0.5 * g.xs{2}.^2 - 1.132) - eps;
data0_invariant_orbit = (data0_invariant_orbit <= 0);
data0_positive_direction = g.xs{2} > 0;
data0 = data0_invariant_orbit .* data0_positive_direction;
data0 = 1 - 2*data0;

%% problem parameters
alpha = 0.4;
gamma = 0.2;

%% create the reset map 
% whenever theta = 0.6, we reset to theta= -0.2 
% theta -> 2*gamma - theta
% theta_dot -> cos(2*alpha).theta_dot

% theta_right = 0.6;
% theta_left = -0.2;

theta_right = 0.59;
theta_left = -0.195;

ind = 1:prod(N);
[I1, I2] = ind2sub(N, ind);

[~, theta_prereset_index] = min(abs(g.vs{1} - theta_right));
[~, theta_postreset_index] = min(abs(g.vs{1} - theta_left));
switching_surface = find(I1==theta_prereset_index);
I1(switching_surface) = theta_postreset_index;

for i=1:length(switching_surface)
  % Post reset value
  post_reset_value = cos(2*alpha) * g.xs{2}(switching_surface(i));
  % Find the closest index to the post reset value
  [~, thetadot_postreset_index] = min(abs(g.vs{2} - post_reset_value));
  I2(switching_surface(i)) = thetadot_postreset_index;
end

reset_map = sub2ind(N, I1, I2);
 

%% time vector
t0 = 0;
tMax = 30;
dt = 1.0;
tau = t0:dt:tMax;

%% Pack problem parameters
schemeData.grid = g; % Grid MUST be specified!

% Dynamical system parameters
schemeData.grid = g;
schemeData.accuracy = 'veryHigh';
schemeData.hamFunc = @rimless_wheel_ham;
schemeData.partialFunc = @rimless_wheel_partial;
schemeData.tMode = 'backward';
schemeData.reset_map = reset_map;

%% Start reachability computation for the signed distance terminal value function
extraArgs.visualize = true;

[data, tau, ~] = HJIPDE_solve_with_reset_map(data0, tau, schemeData, 'zero', extraArgs);