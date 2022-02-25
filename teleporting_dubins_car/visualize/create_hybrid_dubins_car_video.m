function create_hybrid_dubins_car_video(ts, xs, params, video_name)

if nargin < 4
    video_name = ...
        [datestr(now,'YYYYMMDD_hhmmss') '.mp4'];
end
dt = ts(2) - ts(1);

% Color setting.
magenta = [0.937, 0.004, 0.584];
blue = [0.106, 0.588, 0.953];
green = 0.01 * [4.3, 69.4, 63.9];
grey = 0.01 *[19.6, 18.8, 19.2];
orange = [0.965, 0.529, 0.255];
yellow = [0.998, 0.875, 0.529];
navy = [0.063, 0.075, 0.227];
lime = 0.01 * [85.9, 94.9, 4.7];
white = [1.0, 1.0, 1.0];

flame_w = 0.01 * [98.4, 98.4, 83.1];
flame_o = 0.01 * [97.6, 62.4, 19.2];
flame_r = 0.01 * [84.7, 22.7, 14.1];

x_max = 15;
% Open figure
f = figure;
clf
set(gcf, 'Units','pixels','Position', [20 20 760, 460], 'Color', 'k');
set(gca,'Units','pixels','Position',[20 20 720 420], 'Color', 'k', 'XColor', [1.0, 1.0, 1.0], 'YColor', [1.0, 1.0, 1.0]);
xlim([-x_max, x_max]);
axis equal

% Open video writer
vout = VideoWriter(video_name,'MPEG-4');
vout.Quality = 100;
vout.FrameRate = 1/dt;
vout.open;

% Background
% r = rectangle('Position', [-6, -1, 12, 1]); hold on;
% r.FaceColor = [0., 0., 0.];
r = rectangle('Position', [-x_max, 0, 2 * x_max, x_max]); hold on;
r.FaceColor = navy;
drawShadedRectangle([-x_max, x_max],[0 2 * x_max / 3],flame_w, flame_w, flame_o, 0.2, 0.1, 0);

% Draw the level set and orbit
xs_orbit = get_hybrid_orbit(params); hold on;
plot(xs_orbit(1, :), xs_orbit(2, :), 'Color', blue);
xlabel('x','interpreter','latex');
ylabel('y','interpreter','latex');
set(gca,'FontSize',15);

car_width = 0.4;
car_length = 0.2;

max_trace_length = floor(3/dt);

% Main for loop
for iter=1:length(ts)
    time_color_map = [linspace(flame_r(1), white(1), min(iter, max_trace_length))', ...
    linspace(flame_r(2), white(2), min(iter, max_trace_length))', ...
    linspace(flame_r(3), white(3), min(iter, max_trace_length))'];
    s = scatter(xs(1, max(1, iter+1 - max_trace_length):iter), ...
        xs(2, max(1, iter+1 - max_trace_length):iter), 13, time_color_map, 'filled'); hold on;
    s.MarkerFaceAlpha = 'flat';
    s.AlphaData = linspace(0.0, 1.0, min(iter, max_trace_length));

    car = polyshape([-0.5*car_width, 0.5*car_width, 0.5*car_width, -0.5*car_width], ...
        [-0.5*car_length, -0.5*car_length, 0.5*car_length, 0.5*car_length]);    
    car = rotate(car, rad2deg(xs(3, iter)));
    car = translate(car,xs(1, iter),xs(2, iter));
    carplot = plot(car, 'FaceColor', magenta, 'LineStyle', 'none', 'FaceAlpha', 1.0);
    
    r = rectangle('Position', [-x_max, -1, 2 * x_max, 1]);
    r.FaceColor = [0.0, 0.0, 0.0];
    h_shade_up = drawShadedRectangle([-x_max, x_max],[0 0.2],flame_w, flame_o, flame_r);
    h_shade_down = drawShadedRectangle([-x_max, x_max],[0 -0.05],flame_w, flame_o, flame_o);
    drawnow
    current_frame = getframe(gcf); %gca does just the plot
    writeVideo(vout,current_frame);
    pause(0.05)
    delete(h_shade_up)
    delete(h_shade_down)    
    delete(carplot)
    delete(s);
end % end of main for loop
vout.close
