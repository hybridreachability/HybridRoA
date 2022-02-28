function u_d = convert_disturbance_to_control(obj, x, d)
    beta = obj.control_params.beta;
    th1d = obj.control_params.th1d;
    y = y_gen(x, beta, th1d);
    dy = Lfy_gen(x, beta, th1d);
    LgLfy = LgLfy_gen(x, beta, th1d);
    
    v_disturbance = d(1) * y + d(2) * dy;
    u_d = inv(LgLfy)*(v_disturbance);
end