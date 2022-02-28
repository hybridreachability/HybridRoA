function target_function = get_target_function_from_gait( ...
    grid, gait, distance_threshold, plot_target)
if nargin < 3
    distance_threshold = 0.0;
end

if nargin < 4
    plot_target = false;
end

size_grid = prod(grid.N);
%% Convert cell to array in appropriate size.
x_temp = reshape(grid.xs, [ones(1, 4), 4]);
x_temp = cell2mat(x_temp);
x_temp = permute(x_temp, [5, 1:4]);
xs_array = reshape(x_temp, 4, [])';

% initialize target function
ls_array = zeros(1, size_grid);
distance_scale = grid.dx(4) ./ grid.dx;
for i = 1:size_grid
    x = xs_array(i, :)';
    distances_to_gait = vecnorm(distance_scale .* (gait' - x));
    distance_to_gait = min(distances_to_gait);
    l_x = distance_to_gait - distance_threshold;
    ls_array(i) = l_x;    
end
target_function = reshape(ls_array, grid.N');

