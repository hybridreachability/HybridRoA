%% These settings should match with the values you set up in cal_brt_original.m
% Main str id for loading data.
main_file_id_str = 'result_ral_main_';
% time interval for saving data
dt = 0.01;
% terminal time
t_max = 1.5;
% number of timesteps to split data files
N_save = 10;
%% Settings for using data files.
use_data = false;
use_sparse_ttr = true;
use_total_data = false;
% If false, use the total derivs as a single file, this can be very large 
% and inefficient if t_max and grid is large.
use_sparse_derivs = true; 
[derivs, ttr, target_function, data, tau, grid, gait_params, gait] = ...
    get_opt_ctrl_evaluation_setup(main_file_id_str, dt, t_max, N_save, ...
    use_data, use_sparse_ttr, use_sparse_derivs, use_total_data);

clearvars('-except', 'derivs', 'ttr', 'data', 'tau', 'grid', 'target_function', ...
    'gait_params', 'gait', 'main_file_id_str');