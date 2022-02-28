function plot_main_state_history_tilde(tRec, xRec_tilde, fig_name)

if nargin < 3
    save_file = false;
else
    save_file = true;
end

figure
subplot(4, 1, 1)
plot(tRec, xRec_tilde(:, 3), 'r', 'LineWidth', 2)
ylabel('y')
grid on
subplot(4, 1, 2)
plot(tRec, xRec_tilde(:, 4), 'r', 'LineWidth', 2)
ylabel('q1')
grid on
subplot(4, 1, 3)
plot(tRec, xRec_tilde(:, 7), 'r', 'LineWidth', 2);
ylabel('ydot')
grid on
subplot(4, 1, 4)
plot(tRec, xRec_tilde(:, 8), 'r', 'LineWidth', 2);
ylabel('q1dot')
grid on

if save_file
    hgsave(fig_name);
end