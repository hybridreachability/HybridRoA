function dx = two_link_dynamics(t, x, params)
    q = x(1:4);
    dq = x(5:8);
    u = two_link_io_control_clf_qp(x, params);        
    dx = fvec_gen(x) + gvec_gen(x)*u;
end