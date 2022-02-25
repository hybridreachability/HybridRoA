function xs_original = convert_modified_to_original(xs_modified, params)
% Converting modified coordinates to original coordinates
% xs_modified: (n, 3) state history

rs = xs_modified(:, 1) + params.R;
alphas = xs_modified(:, 2);
thetas = xs_modified(:, 3);

p_xs = rs .* cos(alphas);
p_ys = rs .* sin(alphas);

xs_original = [p_xs, p_ys, thetas];
end