function xs_original = get_hybrid_orbit(params)
    R = params.R; v = params.v;
    dt = 0.01;
    ts = 0:dt:pi*R/v;
    thetas = v/R * ts;
    x = R * cos(thetas);
    y = R * sin(thetas);
    xs_original = [x; y; thetas];
end