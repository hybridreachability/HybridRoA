%% Load grid and data
% load('target_binary_for_fmm_35.mat');
% grid = grid_full_pre;
% schemeData.grid = grid_full_pre;
load('grid_target_31_coarse.mat');
schemeData.grid = grid;

%% Player strategies
schemeData.uMode = 'min';
%% Dynamical systems
schemeData.dynSys = CompassWalker();

%% Computation settings.
schemeData.accuracy = 'medium';
% These are manually set for manual TTR postprocess.
schemeData.hamFunc = @genericHam;
schemeData.partialFunc = @genericPartial;
[schemeData.dissFunc, ~, schemeData.derivFunc] = ...
    getNumericalFuncs('global', schemeData.accuracy);

dt = 0.01;
t_max = 0.84;
N_max = ceil(t_max / dt);

main_file_str = 'result_compass_gait_grid31_coarse_no_freeze_';
load(strcat(main_file_str, 'total.mat'));
disp(tau_total)
t0 = 0;
for i = 1:N_max+1
    %% Postprocess for making the TTR table.
    %if tau_total(i) ~=0
    %    schemeData.ttrLast = schemeData.ttr;
    %else
    %    schemeData.ttrLast = ones(size(target_fun(:))).*inf;
    %end
    y = squeeze(data_total(:, :, :, :, i));
    y = y(:);
    [~, schemeData] = feval(@postTimestepTTR, tau_total(i), y, schemeData);
end
ttr = reshape(schemeData.ttr, grid.shape);
save(strcat(main_file_str, 'ttr.mat'), 'ttr', '-v7.3');

%% Visualization
visualize = true;

if visualize
for t = 0:dt:t_max
    figure(ceil(t/dt)+1)
    subplot(2, 1, 1)
    %% Level set in configuration space
    [grid2D , data_vis] = proj(grid,ttr(:, :, :, :),[0 0 1 1]);        
    h_d  = visSetIm(grid2D, data_vis, 'b', t);
%         h_d.FaceAlpha = 0.5;
    xlabel('q1');
    ylabel('q2');

    title(strcat(num2str(t),'sec level sets'));

    subplot(2, 1, 2)
    %% Level set in velocity space
    [grid2D , data_vis] = proj(grid,ttr(:, :, :, :),[1 1 0 0]);        
    h_d  = visSetIm(grid2D, data_vis, 'b', t);
    xlabel('dq1');
    ylabel('dq2');
    fig_main_name = 'fig_ttr_compass_gait_grid31_no_freeze_';
    fig_name = strcat(strcat(fig_main_name,num2str(ceil(t/dt))),'.fig');
    hgsave(fig_name);
end
end
