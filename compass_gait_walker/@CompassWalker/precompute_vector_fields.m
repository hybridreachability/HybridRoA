function precompute_vector_fields(obj)
    % Convert cell to array
    cell_size = size(obj.grid.xs{1});
    cell_dim = length(cell_size);
    x = reshape(obj.grid.xs, [ones(1, cell_dim), obj.nx]);
    x = cell2mat(x);
    x = permute(x, [cell_dim+1, 1:cell_dim]);
    x = reshape(x, obj.nx, []);
    fs_array = obj.get_fvec(x);
    obj.fs_grid = cell(obj.nx, 1);
    for i = 1:obj.nx
        obj.fs_grid{i} = reshape(fs_array(i, :), cell_size);        
    end
    gs_array = obj.get_gvec(x);
    obj.gs_grid = cell(obj.nx, 1);
    for i = 1:obj.nx
        obj.gs_grid{i} = reshape(gs_array(i, :, :), cell_size);
    end
    obj.pSw_y_grid = obj.lL * (cos(obj.grid.xs{1}) ...
        - cos(obj.grid.xs{1} + obj.grid.xs{2}));
    
    u_io = zeros(prod(cell_size), 1);
    if obj.run_closed_loop
        for i=1:size(x, 2)
            x_full = zeros(8, 1);
            x_full([3, 4, 7, 8]) = x(:, i);
            u_io(i) = two_link_io_control(x_full, obj.control_params);
            if rem(i, 2000000) == 0
                fprintf("computing u_io, progress: %.2f %%\n", 100*i/size(x, 2));
            end
        end
        u_io(u_io > obj.uMax) = obj.uMax;
        u_io(u_io < obj.uMin) = obj.uMin;
        obj.us_closed_loop_grid = reshape(u_io, cell_size);
        obj.closed_loop_dynamics_grid = cell(obj.nx, 1);
        for i = 1:obj.nx
            obj.closed_loop_dynamics_grid{i} = ...
                obj.fs_grid{i} + obj.gs_grid{i} .* obj.us_closed_loop_grid;
        end
    end
end