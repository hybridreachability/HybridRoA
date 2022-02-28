function u = two_link_io_control_nonlinear_feedback(x, params, u_bound)
if nargin < 3
    u_bound = [];
end
% Ayush Agrawal
% ME 193B/292B: Feedback control of Legged Robots, Fall 2019
% HW5
% last update: 10/22/19  
    y = y_gen(x, params.beta,params.th1d);
    dy = Lfy_gen(x,params.beta,params.th1d);
    LgLfy = LgLfy_gen(x,params.beta,params.th1d);
    Lf2y = Lf2y_gen(x,params.beta,params.th1d);
    y1 = y(1);
    dy1 = dy(1);
    
    e = params.eps;
    v = [psia_gen(y1, e*dy1);
         ]./e^2;
     
    u = inv(LgLfy)*(-Lf2y + v);
    if ~isempty(u_bound)
        u = min(u, u_bound);
        u = max(u, -u_bound);
    end
end