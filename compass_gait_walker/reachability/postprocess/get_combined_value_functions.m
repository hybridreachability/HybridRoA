function [tau_total, data_total] = get_combined_value_functions( ...
    main_file_id_str, dt, N_save, t_max)

dt_save = N_save * dt;
N_max = ceil(t_max / dt_save);

file_indices = 1000 * (dt_save:dt_save:N_max*dt_save);

filename_temp = strcat(main_file_id_str,num2str(file_indices(1)));
load(filename_temp, 'data');
data_size_temp = size(data);
data_size_per_timestep = data_size_temp(1:4);

% load data and visualize
length_data = ceil(file_indices(end)/(dt * 1000));
data_total = zeros([data_size_per_timestep, length_data]);
tau_total = [];
k = 1;
for i = 1:length(file_indices)    
    filename = strcat(main_file_id_str,num2str(file_indices(i)));
    load(filename, 'tau', 'data');    
    for j = 1:length(tau)
        t = tau(j);
        tau_total = [tau_total; t];
        data_total(:, :, :, :, k) = data(:, :, :, :, j);
        k = k + 1;
    end
    fprintf("Merged %d-th file of total %d files.\n", ...
        [i, length(file_indices)]); 
end