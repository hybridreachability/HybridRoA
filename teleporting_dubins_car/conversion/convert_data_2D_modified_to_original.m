function data_original = convert_data_2D_modified_to_original(...
    data_modified, grid_modified, grid_original, theta_slices, params)
x1 = grid_original.vs{1};
x2 = grid_original.vs{2};
x3 = theta_slices;

if length(x3) == 1
    N = grid_original.N(1:2)';
    data_original = zeros(N);
    for i = 1:N(1)
        disp(i)
        for j = 1:N(2)
            x_original = [x1(i), x2(j), x3];
            x_modified = convert_original_to_modified(x_original, params)';
            data_original(i, j) = eval_u(grid_modified, data_modified, x_modified);
        end
    end
else
    N = [grid_original.N(1:2)', length(x3)];
    data_original = zeros(N);
    for i = 1:N(1)
        fprintf("%d / %d\n", [i, N(1)]);
        disp(i)
        for j = 1:N(2)
            for k = 1:N(3)
                x_original = [x1(i), x2(j), x3(k)];
                x_modified = convert_original_to_modified(x_original, params)';
                data_original(i, j, k) = eval_u(grid_modified, data_modified, x_modified);
            end
        end
    end
end