function derivs = get_sparse_derivs_from_separate(main_file_id_str, dt, N_save, t_max, grid, ttr_sparse)
dt_save = N_save * dt;
N_max = ceil(t_max / dt_save);

file_indices = 1000 * (dt_save:dt_save:N_max*dt_save);

%% initialize derivs
filename_temp = strcat(main_file_id_str,num2str(file_indices(1)));
load(filename_temp, 'data');
data_size_temp = size(data);
data_size_per_timestep = data_size_temp(1:4);
derivs = cell(4, 1);
for j = 1:4
    derivs{j} = zeros(data_size_per_timestep);
end

for i = 1:length(file_indices)    
    filename = strcat(main_file_id_str,num2str(file_indices(i)));
    load(filename, 'tau', 'data');  
    for j = 1:length(tau)
        t_j = tau(j);
        fprintf("Processing t=%.2f of total %d timesteps (t_max=%.2f).\n", ...
            [t_j, N_max, t_max]);
        data_j = squeeze(data(:, :, :, :, j));
        derivs_j = computeGradients(grid, data_j);
        if t_j < t_max
            derivs_j_mask = (ttr_sparse == t_j);
        else
            derivs_j_mask = (ttr_sparse >= t_max);
        end
        for k = 1:4
            derivs{k}(derivs_j_mask) = derivs_j{k}(derivs_j_mask);
        end
    end
end
end