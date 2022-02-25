function xs_modified = convert_original_to_modified(xs_original, params)
% Converting modified coordinates to original coordinates
% xs_modified: (n, 3) state history

rs_bar = sqrt(xs_original(:, 1).^2 + xs_original(:, 2).^2) - params.R;
alphas = atan2(xs_original(:, 2), xs_original(:, 1));
thetas = xs_original(:, 3);

xs_modified = [rs_bar, alphas, thetas];
end