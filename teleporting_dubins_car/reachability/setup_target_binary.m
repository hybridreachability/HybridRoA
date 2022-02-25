clear all
close all
R = 2;
M = 40;
grid_dx1 = 8 * R / (2 * M);
idx_0 = R / grid_dx1;
grid_min = [-R + grid_dx1; -pi; -pi];
grid_max = [-R + grid_dx1 * 2 * M; pi; pi];
N = [2*M, 2*M, 2*M]; % M/2 corresponds to pi/2 for 2nd&3rd axes
pdDims = [2 3];
grid = createGrid(grid_min, grid_max, N, pdDims);

%% Target set
% x1(bar_r) == 0, theta = alpha + pi/2
binary_target = ones(N);
for j = 1:2*M
    index_3rd = (mod(j+M/2, 2*M) > 0) * mod(j+M/2, 2*M) + (mod(j+M/2, 2*M) == 0) * (2*M);
    binary_target(idx_0, j, index_3rd) = -1;
end

figure;
[grid2D , target_vis] = proj(grid,binary_target,[1 0 0], 0);        
visSetIm(grid2D, target_vis, 'g', 0);
xlabel('$\alpha$','interpreter','latex');
ylabel('$\theta$','interpreter','latex');

% save('dubins_target_binary', 'grid', 'binary_target');