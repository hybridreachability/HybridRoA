close all;
clear all;
save_figures = false;
load ('gait_from_clf_qp_ral.mat', 'xRec');
gait = xRec(:, [3, 4, 7, 8]);
load('x_opt_star_ral.mat', 'x_opt_star')


%% Setting up the initial state and the gait parameter.
eps = 0;
init_angle_perturb = 0.5 * eps;
x_opt_star_perturbed = x_opt_star;
x_opt_star_perturbed(1) = x_opt_star_perturbed(1) + init_angle_perturb;
x_opt_star_perturbed(2) = x_opt_star_perturbed(2) - init_angle_perturb;

x0 = get_init_condition_from_opt_var(x_opt_star_perturbed);
x0d = get_init_condition_from_opt_var(x_opt_star);
beta = get_beta_from_opt_var(x_opt_star);
th1d = -x0d(3);
gait_params = [beta;th1d];
% Making sure that the initial state satisfies the kinematic constraint of
% the stance foot.
x0(5) = -cos(x0(3))*x0(7);
x0(6) = -sin(x0(3))*x0(7);

%% If you want to test a custom initial state, set it here.
% q0 = [0.2860; -0.052];
% dq0 = [-0.5; 3.8];
% x0_condensed = [q0; dq0];
% x0 = convert_condensed_states_to_full_states(x0_condensed')';

num_steps = 4;
% Options:
% 'vanilla': use two_link_dynamics.m to run simulation.
% 'vanilla_class': use CompassWalker.dynamics to run simulation.
sim_option = 'vanilla_class';
% Options:
% 'angle': Reset is defined as q1 reaching q1_desired.
% 'foot': Reset is defined as foot position reaching the ground (y=0);
sim_event_option = 'foot';

[xRec, fRec, uRec, tRec, xRec_tilde] = two_link_simulate(x0, ...
    beta, num_steps, th1d, sim_option, sim_event_option);
fig_name_main = 'fig_plot_io_compare_';

if save_figures
    plot_main_state_history(tRec, xRec, ...
        'fig_name', strcat(fig_name_main, 'state'));
    plot_main_control_history(tRec, uRec, ...
        'fig_name', strcat(fig_name_main, 'control'));
    plot_main_contact_history(tRec, fRec);
    plot_main_output(tRec, xRec, ...
        'gait_params', gait_params, 'fig_name', strcat(fig_name_main, 'output'));
    plot_main_phase_plot(tRec, xRec, [], ...
        'gait', gait, ...
        'fig_name', strcat(fig_name_main, 'phase'));  
else
    plot_main_state_history(tRec, xRec);
    plot_main_control_history(tRec, uRec);   
    plot_main_contact_history(tRec, fRec);    
    plot_main_output(tRec, xRec, 'gait_params', gait_params);
    plot_main_phase_plot(tRec, xRec, [], 'gait', gait);
end

%% Uncomment it to run the animation.
% animateTwoLink(tRec, xRec);