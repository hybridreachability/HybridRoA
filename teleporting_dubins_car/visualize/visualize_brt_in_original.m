clear all;
close all;
R = 2; M = 80;
%[data0, grid_original] = setup_target_original(R, M);
load('data0_periodic_orbit');
figure;
data0 = data0_original;
data0 = data0 - 0.03;

for ll =1:length(tau_interest)
    subplot(2, 3, ll);
    h_0 = visSetIm(grid_original, data0, 'b', 0);    
    h_0.FaceAlpha = 0.8;
    hold on;
    h = visSetIm(grid_original, squeeze(data_original(:, :, :, ll)), 'g', 0);
    h.FaceAlpha = 0.5;
    
    view(140,44) % view angle
    lighting phong % type of lighting
    c = camlight; % apply light
    c.Position = [20 -10 -5]; % set position of light source
        axis([-6 6 ...
    -6 6 ...
    grid_original.min(3) grid_original.max(3)]); % set axis bounds
%     axis([grid_original.min(1) grid_original.max(1)...
%     grid_original.min(2) grid_original.max(2)...
%     grid_original.min(3) grid_original.max(3)]); % set axis bounds
    title(strcat(strcat("BRT, t=-",num2str(tau_interest(ll))),"sec"));
    axis square % make axis square (looks cute)

    
    xlabel('x','interpreter','latex');
    ylabel('y','interpreter','latex');
    zlabel('$\theta$','interpreter','latex');   
    set(gca,'FontSize',15) % set font size
    set(gcf,'Color','w'); % make background white
    fig_sz = [18 9]; 
    plot_pos = [0 0 18 9];
    set(gcf, 'PaperPositionMode', 'manual');
    set(gcf, 'PaperUnits', 'inches');
    set(gcf, 'PaperSize', fig_sz);
    set(gcf, 'PaperPosition', plot_pos);
end