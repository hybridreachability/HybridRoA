function ttr = get_sparse_ttr_from_total(grid, data, tau)
dt = tau(2) - tau(1);
t_max = tau(end);
ttr = inf * ones(grid.N');

for i = 1:length(tau)
    t_i = tau(i);
    data_i = squeeze(data(:, :, :, :, i));
    ttr(data_i <= 0) = min(ttr(data_i <= 0), t_i);
end