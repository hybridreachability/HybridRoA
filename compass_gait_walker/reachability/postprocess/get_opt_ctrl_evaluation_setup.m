function [derivs, ttr, target_function, data, tau, grid, gait_params, gait] = ...
    get_opt_ctrl_evaluation_setup(main_file_id_str, dt, t_max, N_save, ...
    use_data, use_sparse_ttr, use_sparse_derivs, use_total_data)
%% [derivs, ttr, target_function, data, tau, grid, gait_params, gait] = ...
%%    get_opt_ctrl_evaluation_setup(main_file_id_str, dt, t_max, N_save, ...
%%    use_data, use_sparse_ttr, use_sparse_derivs, use_total_data)
%% If use_total_data = false (default), returned data is []. 

%% Settings for using data files.
if nargin < 5
    use_data = false;
end

if nargin < 6
    use_sparse_ttr = true;
end
% If false, use the total derivs as a single file, this can be very large 
% and inefficient if t_max and grid is large.
if nargin < 7
    use_sparse_derivs = true; 
end

if nargin < 8
    use_total_data = false;
end

% Load grid, gait_params, and target_function.
grid_file_str = strcat(main_file_id_str, 'grid');
load(grid_file_str, 'grid');

gait_file_str = strcat(main_file_id_str, 'gait');
load(gait_file_str, 'gait', 'gait_params');

target_function_file_str = strcat(main_file_id_str, 'target');
load(target_function_file_str, 'target_function');
disp("target_function is set up.");

% Set up compbined value functions.
data = [];
if use_total_data
    data_total_file_str = strcat(main_file_id_str, num2str(1000 * t_max), '_total.mat');
    if exist(data_total_file_str, 'file')
        if use_data
            load(data_total_file_str, 'tau', 'data');
        else
            load(data_total_file_str, 'tau');
        end
    elseif ~use_data
        tau = 0:dt:t_max;
    else    
        disp("total data file does not exist. Creating one..");
        [tau, data] = get_combined_value_functions( ...
            main_file_id_str, dt, N_save, t_max);
        save(data_total_file_str, 'tau','data', '-v7.3');
    end
    disp("data is set up.");    
else
    tau = 0:dt:t_max;
end

if use_sparse_ttr
    ttr_str = strcat(strcat('sparse_ttr_', num2str(1000 * t_max)), '.mat');
    if exist(strcat(main_file_id_str, ttr_str), 'file')
        disp("Loading from the file..")
        load(strcat(main_file_id_str, ttr_str), 'ttr');
    else
        disp("Sparse ttr file does not exist. Creating one..");
        if use_total_data
            ttr = get_sparse_ttr_from_total(grid, data, tau);
        else
            ttr = get_sparse_ttr_from_separate(main_file_id_str, dt, N_save, t_max);
        end
        save(strcat(main_file_id_str, ttr_str), 'ttr');
    end
else
    % use the original ttr
    ttr_str = strcat(strcat('ttr_', num2str(1000 * t_max)), '.mat'); 
    if exist(strcat(main_file_id_str, ttr_str), 'file')
        disp("Loading from the file..")
        load(strcat(main_file_id_str, ttr_str), 'ttr');
    else
        error("ttr file does not exist.");
    end
end    
disp("ttr is set up.");

% Set up derivatives of the value function
if use_sparse_derivs
    derivs_str = strcat('sparse_derivs_', num2str(1000 * t_max), '.mat');
    if exist(strcat(main_file_id_str, derivs_str), 'file')
        disp("Loading from the file..")
        load(strcat(main_file_id_str, derivs_str));
    else
        disp("Sparse derivs file does not exist. Creating one..");
        if ~use_sparse_ttr
            error("Sparse derivs cannot be set up if sparse ttr is not used.");
        end
        
        if use_total_data
            derivs = get_sparse_derivs_from_total(grid, data, tau, ttr);
        else
            derivs = get_sparse_derivs_from_separate(main_file_id_str, dt, N_save, t_max, grid, ttr);
        end
        save(strcat(main_file_id_str, derivs_str), 'derivs');
    end
else
    % Use the original derivs defined over the entire time.
    derivs_str = 'derivs.mat';
    if exist(strcat(main_file_id_str, derivs_str), 'file')
        disp("Loading from the file..")
        load(strcat(main_file_id_str, derivs_str));
    else
        disp("dervis file does not exist. Creating one..");    
        derivs = computeGradients(grid, data);
        save(strcat(main_file_id_str, derivs_str), 'derivs', '-v7.3');
    end        
end
disp("derivs is set up.");
