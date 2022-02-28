% clear all;
% close all;
%% Load reachability related data.
set_reachability_post_evaluation;
%% Simulation settings.
num_steps = 4;
min_num_steps_io = 2;

%% Plot settings
save_plots = false;

%% Set the initial state.
q0 = [0.286; -0.052];
dq0 = [-0.5; 3.8];

% x0 = [0.0560; 0.1215; -0.1638; 1.1407]; % on the reference gait.
% x0 = [0.0098; 0.2878; -0.3106; 0.5262]; % on the reference gait.
x0 = [q0; dq0]; % condensed

% For double checking if the initial state actually has finite ttr.
ttr_x0 = eval_floor_ttr(grid, ttr, x0);
disp(ttr_x0)
if ttr_x0 > 1000
    disp("x0 has invalid TTR value (it is likely that this x0 is not in the BRT. Try different initial state.")
end
fprintf("x0 TTR: %.3f sec.\n", ttr_x0);
if ~isempty(data)
    value_function = squeeze(data(:, :, :, :, end));
    value_x0 = eval_u(grid, value_function, x0);
    fprintf("x0 Value function (of terminal timestep): %.3f.\n", value_x0);
end
if ttr_x0 <= 0
    ttr_x0 = 0.001; % temporal fix for end_option: time simulation.
end

dynSys = CompassWalker('gait_params', gait_params, ...
    'x', x0, ...
    'event_type', 'foot');

%% First Step (applying Optimal control for evaluation of BRT)
disp("Evaluating the optimal control.");
% Simulate optimal trajectory
[xRec, tRec, uRec, extraOuts] = ...
    run_optimal_controller(x0, grid, target_function, data, tau, ttr, derivs, dynSys, ...
    'end_option', 'reach', ...
    't_final', ttr_x0, ...
    'visualize', false, 'print_log', true);
ttrRec = extraOuts.ttrs;
VRec = extraOuts.Vs;
LgVRec = extraOuts.LgVs;
num_steps_opt = extraOuts.num_steps;
fig = extraOuts.fig;
indices_reset = extraOuts.indices_reset;

% xRec = convert_condensed_states_to_full_states(xRec_condensed);
% Compute Contact forces
fRec = [];
for i = 1:length(tRec)
    fRec = [fRec; Fst_gen(xRec(i, :)', uRec(i))'];
end
xRec_tilde = xs_tilde_from_original(xRec, gait_params);

index_io = [];
if ~extraOuts.failure
    %% Next Steps - apply IO linearization control to check that the state actually converges to the gait.
    % Load necessary hyperparams for IO linearization.
    disp("Applying feedback linearization for the rest of the simulation.");
    x0_next = xRec(end, :)';
    num_steps_io = max(num_steps - num_steps_opt, min_num_steps_io);
    index_io = length(tRec) + 1;

    control_params.gait_params = gait_params;
    sim_settings.sim_option= 'vanilla_class';
    sim_settings.event_type = 'foot';
    sim_settings.num_steps = num_steps_io;
    sim_settings.dt = 0.001;

    [xRec_next, fRec_next, uRec_next, tRec_next, xRec_tilde_next, extraOuts_io] = ...
        run_feedback_linearization(x0_next, control_params, sim_settings);
    indices_reset = [indices_reset; index_io-1+extraOuts_io.indices_reset];

    %% Final history
    xRec = [xRec; xRec_next];
    fRec = [fRec; fRec_next];
    uRec = [uRec; uRec_next];
    tRec = [tRec; tRec_next+tRec(end)];
    xRec_tilde = [xRec_tilde; xRec_tilde_next];
    extraOuts.index_io = index_io;
    extraOuts.num_steps_io = num_steps_io;
end
extraOuts.indices_reset = indices_reset;

fig_name_main = strcat('fig_', main_file_id_str);
if save_plots
    plot_main_state_history(tRec, xRec, ...
        'gait', gait, 'indices_reset', indices_reset, ...
        'index_io', index_io, 'fig_name', strcat(fig_name_main, 'state'));
    plot_main_control_history(tRec, uRec, ...
        'index_io', index_io, 'fig_name', strcat(fig_name_main, 'control'));
    plot_main_contact_history(tRec, fRec, 'index_io', index_io, ...
        'fig_name', strcat(fig_name_main, 'contact'));
    plot_main_output(tRec, xRec, ...
        'gait_params', gait_params, 'fig_name', strcat(fig_name_main, 'output'));
    plot_main_phase_plot(tRec, xRec, xRec_tilde, ...
        'gait', gait, 'index_io', index_io, ...
        'fig_name', strcat(fig_name_main, 'phase'));
else
    plot_main_state_history(tRec, xRec, 'index_io', index_io, 'gait', gait, ...
        'indices_reset', indices_reset);
    plot_main_control_history(tRec, uRec, 'index_io', index_io);
    plot_main_contact_history(tRec, fRec, 'index_io', index_io);       
    plot_main_output(tRec, xRec, ...
        'gait_params', gait_params, 'index_io', index_io);
    plot_main_phase_plot(tRec, xRec, xRec_tilde, ...
        'gait', gait, 'index_io', index_io);
end
sim_name_main = strcat('sim_', main_file_id_str);
save(sim_name_main, 'x0', 'tRec', 'xRec', 'fRec', 'uRec', 'xRec_tilde', 'extraOuts');
