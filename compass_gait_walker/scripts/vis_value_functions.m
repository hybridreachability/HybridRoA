% close all; clear all;
main_file_id_str = 'result_ral_main_';

% save file settings.
t_terminal = 1.5; % If empty, uses total.
plot_3d = false;
plot_target_figures = true;
save_target_figures = false;
save_brt_figures = false;
color_option = 'mono'; % 'value': color encodes value. 'mono': use single cplor.
save_format = 'pdf';
fig_name_main = strcat('fig_', main_file_id_str);

grid_file_str = strcat(main_file_id_str, 'grid');
gait_file_str = strcat(main_file_id_str, 'gait');
target_function_file_str = strcat(main_file_id_str, 'target');
load(grid_file_str, 'grid');
load(gait_file_str, 'gait_params', 'gait');
load(target_function_file_str, 'target_function');

if isempty(t_terminal)
    value_function_file_str = strcat(main_file_id_str, 'total.mat');
    load(value_function_file_str, 'data_total', 'tau_total');
    data = data_total;
    t_terminal = tau_total(end);
    t_str = num2str(1000*t_termianl);
else
    t_str =  num2str(1000*t_terminal);
    value_function_file_str = strcat(main_file_id_str, t_str, '.mat');
    load(value_function_file_str, 'data');
end    

value_function = squeeze(data(:, :, :, :, end));

if plot_target_figures
    fig_2d_target = vis_level_set_2d(grid, target_function, 'gait', gait, 'color_option', color_option);
    if save_target_figures
        save_figure(fig_2d_target, 'file_name', strcat(fig_name_main, 'target2d'), ...
            'file_format', save_format);
    end
end

fig_2d_value = vis_level_set_2d(grid, value_function, 'gait', gait, 'color_option', color_option, 'level', 0);
fig_2d_value_new = vis_level_set_2d_new(grid, value_function, 'gait', gait, 'color_option', color_option, 'level', 0);

if save_brt_figures
    save_figure(fig_2d_value, 'file_name', strcat(fig_name_main, 'brt_T_', t_str, '_2d'), ...
        'file_format', save_format);
    save_figure(fig_2d_value_new, 'file_name', strcat(fig_name_main, 'brt_T_', t_str, '_2d_for_paper'), ...
        'file_format', save_format, 'figure_size', [4, 6]);
end

if plot_3d
    if plot_target_figures
        fig_3d_target = vis_level_set_3d(grid, target_function, gait, 0, 'foot', -0.15:0.06:0.15);
        if save_target_figures
            save_figure(fig_3d_target, 'file_name', strcat(fig_name_main, 'target3d'), ...
                'file_format', save_format);
        end
    end
    fig_3d_value = vis_level_set_3d(grid, value_function, gait, 0, 'foot', -0.15:0.06:0.15);

    if save_brt_figures
        save_figure(fig_3d_value, 'file_name', strcat(fig_name_main, 'brt_T_', t_str, '_3d'), ...
            'file_format', save_format);
        save_figure(fig_3d_value, 'file_name', strcat(fig_name_main, 'brt_T_', t_str, '_3d'));
    end
end