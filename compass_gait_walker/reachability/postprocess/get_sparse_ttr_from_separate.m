function ttr = get_sparse_ttr_from_separate(main_file_id_str, dt, N_save, t_max)
dt_save = N_save * dt;
N_max = ceil(t_max / dt_save);

file_indices = 1000 * (dt_save:dt_save:N_max*dt_save);

% initialize ttr.
filename_temp = strcat(main_file_id_str,num2str(file_indices(1)));
load(filename_temp, 'data');
data_size_temp = size(data);
data_size_per_timestep = data_size_temp(1:4);
ttr = inf * ones(data_size_per_timestep);

for i = 1:length(file_indices)    
    filename = strcat(main_file_id_str,num2str(file_indices(i)));
    load(filename, 'tau', 'data');  
    for j = 1:length(tau)
        t_j = tau(j);
        data_j = squeeze(data(:, :, :, :, j));
        ttr(data_j <= 0) = min(ttr(data_j <= 0), t_j);
    end
    fprintf("Converted %d-th data of total %d files to ttr.\n", ...
        [i, length(file_indices)]); 
end