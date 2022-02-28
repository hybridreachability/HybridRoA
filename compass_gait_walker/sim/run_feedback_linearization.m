function [xRec, fRec, uRec, tRec, xRec_tilde, extraOuts] = run_feedback_linearization(x0, ...
    control_params, ...
    sim_settings, print_log)
%TWO_LINK_SIMULATE simulates the two link robot for Nsteps number of
%walking steps and with I/O parameters beta and initial condition x0.
% Ayush Agrawal, Jason Choi
% ayush.agrawal@berkeley.edu
% jason.choi@berkeley.edu
% Inputs:   x0: initial state of the step in full representation in the original coordinate (8 x 1 vector)
%           beta: bezier coefficients that define the reference gait
%           Nsteps: number of walking steps to simulate
%           th1d: desired value of q1 (phase var) at the end of a step
%           sim_option: simulation option.
%              'vanilla': use two_link_dynamics.m to run simulation.
%               'tilde': use two_link_dynamics_tilde.m to run simulation.
%               'vanilla_class': use CompassWalker.dynamics to run simulation.
%               'tilde_class': use CompassWalkerTilde.dynamics to run simulation.
%           sim_event_option: event used for reset map in simulation.
%               'angle': Reset is defined as q1 reaching q1_desired.
%               'foot': Reset is defined as foot position reaching the
%               ground (y=0).
if nargin < 4
    print_log = false;
end

if length(x0) == 4
    x0 = convert_condensed_states_to_full_states(x0')';
end
    
[gait_params, eps] = parse_control_params(control_params);
sim_settings.reset_q1d = gait_params(5);
[sim_option, sim_event_option, reset_q1_threshold, reset_q1d, dt, Nsteps] = ...
    parse_sim_settings(sim_settings);


if check_on_switching_surface(x0)
    xRec = x0';
    x0 = reset_map_full(x0);
    Nsteps = Nsteps - 1;
    tRec = [0; 0];
    xRec_tilde = xs_tilde_from_original(xRec, gait_params);
    indices_reset = 1;
else
    % variables to record data
    tRec = 0;
    xRec = [];
    xRec_tilde = [];
    indices_reset = [];
end
% parameters
params.ctrl_type = 'io';
params.beta = gait_params(1:4);
params.th1d = gait_params(5);
params.eps = eps; % Epsilon used in feedback linearization.
params.reset_q1_threshold = reset_q1_threshold;
params.reset_q1d = reset_q1d;

% Reflection matrix (swap leg1 and 2)
R = two_link_reflect;
failure = false;
for i = 1:Nsteps
    step_summary.x_init = x0;
    [xs, ts, xs_tilde, failure, params] = step_simulate_helper(x0, tRec(end), params, sim_option, sim_event_option, dt);    
    
    % Record data
    tRec = [tRec;ts];
    xRec = [xRec;xs];
    xRec_tilde = [xRec_tilde;xs_tilde];
    indices_reset = [indices_reset; length(tRec)-1];
    step_summary.x_terminal = xs(end, :)';
    % Check swing foot position
    pSw_at_event = pSw_gen(xs(end, :)');
    step_summary.pSw_terminal = pSw_at_event;
    
    if print_log
        print_step_summary(i, step_summary);
    end
    
    if failure
        break
    end
    
    %% Apply reset map and reinitialize initial state for next step.
    q_minus = xs(end, 1:4)';
    dq_minus = xs(end, 5:end)';
    q_plus = R*q_minus;
    dq_plus = R*dqPlus_gen([q_minus;dq_minus]);
    x0 = [q_plus;dq_plus];    
end

tRec = tRec(2:end);
uRec = [];
fRec = [];
%% Compute control inputs and Contact forces
for i = 1:length(tRec)
    u = two_link_io_control_clf_qp(xRec(i, :)', params, 4);
    uRec = [uRec; u];
    fRec = [fRec; Fst_gen(xRec(i, :)', u)'];
end
extraOuts.indices_reset = indices_reset;
extraOuts.failure = failure;
end

function [xs, ts, xs_tilde, failure, params] = step_simulate_helper(x0, t0, params, sim_option, event_option, dt)
%% function that runs walk step simluation
% Inputs:   x0: initial state of the step in full representation in the original coordinate (8 x 1 vector)
%           t0: initial time of the step
%           params: control params
%               .ctrl_type
%               .beta
%               .eps
%               .th1d
%           sim_option: simulation option
%              'vanilla': use two_link_dynamics.m to run simulation.
%              'tilde': use two_link_dynamics_tilde.m to run simulation.
%              'vanilla_class': use CompassWalker.dynamics to run simulation.
%              'tilde_class': use CompassWalkerTilde.dynamics to run simulation.
    failure = false;
    t_insane = 1.2;
    x_norm_insane = 50;
    tspan = t0:dt:t0+t_insane;
    gait_params = [params.beta;params.th1d];
    if strcmp(sim_option, 'vanilla')
        dynamics_function = @(t,x)two_link_dynamics(t, x, params);
        event_function = @(t, x)two_link_event(t, x, params, event_option);
        odeOpts = odeset('Events', event_function);
        [ts, xs] = ode45(dynamics_function, tspan, x0, odeOpts);
        xs_tilde = xs_tilde_from_original(xs, gait_params);           
    elseif strcmp(sim_option, 'vanilla_class')
        dynsys = CompassWalker('gait_params', gait_params, ...
            'event_type', event_option);
%         dynsys = CompassWalker('gait_params', gait_params, ...
%             'event_type', event_option, ...
%             'run_closed_loop', true);
%         dynamics_function = @(t,x) dynsys.dynamics(t, x, []);
%         event_function = @dynsys.reset_event;
%         odeOpts = odeset('Events', event_function);
        x0_condensed = x0([3, 4, 7, 8]);
        init_stance_position = pSt_gen(x0);
%         [ts, xs_condensed] = ode45(dynamics_function, tspan, x0_condensed, odeOpts);
        [xs_condensed, us, ts] = rollout_one_step( ...
            x0_condensed, t0, dynsys, dt);
        xs = convert_condensed_states_to_full_states( ...
            xs_condensed, init_stance_position);
        xs_tilde = xs_tilde_from_original(xs, gait_params);
        params = dynsys.control_params;
    elseif strcmp(sim_option, 'tilde')
        x0_tilde = [q_tilde_from_q_gen(x0(1:4), gait_params); 
            dq_tilde_from_qdq_gen(x0(1:4), x0(5:8), gait_params)];
        dynamics_function = @(t,x)two_link_dynamics_tilde(t, x, params);
        event_function = @(t, x)two_link_event_tilde(t, x, params, event_option);
        odeOpts = odeset('Events', event_function);
        [ts, xs_tilde] = ode45(dynamics_function, tspan, x0_tilde, odeOpts);
        xs = xs_original_from_tilde(xs_tilde, gait_params);
    elseif strcmp(sim_option, 'tilde_class')
        dynsys = CompassWalkerTilde(1:4, gait_params, [], event_option);
        dynamics_function = @(t,x) dynsys.dynamics(t, x, [], [], true, params);
        event_function = @dynsys.reset_event;
        odeOpts = odeset('Events', event_function);
        init_stance_position = pSt_gen(x0);
        x0_tilde = [q_tilde_from_q_gen(x0(1:4), gait_params); 
            dq_tilde_from_qdq_gen(x0(1:4), x0(5:8), gait_params)];
        x0_condensed_tilde = x0_tilde([3, 4, 7, 8]);
        [ts, xs_condensed_tilde] = ode45( ...
            dynamics_function, tspan, x0_condensed_tilde, odeOpts);
        xs_tilde_temp = zeros(length(ts), 8);
        xs_tilde_temp(:, [3,4,7,8]) = xs_condensed_tilde;
        xs_original_temp = xs_original_from_tilde(xs_tilde_temp, gait_params);
        xs_condensed = xs_original_temp(:, [3, 4, 7, 8]);
        xs = convert_condensed_states_to_full_states( ...
            xs_condensed, init_stance_position);
        xs_tilde = xs_tilde_from_original(xs, gait_params);
    end
    
    if ts(end) == t0+t_insane || norm(xs(end, [3, 4, 7, 8])) > x_norm_insane
        failure = true;
    end
end

function print_step_summary(i, log)
    fprintf("------Summary of %d-th step------\n", i);
    disp("Initial state");
    disp(log.x_init');
    disp("Terminal state");
    disp(log.x_terminal');
    disp("Swing foot position at terminal state (x, y)");
    disp(log.pSw_terminal');    
end

function [gait_params, eps] = parse_control_params(control_params)
    if ~isfield(control_params, 'gait_params')
        error("control_params.gait_params should be specified.");
    else
        gait_params = control_params.gait_params;
    end
    if ~isfield(control_params, 'eps')
        eps = 0.1;
    else
        eps = control_params.eps;
    end
end

function [sim_option, event_type, reset_q1_threshold, reset_q1d, dt, num_steps] = ...
    parse_sim_settings(sim_settings)
    if ~isfield(sim_settings, 'sim_option')
        sim_option = 'vanilla_class';
    else
        sim_option = sim_settings.sim_option;
    end
    
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
        num_steps = 1;
    else
        num_steps = sim_settings.num_steps;
    end
end