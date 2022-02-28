function ttr_floor = eval_floor_ttr(grid, ttr, x)

% If the number of columns does not match the grid dimensions, try taking
% transpose
if size(x, 2) ~= grid.dim
    x = x';
end

adjacent_ttrs = inf * ones([2^grid.dim, 1]);
% lower_adjacent_ttrs = inf * ones([grid.dim, 1]);
% upper_adjacent_ttrs = inf * ones([grid.dim, 1]);

indices_lower = zeros([grid.dim, 1]);
indices_upper = zeros([grid.dim, 1]);

for i = 1:grid.dim
    [~, index_grid] = min(abs(grid.vs{i} - x(i)));
    if index_grid == 1 && x(i) < grid.vs{i}(1)
        error("x is out of grid min bound.");
    elseif index_grid == grid.N(i) && x(i) > grid.vs{i}(end)
        error("x is out of grid max bound.");
    end
    if grid.vs{i}(index_grid) < x(i) || index_grid == 1
        index_lower = index_grid;
        index_upper = index_grid + 1;
    else        
        index_lower = index_grid - 1;
        index_upper = index_grid;
    end
    indices_lower(i) = index_lower;
    indices_upper(i) = index_upper;
end

indices_neighbor = get_adjacent_indices_recursively(indices_lower, indices_upper);
for i = 1:size(indices_neighbor, 1)
    indices_i = num2cell(indices_neighbor(i, :));
    adjacent_ttrs(i) = ttr(indices_i{:});
end
weights_neighbor = get_weights(grid, indices_neighbor, x);

%weights_used = weights_neighbor(adjacent_ttrs ~= inf);
% adjacent_ttrs_used = adjacent_ttrs(adjacent_ttrs ~= inf);
if all(adjacent_ttrs == inf)
    ttr_floor = inf;
    return
end
adjacent_ttrs_used = adjacent_ttrs;
adjacent_ttrs_used(adjacent_ttrs == inf) = max(adjacent_ttrs(adjacent_ttrs ~= inf));
weights_used = weights_neighbor;
ttr_floor = weights_used' * adjacent_ttrs_used / sum(weights_used);
end

function indices = get_adjacent_indices_recursively(indices_lower, indices_upper)
length_current_dim  = length(indices_lower);
if length_current_dim == 1
    indices = [indices_lower; indices_upper];
    return
end
size_each = 2^(length_current_dim - 1);
indices = [indices_lower(1) * ones(size_each, 1), ...
    get_adjacent_indices_recursively(indices_lower(2:end), indices_upper(2:end));
    indices_upper(1) * ones(size_each, 1), ...
    get_adjacent_indices_recursively(indices_lower(2:end), indices_upper(2:end))];
end

function weights_neighbor = get_weights(grid, indices_neighbor, x)
    weights_neighbor = zeros(size(indices_neighbor, 1), 1);
    for i = 1:length(weights_neighbor)
        indices_i = indices_neighbor(i, :);
        weight_i = 1;
        for j = 1:4
             weight_i = weight_i * (grid.dx(j) - abs(x(j) - grid.vs{j}(indices_i(j))));             
        end
        weights_neighbor(i) = weight_i;
    end
end
