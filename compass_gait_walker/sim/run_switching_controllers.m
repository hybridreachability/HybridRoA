function [xRec, fRec, uRec, tRec, xRec_tilde, extraOuts] = ...
    run_switching_controllers(x0, control_params, sim_settings, print_log)
%% [xRec, fRec, uRec, tRec, xRec_tilde, extraOuts] = ...
%%    run_switching_controllers(x0, control_params, sim_settings)
% Runs simulation with optimal controller switching to
% feedback linearization controller when the state reaches the target.
check_control_params(control_params);
sim_settings.reset_q1d = control_params.gait_params(5);
[sim_event_option, reset_q1_threshold, reset_q1d, dt, num_steps, min_num_steps_io] ...
    = parse_sim_settings(sim_settings);
if nargin < 4
    print_log = true;
end
ttr_x0 = eval_floor_ttr(control_params.grid, control_params.ttr, x0);
if print_log
    if ttr_x0 > 1000
        disp("x0 has invalid TTR value (it is likely that this x0 is not in the BRT. Try different initial state.")
    end
    fprintf("x0 TTR: %.3f sec.\n", ttr_x0);
    if ~isempty(control_params.data)
        value_function = squeeze(control_params.data(:, :, :, :, end));
        value_x0 = eval_u(control_params.grid, value_function, x0);
        fprintf("x0 Value function (of terminal timestep): %.3f.\n", value_x0);
    end
end
if ttr_x0 <= 0
    ttr_x0 = 0.001; % temporal fix for end_option: time simulation.
end

dynSys = CompassWalker('gait_params', control_params.gait_params, ...
    'x', x0, ...
    'event_type', sim_event_option, ...
    'reset_q1_threshold', reset_q1_threshold);

%% First Step (applying Optimal control for evaluation of BRT)
if print_log
    disp("Evaluating the optimal control...");
end
% Simulate optimal trajectory
[xRec, tRec, uRec, extraOuts] = ...
    run_optimal_controller(x0, control_params.grid, ...
    control_params.target_function, control_params.data, ...
    control_params.tau, control_params.ttr, control_params.derivs, dynSys, ...
    'end_option', 'reach', ...
    't_final', ttr_x0, ...
    'reset_q1_threshold', reset_q1_threshold, ...
    'dt', dt, 'visualize', false, 'print_log', print_log);
indices_reset = extraOuts.indices_reset;
num_steps_opt = extraOuts.num_steps;
fRec = [];
for i = 1:length(tRec)
    fRec = [fRec; Fst_gen(xRec(i, :)', uRec(i))'];
end
xRec_tilde = xs_tilde_from_original(xRec, control_params.gait_params);

index_io = [];
if ~extraOuts.failure
    %% Next Steps - apply IO linearization control to check that the state actually converges to the gait.
    % Load necessary hyperparams for IO linearization.
    if print_log
        disp("Applying feedback linearization for the rest of the simulation.");
    end
    x0_next = xRec(end, :)';
    num_steps_io = max(num_steps - num_steps_opt, min_num_steps_io);
    index_io = length(tRec) + 1;

    sim_settings.sim_option= 'vanilla_class';
    sim_settings.num_steps = num_steps_io;
    sim_settings.dt = 0.001;

    [xRec_next, fRec_next, uRec_next, tRec_next, xRec_tilde_next, extraOuts_io] = ...
        run_feedback_linearization(x0_next, control_params, sim_settings, print_log);
    indices_reset = [indices_reset; index_io-1+extraOuts_io.indices_reset];

    %% Final history
    xRec = [xRec; xRec_next];
    fRec = [fRec; fRec_next];
    uRec = [uRec; uRec_next];
    tRec = [tRec; tRec_next+tRec(end)];
    xRec_tilde = [xRec_tilde; xRec_tilde_next];
    extraOuts.num_steps_io = num_steps_io;
end
extraOuts.index_io = index_io;
extraOuts.indices_reset = indices_reset;
extraOuts.failure = extraOuts.failure || extraOuts_io.failure;
end

function check_control_params(control_params)
    if ~isfield(control_params, {'gait_params', 'grid', 'data', 'tau', 'ttr', 'derivs'})
        error("control_params lacks necessary fields.");
    end
end

function [event_type, reset_q1_threshold, reset_q1d, dt, num_steps, min_num_steps_io] = ...
    parse_sim_settings(sim_settings)    
    if ~isfield(sim_settings, 'event_type')
        event_type = 'foot';
    else
        event_type = sim_settings.event_type;
    end

    if ~isfield(sim_settings, 'reset_q1_threshold')
        reset_q1_threshold = -0.03;
    else
        reset_q1_threshold = sim_settings.reset_q1_threshold;
    end
    
    if ~isfield(sim_settings, 'reset_q1d')
        error("control_params.gait_params or sim_settings.reset_q1d should be specified.");
    else
        reset_q1d = sim_settings.reset_q1d;
    end
    
    if ~isfield(sim_settings, 'dt')
        dt = 0.001;
    else
        dt = sim_settings.dt;
    end
    
    if ~isfield(sim_settings, 'num_steps')
        num_steps = 4;
    else
        num_steps = sim_settings.num_steps;
    end
    
    if ~isfield(sim_settings, 'min_num_steps_io')
        min_num_steps_io = 2;
    else
        min_num_steps_io = sim_settings.min_num_steps_io;
    end
end