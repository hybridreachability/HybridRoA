function vis_value_function_reset_map(grid, xs_switching_surface, xs_post_assigned, gait, ...
    q1s, add_gait_bound_slices)
if nargin < 4
    gait =[];
end
if nargin < 5
    q1s = linspace(grid.min(1), grid.max(1), 6);
end

if nargin < 6
    add_gait_bound_slices = true;
end

if add_gait_bound_slices && ~isempty(gait)
    % Add start and end q1 of the reference gait and sort again.
    q1s = [q1s, gait(1, 1), gait(end, 1)];
    q1s = sort(q1s);
end

eps = 0.001;
n_q1s = length(q1s);
palette = get_palette_colors();
open_figure('size', 'full', 'font_size', 14);
for i = 1:n_q1s
    q1 = q1s(i);
    %% Plot the post-reset-map states (state on the switching surface) first.
    if (floor(n_q1s/2) == n_q1s/2)
        subplot(2, n_q1s/2, i);
    else
        subplot(1, n_q1s, i);
    end
    idx_pre_q1 = find(abs(squeeze(xs_switching_surface(1, :)) - q1) < eps);
    if ~isempty(idx_pre_q1)
        q2_switch = xs_switching_surface(2, idx_pre_q1);
        dq1_switch = xs_switching_surface(3, idx_pre_q1);
        dq2_switch = xs_switching_surface(4, idx_pre_q1);
        p_switch_surface = plot3(...
            q2_switch, dq1_switch, dq2_switch, 'o');
        p_switch_surface.MarkerFaceColor = palette.magenta;
        p_switch_surface.MarkerEdgeColor = 'none';
        p_switch_surface.MarkerSize = 2;
        hold on;
    end
    
    idx_post_q1 = find(abs(squeeze(xs_post_assigned(1, :)) - q1) < eps);
    if ~isempty(idx_post_q1)
            q2_post = xs_post_assigned(2, idx_post_q1);
        dq1_post = xs_post_assigned(3, idx_post_q1);
        dq2_post = xs_post_assigned(4, idx_post_q1);
        p_post_reset = plot3(...
            q2_post, dq1_post, dq2_post, 'o');
        p_post_reset.MarkerFaceColor =  palette.orange;
        p_post_reset.MarkerEdgeColor = 'none';
        p_post_reset.MarkerSize = 2;
%         hold on;
    end
    
    xlabel('$q_2$');
    ylabel('$\dot{q}_{1}$');
    zlabel('$\dot{q}_{2}$');
    title(strcat('$q_1=$', num2str(q1)));
    view(38.5, 27);
end
