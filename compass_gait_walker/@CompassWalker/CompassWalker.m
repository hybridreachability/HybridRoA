classdef CompassWalker < DynSys
    properties
        % Control bounds.
        uMax
        uMin
        dMax
        dMin
        
        % model params
        lL = 1;
        mL = 1;
        g = 9.81
        mH = 1;
                
        % Control and gait settings.
        % gait_params(1:4): beta, gait_params(5): th1d
        gait_params
        eps
        control_params
        default_ref_traj_file_name = 'x_opt_star_ral.mat'
        
        % Simulation setting.
        event_type
        reset_q1_threshold
        reset_q1d
        
        %% Reachability settings.
        dims
        % if true, dynamics is freezed (dx = 0) when the state is below the
        % switching surface.
        freeze_dynamics
        % If true, computation is done for closed loop dynamics with
        % feedback linearization controller.
        run_closed_loop
        % grid: (if not empty, pre-compute the vector fields f, g  on the grid points to speed up HJIPDE_solve)
        grid 
        % values of f on the grid points.
        fs_grid
        % values of g on the grid points.
        gs_grid
        % value of swing foot position on the grid points.
        pSw_y_grid        
        % vector field of the closed_loop_dynamics_with feedback
        % linearization.
        closed_loop_dynamics_grid
        % control used for closed loop
        us_closed_loop_grid
    end
    
    methods
        function obj = CompassWalker(varargin)
        %% dynsys = CompassWalker('gait_params', gait_params, key1, val1, key2, val2, ...)
        % keyword arguments:
        %   dims
        %   x: initial state
        %   event_type: type of the event(switching surface) (default:
        %       'foot')
        %   grid: if grid is provided, dynamics are precalculated and saved
        %       as a table.
        %   u_bound: bound of u (uMin, uMax) (default: [-4, 4])
        %   d_bound: bound of d (dMin, dMax) (default: [0, 0])
        %   freeze_dynamics: freeze the dynamics below the switching
        %       surface (default: false)
        %   reset_q1_threshold: For event_type 'foot' option, only when q1
        %       < reset_q1_threshold, the switching surface is active.
        
            necessary_var_keys = {'gait_params'};
            %% keywords that need default values
            default_var_keys = {'dims', 'x', 'event_type', 'grid', ...
                'u_bound', 'd_bound', 'eps', ...
                'freeze_dynamics', 'run_closed_loop', 'reset_q1_threshold', ...
                'Kp', 'Kd'};
            %% default values for keyword arguments.
            dims_default = 1:4;
            load(obj.default_ref_traj_file_name, 'x_opt_star')
            x = get_init_condition_from_opt_var(x_opt_star);
            x_default = x([3, 4, 7, 8]);
            event_type_default = 'foot';
            u_bound_default = [-4, 4];
            d_bound_default = [0.0, 0.0];
%             d_bound_default = [-0.3, 0.75];
%            eps_default = 0.1;
            eps_default = 0.1;
            freeze_dynamics_default = false;
            run_closed_loop_default = false;
            reset_q1_threshold_default = -0.03;
            Kp_default = 10;
            Kd_default = 1;
            default_var_values = {dims_default, x_default, event_type_default, [], ...
                u_bound_default, d_bound_default, eps_default, ...
                freeze_dynamics_default, run_closed_loop_default, reset_q1_threshold_default, ...
                Kp_default, Kd_default};
            kwargs = parse_function_args_full(necessary_var_keys, ...
                default_var_keys, default_var_values, varargin{:});
            obj.nu = 1;
            obj.nd = 1;
            
            obj.gait_params = kwargs.gait_params;            
            obj.eps = kwargs.eps;
            obj.control_params.beta = obj.gait_params(1:4);
            obj.control_params.th1d = obj.gait_params(5);
            obj.control_params.eps = obj.eps;
%             Kp = kwargs.Kp;
%             Kd = kwargs.Kd;
            A = [0, 1; 0, 0]; B = [0;1];
%             K = lqr(A, B, [1, 0; 0, 2], 0.32); % settings for eps = 0.1;
            K = lqr(A, B, [1, 0; 0, 2], 0.42); % settings for eps = 0.09;            
%             K = lqr(A, B, [1, 0; 0, 1.5], 0.3); % settings for eps = 0.1, clf_rate;            
            K = lqr(A, B, [1, 0; 0, 2.5], 0.1); % settings for eps = 0.09;            
            % TODO: Use this (P!!!) for the final submission result:
%             Q = [1, 0; 0, 0.1];
%             [K, P] = lqr(A, B, Q, 0.005); % settings for eps = 0.09;            
            
            Kp = K(1);
            Kd = K(2);
            A = [0, 1;
                -Kp, -Kd];
            Q = eye(2);
            P = lyap(A', Q); % A'P+PA=Q, find P
            obj.control_params.P = P;
            obj.control_params.clf.rate = ...
               min(eig(Q))/max(eig(P))/obj.eps;            
            fprintf("Setting clf rate automatically to %.3f \n", ...
                obj.control_params.clf.rate);           
            
            obj.uMin = kwargs.u_bound(1);
            obj.uMax = kwargs.u_bound(2);
            obj.dMin = kwargs.d_bound(1);
            obj.dMax = kwargs.d_bound(2);
                        
            obj.x = kwargs.x;
            obj.dims = kwargs.dims;
            obj.nx = length(obj.dims);
            obj.freeze_dynamics = kwargs.freeze_dynamics;
            obj.run_closed_loop = kwargs.run_closed_loop;
            obj.event_type = kwargs.event_type;
            obj.grid = kwargs.grid;
            obj.reset_q1_threshold = kwargs.reset_q1_threshold;
            if ~isempty(obj.grid)
                disp("grid is provided. Precomputing the vector fields for the grid points..");
                obj.precompute_vector_fields();
            end
        end
    end
end
