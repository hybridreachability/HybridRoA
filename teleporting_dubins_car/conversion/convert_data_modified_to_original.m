function data_original = convert_data_modified_to_original(...
    data_modified, grid_modified, grid_original, params)
%% Only works for 3 dimensional data.
x1 = grid_original.vs{1};
x2 = grid_original.vs{2};
x3 = grid_original.vs{3};
N = grid_original.N';

data_original = zeros(N);
for i = 1:N(1)
    disp(i)
    for j = 1:N(2)
        for k = 1:N(3)
            x_original = [x1(i), x2(j), x3(k)];
            x_modified = convert_original_to_modified(x_original, params)';
            data_original(i, j, k) = eval_u(grid_modified, data_modified, x_modified);
        end
    end
end