clear all
visualize = true;
save_video = false;
save_figures = false;
% reset_map_nonlinear_factor to visualize
thetas_to_visualize = -pi:pi/12:11*pi/12;
alphas = [0.1, 0.5, 1.0, 1.5, 100]; 

main_file_str = 'data_with_reset_map_';
main_t_str = 't_6_3';
save_dir = 'data/';

% grid sizes used to convert to the original coordinate.
M = 70;
M_angle = 60;
N = [2*M+1, M+1, 2*M_angle];

theta_slices = -pi:pi/12:11*pi/12; % Don't change this.
for alpha = alphas
    fprintf("Preprocessing alpha = %.2f\n", alpha);
    if exist(strcat(main_file_str, 'alpha_', num2str(100*alpha), '_', main_t_str, '_2D.mat'), 'file')
        disp("2D data file for alpha exists.")
    elseif ~exist(strcat(main_file_str, 'alpha_', num2str(100*alpha), '_', main_t_str, '.mat'), 'file')
        error("3D data file for alpha does not exist. Cannot proceed.");
    else
        load(strcat(main_file_str, 'alpha_', num2str(100*alpha), '_', main_t_str, '.mat'));
        %% Precalculation of slice of value function at initial state and the periodic orbit.
        x_max = 10 * params.R;
        grid_min = [-x_max; 0; -pi];
        grid_max = [x_max; x_max; pi];
        grid_original = createGrid(grid_min, grid_max, N, 3);    
        grid2D_original = createGrid(grid_min(1:2), grid_max(1:2), [2*M+1, M+1]);
        xs_orbit = get_hybrid_orbit(params); 
        disp("Converting to 2D data in the original coordinate system.");
        data_2D = convert_data_2D_modified_to_original(...
            squeeze(data(:, :, :, end)), grid, grid_original, theta_slices, params);
        data_2D_file_str = strcat(save_dir, ...
            main_file_str, 'alpha_', num2str(100*alpha), '_', main_t_str, '_2D');
        save(data_2D_file_str, 'grid2D_original', 'data_2D');
    end
end

if visualize
    create_brt_visualizations(alphas, thetas_to_visualize, ...
        save_video, save_figures, ...
        [], main_file_str, main_t_str);
end