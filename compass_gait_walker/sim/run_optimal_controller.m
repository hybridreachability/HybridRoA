function [xs, ts, us, extraOuts] = run_optimal_controller( ...
    x0_condensed, grid, target_function, data, tau, ttr, derivs, dynsys, varargin)
%% MODIFICATION OF computeOptTraj in helperOC
%   uses TTR to evaluate the time horizon to use.
%   taylored for the compass-gait-walker
%
%   Computes the optimal trajectories given the optimal value function
%   represented by (g, data), associated time stamps tau, dynamics given in
%   dynSys.
%
% Inputs:
%   x0: initial state
%   grid, data - grid and value function
%   tau     - time stamp (must be the same length as size of last dimension of
%                         data)
%   ttr - time-to-reach data for the grid points.
%   dynsys  - CompassWalker object
%   extra arguments:
%     'dt' - sampling time for simulation (default: 0.001)
%     'end_option'   - options for ending the simulation. (default:
%     'reach');
%           'reach' : end the simulation when the value function gets
%           negative
%           'time'  : end the simulation when specified time ends
%           ('t_final' should be specified together)
%           'ground' : end the simulation when it reaches the ground.
%     'uMode'        - specifies whether the control u aims to minimize or
%                     maximize the value function
%     'visualize'    - set to true to visualize results
%     'projDim'      - set the dimensions that should be projected away when
%                     visualizing
%     'fig_filename' - specifies the file name for saving the visualizations
%     't_final'
% TODO: ADD Disturbance
if nargin < 8
    error("x0, grid, data, tau, ttr, derivs, dynsys must be provided.");
end
hj_data.grid = grid;
hj_data.target_function = target_function;
hj_data.data = data;
hj_data.tau = tau;
hj_data.ttr = ttr;
hj_data.dynsys = dynsys;
hj_data.derivs = derivs;

extraArgs = parse_function_args(varargin{:});
if ~isfield(extraArgs, 'dt')
    dt = 0.001;
else
    dt = extraArgs.dt;
end
if ~isfield(extraArgs, 'end_option')
    extraArgs.end_option = 'reach';
end

if strcmp(extraArgs.end_option, 'time')
    if ~isfield(extraArgs, 't_final')
        disp("Warning: 't_final' is not set, setting the value to max(tau).");
        t_final = max(tau);
    else
        t_final = extraArgs.t_final;
    end
end

if strcmp(extraArgs.end_option, 'ground')
    error("Not implemented. TODO.");
end

print_log = false;
if isfield(extraArgs, 'print_log')
    print_log = extraArgs.print_log;
end

% Default parameters
uMode = 'min';
if isfield(extraArgs, 'uMode')
    uMode = extraArgs.uMode;
end
hj_data.uMode = uMode;

% Visualization
fig = [];
visualize = false;
if isfield(extraArgs, 'visualize') && extraArgs.visualize
    visualize = extraArgs.visualize;
    if ~isfield(extraArgs, 'projDim')
        extraArgs.projDim = [0 0 1 1]; % Showing q1 q2 as the default axes.
    end
    showDims = find(extraArgs.projDim);
    hideDims = ~extraArgs.projDim;
    fig = open_figure();
end

if any(diff(tau) < 0)
  error('Time stamps must be in ascending order!')
end

%% Initialization.
stance_foot_position =[0, 0];
t = 0;
if check_on_switching_surface(x0_condensed)
    % Initial state is already on the switching surface.
    % reset the state to post-reset.
    x_pre_full = convert_condensed_states_to_full_states( ...
        x0_condensed', stance_foot_position)';
    [u, ttr_x, V_x, LgV_x] = get_optctrl(hj_data, x0_condensed);
    x0_full = reset_map_full(x_pre_full);
    stance_foot_position = pSt_gen(x0_full);
    xs = [x_pre_full'; x0_full'];
    ts = [t; t];
    us = u;
    ttrs = ttr_x;
    Vs = V_x;
    LgVs = LgV_x;
    x = x0_full([3, 4, 7, 8]);
    num_steps = 1;
    indices_reset = 1;
else
    x0_full = convert_condensed_states_to_full_states(x0_condensed')';
    x = x0_condensed;
    num_steps = 0;
    indices_reset = [];
    xs = x0_full'; ts = t; us = [];
    ttrs = []; Vs = []; LgVs = [];
end
failure = false;
odeSolver = @ode45;
% value of the target function at current state
target_x = eval_u(grid, target_function, x); 
eps = 1e-5;
t_insane = 2.0;
if strcmp(extraArgs.end_option, 'time')
    while t < t_final
%         disp(t);
        % Determine optimal control input
        try
            [u, ttr_x, V_x, LgV_x] = get_optctrl(hj_data, x);
        catch e
            disp("Warning: error occured while evaluating optimal u. (x out of grid bound.)");
            failure = true;
            break
        end
%         u = dynsys.optCtrl([], x, deriv, uMode);
        us = [us; u];
        ttrs = [ttrs; ttr_x];
        Vs = [Vs; V_x];
        LgVs = [LgVs; LgV_x];

        % Run one time step propagation.
        dynamics_function = @(t,x) dynsys.dynamics(t, x, u);
        event_function = @dynsys.reset_event;
        odeOpts = odeset('Events', event_function);
        tspan = [t, t+dt];
        [ts_temp, xs_temp] = ode45(dynamics_function, tspan, x, odeOpts);
        if ts_temp(end) == t+dt
            % event did not happen, keep simulating the continuous
            % dynamics.
            x = xs_temp(end, :)';
            x_full = convert_condensed_states_to_full_states(x', stance_foot_position)';
            xs = [xs; x_full'];
            ts = [ts; ts_temp(end)];
            t = ts_temp(end);
        else
            % event happend. reset the state to post-reset.
            x_pre = xs_temp(end, :)';
            x_pre_full = convert_condensed_states_to_full_states( ...
                x_pre', stance_foot_position)';
            x_post_full = reset_map_full(x_pre_full')';
            stance_foot_position = pSt_gen(x_post_full);
            x = x_post_full([3, 4, 7, 8]);
            xs = [xs; x_post_full'];
            num_steps = num_steps + 1;
            ts = [ts; ts_temp(end)];
            t = ts_temp(end);
            indices_reset = [indices_reset; length(ts)];
        end
    end
    
elseif strcmp(extraArgs.end_option, 'reach')
    while target_x > eps && t < t_insane
        % Determine optimal control input
        try
            [u, ttr_x, V_x, LgV_x] = get_optctrl(hj_data, x);
        catch e
            disp("Warning: error occured while evaluating optimal u. (x out of grid bound.)");
            failure = true;
            break
        end
        if print_log
            if ~isempty(V_x)
                fprintf("t: %.4f \t ttr: %.3f \t V: %.3f \t u: %.3f\n", [t, ttr_x, V_x, u]);
            else
                fprintf("t: %.4f \t ttr: %.3f \t u: %.3f \t LgV_x: %.3f\n", [t, ttr_x, u, LgV_x]);
            end
        end
        us = [us; u];
        ttrs = [ttrs; ttr_x];
        Vs = [Vs; V_x];
        LgVs = [LgVs; LgV_x];

        % Run one time step propagation.
        dynamics_function = @(t,x) dynsys.dynamics(t, x, u);
        event_function = @dynsys.reset_event;
        odeOpts = odeset('Events', event_function);
        tspan = [t, t+dt];
        [ts_temp, xs_temp] = ode45(dynamics_function, tspan, x, odeOpts);
        if ts_temp(end) == t+dt
            % event did not happen, keep simulating the continuous
            % dynamics.
            x = xs_temp(end, :)';
            x_full = convert_condensed_states_to_full_states(x', stance_foot_position)';
            xs = [xs; x_full'];
            ts = [ts; ts_temp(end)];
            t = ts_temp(end);    
        else
            % event happend. reset the state to post-reset.
            x_pre = xs_temp(end, :)';
            x_pre_full = convert_condensed_states_to_full_states( ...
                x_pre', stance_foot_position)';
            x_post_full = reset_map_full(x_pre_full);
            stance_foot_position = pSt_gen(x_post_full);
            x = x_post_full([3, 4, 7, 8]);
            xs = [xs; x_post_full'];
            num_steps = num_steps + 1;
            ts = [ts; ts_temp(end)];
            t = ts_temp(end);
            if print_log
                fprintf("Reset happened. post-impact-state: %.2f %.2f %.2f %.2f\n", ...
                    [x(1), x(2), x(3), x(4)]);
            end
            indices_reset = [indices_reset; length(ts)];
        end
        target_x = eval_u(grid, target_function, x);
        if isnan(target_x)
            failure = true;
            break
        end
    end
end
% Evaluate u at the final state and append it to the trajectory to match
% the arrays' sizes.
if ~failure
    try
        [u, ttr_x, V_x, LgV_x] = get_optctrl(hj_data, x);
        us = [us; u];
        ttrs = [ttrs; ttr_x];
        Vs = [Vs; V_x];
        LgVs = [LgVs; LgV_x];
    catch e
        disp("Warning: error occured while evaluating optimal u. (x out of grid bound.)");
        failure = true;
        xs = xs(1:end-1, :);
        ts = ts(1:end-1);
    end
else
    xs = xs(1:end-1, :);
    ts = ts(1:end-1);
end
if t > t_insane
    fprintf("Warning: Optimal control traj might have diverged, Simulation stopped after %.2f sec.\n", t_insane);
    failure = true;
end
extraOuts.ttrs = ttrs;
extraOuts.Vs = Vs;
extraOuts.LgVs = LgVs;
extraOuts.num_steps = num_steps;
extraOuts.fig = fig;
extraOuts.indices_reset = indices_reset;
extraOuts.failure = failure;
end

function [u, ttr_x, V_x, LgV_x] = get_optctrl(hj_data, x)
    grid = hj_data.grid;
    data = hj_data.data;
    tau = hj_data.tau;
    ttr = hj_data.ttr;
    dynsys = hj_data.dynsys;
    derivs = hj_data.derivs;
    use_sparse_derivs = false;
    if length(size(derivs{1})) == 4
        use_sparse_derivs = true;
    end
    
    dt_tau = tau(2) - tau(1);
    try
        ttr_x = eval_floor_ttr(grid, ttr, x);
    catch e
        rethrow(e)
    end
    % index of the value function to use
    if ttr_x > dt_tau/2
        tau_interest = tau - ttr_x <= 0;
        [~, index_t]  = max(tau(tau_interest));
    else
        index_t = 1;
    end
    
    V_x = [];
    if ~isempty(data)
        data_x = squeeze(data(:, :, :, :, index_t));
        V_x = eval_u(grid, data_x, x);
        % Dumb search..
        while (V_x < 0.001 && index_t > 1)
            index_t = index_t -1;
            data_x = squeeze(data(:, :, :, :, index_t));
            V_x = eval_u(grid, data_x, x);
        end
    end

    if use_sparse_derivs
        derivs_x = derivs;
    else
        derivs_x = cell(4, 1);
        for j = 1:4
            derivs_x{j} = squeeze(derivs{j}(:, :, :, :, index_t));
        end
    end
        
    deriv_x = eval_u(grid, derivs_x, x);
    LgV_x = deriv_x' * squeeze(dynsys.get_gvec(x));
    u = dynsys.optCtrl([], x, deriv_x, hj_data.uMode);    
end


