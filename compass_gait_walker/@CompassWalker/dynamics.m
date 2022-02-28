function [dx, u_out] = dynamics(obj, t, x, u, d)
if nargin < 4 && ~obj.run_closed_loop
    error("Not supported, provide u or set obj.run_closed_loop to true.");
end
if nargin < 5
    if iscell(x)
        error("Not supported.");
    end
    d = 0;
end

%% u_out: Returns u that is used in the closed loop controller
u_out = [];
% disp(t)

is_x_cell = iscell(x);

if obj.run_closed_loop
    %% IO Control
    if is_x_cell
        if isempty(obj.grid)
            error("Not supported. (TODO)");
        end
        dx = obj.closed_loop_dynamics_grid;
        u_out = obj.us_closed_loop_grid;
        for i = 1:obj.nx
            if obj.freeze_dynamics
                dx{i} = dx{i} .* ~(obj.grid.xs{1} < obj.reset_q1_threshold & obj.pSw_y_grid < 0);
            end
        end        
    else
        x_full = zeros(8, 1);
        x_full([3, 4, 7, 8]) = x;
        u = two_link_io_control(x_full, obj.control_params, obj.uMax);
        if u < obj.uMin
            u = obj.uMin;
        elseif u > obj.uMax
            u = obj.uMax;
        end
        dx = obj.get_fvec(x) + obj.get_gvec(x) * u;
        u_out = u;
        if obj.freeze_dynamics
            pSw_y = obj.lL * (cos(x(1)) - cos(x(1)+x(2)));
            dx = dx .* ~(x(1) < obj.reset_q1_threshold & pSw_y < 0);
        end
    end
    return
end

%% For open loop computation (u is coming from the optCtrl function.)
if is_x_cell
    if isempty(obj.grid)
        error("Not supported. (TODO)");
    end
    
    dx = cell(obj.nx, 1);
    d_to_u = -obj.grid.xs{4} .* d{1};
    for i = 1:obj.nx
        dx{i} = obj.fs_grid{i} + obj.gs_grid{i} .* u{1} + obj.gs_grid{i} .* d_to_u;
        if obj.freeze_dynamics
            dx{i} = dx{i} .* ~(obj.grid.xs{1} < obj.reset_q1_threshold & obj.pSw_y_grid < 0);
        end
    end    
else
%     x_full = zeros(8, 1);
%     x_full([3, 4, 7, 8]) = x;
%     dx = obj.get_fvec(x) + obj.get_gvec(x) * u + obj.get_gvec(x) *
%     two_link_disturbance(x_full, obj.gait_params); % Ayush's model: hard
%     to compute the hamiltonian for the disturbance.
    dx = obj.get_fvec(x) + obj.get_gvec(x) * u + obj.get_gvec(x) * (-x(4) * d);
    if obj.freeze_dynamics
        pSw_y = obj.lL * (cos(x(1)) - cos(x(1)+x(2)));
        dx = dx .* ~(x(1) < obj.reset_q1_threshold & pSw_y < 0);
    end
end