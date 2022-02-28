close all
clear all
%% Plot settings (for visualization and debugging.)
plot_grid = true;
plot_target = true;
plot_reset_map = true;

%% Save settings
add_date_string = true;
custom_string_for_files = 'result_';

%% Main computation settings
precompute_dynamics_table = true; % Usually, true makes computation much faster.
reset_option = 'foot'; % 'foot', 'angle'
apply_value_function_remapping = true;
apply_freeze = false;
apply_closed_loop_feedback_linearization = false;
apply_disturbance = false;
% time interval for saving data
dt = 0.01;
% terminal time
t_max = 1.5;
% number of timesteps to split data files
N_save = 10;
% Initial time for the computation. (Default is 0, if it is non-zero value,
% you are resuming the brt computation from some previous data file.)
t0 = 0.0;
if apply_closed_loop_feedback_linearization && apply_disturbance
    error("Not supported.");
end

%% Main str id for saving datas
main_file_id_str = custom_string_for_files;
if add_date_string
    main_file_id_str = strcat(main_file_id_str, ...
        datestr(datetime('now'),'yymmdd_HH'));
    main_file_id_str = strcat(main_file_id_str, '_');
end

if apply_value_function_remapping
   main_file_id_str = strcat(main_file_id_str, 'remap_');
end
if apply_freeze
    main_file_id_str = strcat(main_file_id_str, 'freeze_');
end
if apply_closed_loop_feedback_linearization
    main_file_id_str = strcat(main_file_id_str, 'closed_');
end
if apply_disturbance
    main_file_id_str = strcat(main_file_id_str, 'disturbance_');
end
setting_info_id_str = strcat(main_file_id_str, 'setting_info.mat');
save(setting_info_id_str, 'reset_option', 'precompute_dynamics_table', ...
    'apply_value_function_remapping', 'apply_freeze', 'apply_disturbance', ...
    'dt', 't_max', 'N_save', 't0');

%% Set up grid.
grid_file_str = strcat(main_file_id_str, 'grid.mat');
if exist(grid_file_str, 'file')
    load(grid_file_str, 'grid');
else
    disp("grid file does not exist. Creating one..");
    % q1, q2, q1dot, q2dot
    % IMPORTANT: Make sure that q2s contains -2*q1s and dq2s contains
    % -2*dq1s. This is very important to match with the switching surface.
    grid_min = [-0.52; -1.04; -4.0; -8.0];
    grid_max = [0.52; 1.04; 4.0; 8.0];    
    N = [41; 81; 81; 81];
    grid = createGrid(grid_min, grid_max, N);
    save(grid_file_str, 'grid', '-v7.3');
end
disp("grid is set up.");


%% Set up gait params
gait_file_str = strcat(main_file_id_str, 'gait.mat');
if exist(gait_file_str, 'file')
    load(gait_file_str, 'gait', 'gait_params');
else
    disp("gait data not specified. Loading one..");
    load('gait_from_clf_qp_ral.mat', 'gait_params', 'xRec');
    gait = xRec(:, [3, 4, 7, 8]);
    save(gait_file_str, 'gait', 'gait_params');
end
disp("gait is set up.");

if plot_grid
    vis_grid_original(grid, gait);
end

%% Set up the target function.
target_function_file_str = strcat(main_file_id_str, 'target.mat');
if exist(target_function_file_str, 'file')
    load(target_function_file_str, 'target_function');
else
    disp("target_function data file does not exist. Creating one frome the gait..");
    distance_threshold = 0.2;
    target_function = get_target_function_from_gait( ...
        grid, gait, distance_threshold, plot_target);
    save(target_function_file_str, 'target_function', 'distance_threshold', '-v7.3');
end
disp("target_function is set up.");

if plot_target
    vis_level_set_2d(grid, target_function, 'gait', gait); 
    save_figure('file_name', strcat(main_file_id_str, 'fig_target2d'), 'file_format', 'png');
    vis_level_set_3d(grid, target_function, gait, 0, 'foot', -0.15:0.06:0.15);
    save_figure('file_name', strcat(main_file_id_str, 'fig_target3d'), 'file_format', 'png');
end

%% Set up schemeData for helperOC HJIPDE_solve.
scheme_data_file_str = strcat(main_file_id_str, 'scheme_data.mat');
if exist(scheme_data_file_str, 'file')
    load(scheme_data_file_str, 'schemeData');
else
    disp("scheme_data file does not exist. Creating one from the gait..");
    schemeData.u_bound = [-4, 4];
    schemeData.uMode = 'min';
    if apply_disturbance
        schemeData.d_bound = [-0.3, 0.75];
    else
        schemeData.d_bound = [0.0, 0.0];
    end
    schemeData.dMode = 'max';
    schemeData.accuracy = 'high';
    % These are manually set for manual TTR postprocess.
    schemeData.hamFunc = @genericHam;
    schemeData.partialFunc = @genericPartial;
    [schemeData.dissFunc, ~, schemeData.derivFunc] = ...
        getNumericalFuncs('global', schemeData.accuracy);
    if precompute_dynamics_table
        dynsys_grid = grid;
    else
        dynsys_grid = [];
    end

    schemeData.dynSys = CompassWalker('gait_params', gait_params, ...
        'grid', dynsys_grid, ...
        'u_bound', schemeData.u_bound, ...
        'd_bound', schemeData.d_bound, ...
        'freeze_dynamics', apply_freeze, ...
        'run_closed_loop', apply_closed_loop_feedback_linearization); 
    save(scheme_data_file_str, 'schemeData');
end

%% Set up reset map if apply_value_function_remapping is true.
if apply_value_function_remapping
    reset_map_file_str = strcat(main_file_id_str, 'reset_map.mat');
    if exist(reset_map_file_str, 'file')
        load(reset_map_file_str, 'reset_map', 'xs_switching_surface', 'xs_post_assigned');
    else
        disp("reset_map file does not exist. Creating one from the grid..");
        [reset_map, xs_switching_surface, xs_post_assigned] = ...
            get_value_function_reset_map(grid, 'foot');
        save(reset_map_file_str, 'reset_map', 'xs_switching_surface', 'xs_post_assigned', '-v7.3');
    end
    schemeData.reset_map = reset_map;
    disp("reset_map is set up.");
    if plot_reset_map
        vis_reset_map(grid, gait);
        save_figure('file_name', strcat(main_file_id_str, 'fig_true_reset_map'), 'file_format', 'png');
        vis_value_function_reset_map(grid, xs_switching_surface, xs_post_assigned, gait);
        save_figure('file_name', strcat(main_file_id_str, 'fig_assigned_reset_map'), 'file_format', 'png');
    end
end
    
%% Set up dynamics and grid (this is not included in saved file because they are all included in the previous saved files.);   
schemeData.grid = grid;
disp("schemeData is set up. Initiating HJIPDE_solve");

HJIextraArgs.targetFunction = target_function;

%% Compute BRT
dt_save = N_save * dt;
N_max = ceil(t_max / dt_save);
if floor(t0 / dt_save) ~= (t0 / dt_save)
    error("t0 is not set up properly");
end
N_init = floor(t0 / dt_save) + 1;
if N_init == 1
    data = target_function;
else
    last_final_file_str = strcat(main_file_id_str,num2str(1000*t0));
    load(last_final_file_str, 'data');
    data = squeeze(data(:, :, :, :, end));
end

for i = N_init:N_max
    tau = t0:dt:t0+dt_save;
    [data, tau, extraOuts] = ...
            HJIPDE_solve_with_reset_map(data, tau, schemeData, 'minVWithL', HJIextraArgs);
    final_t = tau(end);
    
    %% Postprocess for saving data
    if i > 1
        data = data(:, :, :, :, 2:end);
        tau = tau(2:end);
    end
    save(strcat(strcat(main_file_id_str,num2str(1000*final_t)),'.mat'),...
            'tau','data','-v7.3');
    data = squeeze(data(:, :, :, :, end));
    t0 = tau(end);
end
