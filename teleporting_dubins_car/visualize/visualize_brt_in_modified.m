% clear all;
% close all;
load('data_target_orbit_modified_t15');
tau_interest = [21, 41, 61, 81, 101, 121];
data0 = load_target_function_from_h5_dubins('data0_orbit_modified_fmm.h5');
figure;
for ll =1:length(tau_interest)
    subplot(2, 3, ll);
    h_0 = visSetIm(grid, data0, 'b', 0);    
    h_0.FaceAlpha = 0.5;
    hold on;
    h = visSetIm(grid, squeeze(data(:, :, :, tau_interest(ll))), 'g', 0);
    h.FaceAlpha = 0.7;
    
    view(140,44) % view angle
    lighting phong % type of lighting
    c = camlight; % apply light
    c.Position = [20 -10 -5]; % set position of light source
    axis([grid.min(1) grid.max(1)...
    grid.min(2) grid.max(2)...
    grid.min(3) grid.max(3)]); % set axis bounds
    title(strcat(strcat("BRT, t=-",num2str(tau(tau_interest(ll)))),"sec"));
    axis square % make axis square (looks cute)

    
    xlabel('$\bar{r}$','interpreter','latex');
    ylabel('$\alpha$','interpreter','latex');
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