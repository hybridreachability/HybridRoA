clear all
close all

params.v = 1;
params.R = 2;
params.u_bound = 1;

% Load target set and grid
load('dubins_target_binary_hybrid')
target_function = load_target_function_from_h5('dubins_target_hybrid_fmm.h5');

schemeData.grid = grid;

schemeData.uMode = 'min';

schemeData.dynSys = ModifiedDubinsCar([], [], params);
% schemeData.dynSys = FreezeDubinsCar([], [], params);


schemeData.accuracy = 'high';
schemeData.hamFunc = @genericHam;
schemeData.partialFunc = @genericPartial;
[schemeData.dissFunc, ~, schemeData.derivFunc] = ...
    getNumericalFuncs('global', schemeData.accuracy);


HJIextraArgs.stopConverge = 1;

HJIextraArgs.targetFunction = target_function;

HJIextraArgs.visualize.valueSet = 1;
HJIextraArgs.visualize.initialValueSet = 1;
HJIextraArgs.visualize.figNum = 1; %set figure number
HJIextraArgs.visualize.deleteLastPlot = true; %delete previous plot as you update

t0 = 0;
dt = 0.1;
t_max = 0.1;
tau = t0:dt:t_max;
data0 = target_function;
reset_map_type = "parametrized"; % options: "identity", "sqrt", "diverge", "parametrized"

alphas = [0.4, 0.5, 0.6, 1.0, 1.4, 1.5, 1.6, 1.75]; % reset_map_nonlinear_factor
for alpha=alphas
    % Update reset map
    params.reset_map_nonlinear_factor = alpha;
    reset_map = get_reset_map(grid, params, reset_map_type);
    schemeData.reset_map = reset_map;
    % Update value function computation.
    [data, tau, extraOuts] = ...
        HJIPDE_solve_with_reset_map(data0, tau, schemeData, 'minVWithL', HJIextraArgs);
    % Data_file_name
    data_file_str = strcat('data_with_reset_map_alpha_', num2str(100*alpha));
    data_file_str = strcat(data_file_str, '_t_');
    data_file_str = strcat(data_file_str, num2str(t_max));
    save(strcat(data_file_str, '.mat'), 'grid', 'data0', 'params', 'data', 'tau');
end

function target_function = load_target_function_from_h5(file_name)
fid = H5F.open(file_name);
dset_id = H5D.open(fid,'data');
target_function = permute(H5D.read(dset_id), [3, 2, 1]);
end