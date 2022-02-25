function reset_map = get_reset_map(grid, params, reset_map_type)
    if strcmp(reset_map_type, 'identity')
        reset_map = get_reset_map_identity(grid, params);
    elseif strcmp(reset_map_type, 'sqrt')
        reset_map = get_reset_map_sqrt(grid, params);
    elseif strcmp(reset_map_type, 'diverge')
        reset_map = get_reset_map_diverge(grid, params);
    elseif strcmp(reset_map_type, 'parametrized')
        reset_map = get_reset_map_parametrized(grid, params);
    else
        error("reset_map_type not supported.")
    end
end

function reset_map = get_reset_map_identity(grid, params)
    eps = 1e-5;
    N = grid.N;
    M = N(3) / 2;
    ind = 1:prod(N);
    [I1, I2, I3] = ind2sub(N, ind);
    
    idx_alpha_0  = find(grid.vs{2}==0);
    idx_alpha_pi = find(abs(grid.vs{2}-pi)<eps);

    idx_theta = find(sin(grid.vs{3}) < -eps);
    
    I1_reset = I1;
    I2_reset = I2;
    I3_reset = I3;
    %% Scanning all the grid points and if it's the reset map condition, apply it.
    for j = ind
        i1 = I1(j);
        i2 = I2(j);
        i3 = I3(j);
        if (i2 == idx_alpha_0 || i2 == idx_alpha_pi) && any(idx_theta == i3)
            % alpha to (alpha + pi)
            if i2 == idx_alpha_0
                i2_post = idx_alpha_pi;
            elseif i2 == idx_alpha_pi
                i2_post = idx_alpha_0;
            end
            % theta to (theta + pi)
            if i3 <= M
                i3_post = i3 + M;
            else
                i3_post = i3 - M;
            end
            I1_reset(j) = i1;
            I2_reset(j) = i2_post;
            I3_reset(j) = i3_post;
        end        
    end
    reset_map = sub2ind(N, I1_reset, I2_reset, I3_reset);
end

function reset_map = get_reset_map_sqrt(grid, params)
    eps = 1e-5;
    R = params.R;
    N = grid.N;
    M = N(3) / 2;
    ind = 1:prod(N);
    [I1, I2, I3] = ind2sub(N, ind);
    
    idx_alpha_0  = find(grid.vs{2}==0);
    idx_alpha_pi = find(abs(grid.vs{2}-pi)<eps);

    idx_theta = find(sin(grid.vs{3}) < -eps);
    
    I1_reset = I1;
    I2_reset = I2;
    I3_reset = I3;
    %% Scanning all the grid points and if it's the reset map condition, apply it.
    for j = ind
        i1 = I1(j);
        i2 = I2(j);
        i3 = I3(j);
        if (i2 == idx_alpha_0 || i2 == idx_alpha_pi) && any(idx_theta == i3)
            % alpha to (alpha + pi)
            if i2 == idx_alpha_0
                i2_post = idx_alpha_pi;
            elseif i2 == idx_alpha_pi
                i2_post = idx_alpha_0;
            end
            % theta to (theta + pi)
            if i3 <= M
                i3_post = i3 + M;
            else
                i3_post = i3 - M;
            end
            % r_bar to (sqrt(R*(r_bar+R)) - R)
            r_bar_current = grid.vs{1}(i1);
            r_bar_post = sqrt(R * (r_bar_current + R)) - R;
            [~, i1_post] = min(abs(grid.vs{1} - r_bar_post));

            I1_reset(j) = i1_post;
            I2_reset(j) = i2_post;
            I3_reset(j) = i3_post;
%             disp("debug");
        end        
    end
    reset_map = sub2ind(N, I1_reset, I2_reset, I3_reset);
end

function reset_map = get_reset_map_diverge(grid, params)
    eps = 1e-5;
    R = params.R;
    N = grid.N;
    M = N(3) / 2;
    ind = 1:prod(N);
    [I1, I2, I3] = ind2sub(N, ind);
    
    idx_alpha_0  = find(grid.vs{2}==0);
    idx_alpha_pi = find(abs(grid.vs{2}-pi)<eps);

    idx_theta = find(sin(grid.vs{3}) < -eps);
    
    I1_reset = I1;
    I2_reset = I2;
    I3_reset = I3;
    %% Scanning all the grid points and if it's the reset map condition, apply it.
    for j = ind
        i1 = I1(j);
        i2 = I2(j);
        i3 = I3(j);
        if (i2 == idx_alpha_0 || i2 == idx_alpha_pi) && any(idx_theta == i3)
            % alpha to (alpha + pi)
            if i2 == idx_alpha_0
                i2_post = idx_alpha_pi;
            elseif i2 == idx_alpha_pi
                i2_post = idx_alpha_0;
            end
            % theta to (theta + pi)
            if i3 <= M
                i3_post = i3 + M;
            else
                i3_post = i3 - M;
            end
            r_bar_current = grid.vs{1}(i1);
            r_bar_post = (r_bar_current + R)^1.5/sqrt(R) - R;
            [~, i1_post] = min(abs(grid.vs{1} - r_bar_post));

            I1_reset(j) = i1_post;
            I2_reset(j) = i2_post;
            I3_reset(j) = i3_post;
%             disp("debug");
        end        
    end
    reset_map = sub2ind(N, I1_reset, I2_reset, I3_reset);
end

function reset_map = get_reset_map_parametrized(grid, params)
    if ~isfield(params, 'reset_map_nonlinear_factor')
        error("reset_map_nonlinear_factor is not given.")
    end
    eps = 1e-5;
    R = params.R;
    N = grid.N;
    M = N(3) / 2;
    ind = 1:prod(N);
    [I1, I2, I3] = ind2sub(N, ind);
    
    idx_alpha_0  = find(grid.vs{2}==0);
    idx_alpha_pi = find(abs(grid.vs{2}-pi)<eps);

    idx_theta = find(sin(grid.vs{3}) < -eps);
    
    I1_reset = I1;
    I2_reset = I2;
    I3_reset = I3;
    %% Scanning all the grid points and if it's the reset map condition, apply it.
    for j = ind
        i1 = I1(j);
        i2 = I2(j);
        i3 = I3(j);
        if (i2 == idx_alpha_0 || i2 == idx_alpha_pi) && any(idx_theta == i3)
            % alpha to (alpha + pi)
            if i2 == idx_alpha_0
                i2_post = idx_alpha_pi;
            elseif i2 == idx_alpha_pi
                i2_post = idx_alpha_0;
            end
            % theta to (theta + pi)
            if i3 <= M
                i3_post = i3 + M;
            else
                i3_post = i3 - M;
            end
            r_bar_current = grid.vs{1}(i1);
            alpha = params.reset_map_nonlinear_factor;
            r_bar_post = R * ((r_bar_current + R)/R)^alpha - R;
            [~, i1_post] = min(abs(grid.vs{1} - r_bar_post));

            I1_reset(j) = i1_post;
            I2_reset(j) = i2_post;
            I3_reset(j) = i3_post;
        end        
    end
    reset_map = sub2ind(N, I1_reset, I2_reset, I3_reset);
end