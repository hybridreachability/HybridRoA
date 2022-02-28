function [xs, us, ts] = rollout_one_step( ...
    x_init_step, t_init_step, dynsys, dt)
if nargin < 4   
    dt = 0.001;
end
sim_t = 3;
% Total time step
total_k = ceil(sim_t / dt);

% Initialize traces.
x = x_init_step; xs = x_init_step';
t = t_init_step; ts(1) = t;
us = [];
event_function = @dynsys.reset_event;
odeOpts = odeset('Events', event_function);
%% Run Simulation
for k = 1:total_k-1
    x_full = zeros(8, 1);
    x_full([3, 4, 7, 8]) = x;
    u = two_link_io_control_clf_qp(x_full, dynsys.control_params, dynsys.uMax); % u=u_star + LgLf\mu
    us = [us; u];
    
    [ts_k, xs_k, te] = ode45(@(t, s) dynsys.dynamics(t, s, u, 0.0), [t t+dt], x, odeOpts);

    if isempty(te)
        t = ts_k(end);
        ts = [ts; t];
        x_next = xs_k(end, :)';
        xs = [xs; x_next'];    
    else
        % foot hit the ground.
        return;
    end    
    x = x_next;
end % end of main for loop