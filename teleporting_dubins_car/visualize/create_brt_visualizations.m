function create_brt_visualizations(alphas, theta_to_vis, ...
    in_video, save_figures, ...
    params, ...
    main_file_str, main_t_str, save_dir)
if nargin < 1
    alphas = [0.5, 1.0, 1.5];
    % alphas = [0.1, 0.25, 0.5, 0.75, 0.9, 1.0, 1.1, 1.25, 1.5, 1.75, 2.0, 2.5, 3.0, 4.0, 100]; % reset_map_nonlinear_factor
end
if nargin < 2
    theta_to_vis = -pi:pi/12:11*pi/12;
end
if nargin < 3
    in_video = false;
end
if nargin < 4
    save_results = true;
end
if nargin < 6
    main_file_str = 'data_with_reset_map_';
end
if nargin < 7
    main_t_str = 't_6_3';
end
if nargin < 8
    save_dir = 'results/with_reset_map/brts/';
end
if nargin < 5 || isempty(params)
    load(strcat(main_file_str, 'alpha_', num2str(100*alphas(1)), '_', main_t_str, '.mat'), ...
        'params');
end

x_max = 10 * params.R;
xs_orbit = get_hybrid_orbit(params); 
theta_slices = -pi:pi/12:11*pi/12; % do not change this.

palette = get_palette_colors();
orange = palette.orange;
blue = palette.blue;
green = palette.green;
yellow = palette.yellow;
yellow2 = 0.9 * yellow;
color_map = get_color_map([blue; green; yellow2; orange], length(alphas)-1);
line_width = linspace(3.0, 1.5, length(alphas));
for i=1:length(theta_to_vis)
    open_figure('size', [1200, 400]);
    theta = theta_to_vis(i);
    file_theta_index = find(theta_slices==theta);
    if isempty(file_theta_index)
        error("chosen theta cannot be visualized.");
    end
    for j = 1:length(alphas)
        alpha = alphas(j);
        load_file_str = strcat(main_file_str, ...
            'alpha_', num2str(100*alphas(j)), ...
            '_', main_t_str, '_2D.mat');
        load(load_file_str, 'data_2D', 'grid2D_original');
        %% If you want to fill in the contour, you have to use this code.
        %% But this only works for single alpha.
%             [M, c] = contourf(grid2D_original.xs{1}, grid2D_original.xs{2}, -squeeze(data_2D(:, :, i)), [0, 0], 'w');
%             colormap(orange);
%             M.FaceAlpha = 0.5;
%             set(M, 'Renderer', 'OpenGL');
%             alphable = findobj(c, '-property', 'FaceAlpha');
%             set(alphable, 'FaceAlpha',0.5);
%             set(alphable, 'FaceColor', blue);
%             hold on;

        h = visSetIm(grid2D_original, squeeze(data_2D(:, :, file_theta_index)), ...
            color_map(j, :), 0); hold on;
        h.LineWidth = line_width(j);
        h.DisplayName = strcat('$\alpha=',num2str(alpha), '$');
        if alpha == 100
            h.DisplayName = 'freeze';
            h.LineStyle = '--';
        end
    end
    hold on
    plot(xs_orbit(1, :), xs_orbit(2, :), 'b-.', 'DisplayName', 'orbit', 'LineWidth', 2);
    hold off;
    axis equal
    xlim([-x_max, x_max]);
    ylim([0, 10]);
    grid on

    hl = legend('show');
    set(hl, 'Interpreter', 'latex');

    xlabel('$p_x$','interpreter','latex');
    ylabel('$p_y$','interpreter','latex');
    title(strcat('$\theta=$',num2str(theta)), 'interpreter', 'latex');
    set(gca,'FontSize',15);

    if save_figures
        plot_name_str = strcat(save_dir, main_t_str, '/plot_brt_',int2str(file_theta_index));
        save_figure(gcf, 'figure_size', [6, 2], 'file_name', plot_name_str, 'file_format', 'pdf');
        save_figure(gcf, 'figure_size', [6, 2], 'file_name', plot_name_str, 'file_format', 'fig');            
    end
end
if in_video
   %% save in video format    
    for i=1:length(theta_to_vis)
        if in_video
            videoFilename = strcat(save_dir, main_t_str, '/plot_in_video_brt_', ...
            int2str(file_theta_index));
            vout = VideoWriter(videoFilename,'MPEG-4');
            vout.Quality = 100;
            vout.FrameRate = 5;
            vout.open;
        end

        fig = open_figure('size', [1200, 400]);
        theta = theta_to_vis(i);
        file_theta_index = find(theta_slices==theta);
        if isempty(file_theta_index)
            error("chosen theta cannot be visualized.");
        end
        for j = 1:length(alphas)
            plot(xs_orbit(1, :), xs_orbit(2, :), 'b-.', 'DisplayName', 'orbit', 'LineWidth', 2);
            hold on;
            alpha = alphas(j);
            load_file_str = strcat(main_file_str, ...
                'alpha_', num2str(100*alphas(j)), ...
                '_', main_t_str, '_2D.mat');
            load(load_file_str, 'data_2D', 'grid2D_original');
            h = visSetIm(grid2D_original, squeeze(data_2D(:, :, file_theta_index)), ...
                color_map(j, :), 0);
            h.LineWidth = line_width(j);
            h.DisplayName = strcat('$\alpha=',num2str(alpha), '$');
            if alpha == 100
                h.DisplayName = 'freeze';
                h.LineStyle = '--';
            end
            hold off;
            axis equal
            xlim([-x_max, x_max]);
            ylim([0, 10]);
            grid on

            hl = legend('show');
            set(hl, 'Interpreter', 'latex');

            xlabel('$p_x$','interpreter','latex');
            ylabel('$p_y$','interpreter','latex');
            title(strcat('$\theta=$',num2str(theta)), 'interpreter', 'latex');
            set(gca,'FontSize',15);
            current_frame = getframe(gcf); %gca does just the plot
            writeVideo(vout,current_frame);
        end
        vout.close;
    end 
end