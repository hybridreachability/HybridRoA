function derivs = get_sparse_derivs_from_total(grid, data, tau, ttr_sparse)
dt = tau(2) - tau(1);
t_max = tau(end);
derivs = cell(4, 1);
for j = 1:4
    derivs{j} = zeros(grid.N');
end

for i = 1:length(tau)
    fprintf("Processing %d-th index of total %d timesteps.\n", ...
        [i, length(tau)]);
    t_i = tau(i);
    data_i = squeeze(data(:, :, :, :, i));
    derivs_i = computeGradients(grid, data_i);
    if i < length(tau)
        derivs_i_mask = (ttr_sparse == t_i);
    else
        derivs_i_mask = (ttr_sparse >= t_max);
    end
    
    for j = 1:4
        derivs{j}(derivs_i_mask) = derivs_i{j}(derivs_i_mask);
    end
end

end