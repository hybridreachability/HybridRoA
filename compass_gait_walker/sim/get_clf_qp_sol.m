function mu = get_clf_qp_sol(x, params)
%% CLF-QP (with Feedback linearization) without input constraint.
    y = y_gen(x, params.beta,params.th1d);
    dy = Lfy_gen(x,params.beta,params.th1d);
    LgLfy = LgLfy_gen(x,params.beta,params.th1d);
    Lf2y = Lf2y_gen(x,params.beta,params.th1d);
    
    V = clf_FL(y, dy, params);
    LfV = lF_clf_FL(y, dy, params);
    LgV = lG_clf_FL(y, dy, params);
        
    inv_LgLfy = inv(LgLfy);
    u_star = -LgLfy\Lf2y; %feedforward term
    %% Decision variables (obj.udim)
    %%      1-udim: \mu
    A = [LgV];
    b = [-LfV - params.clf.rate * V];

    %% Analytical solution.
    if A == 0
        mu = 0;
    elseif A > 0
        if b < 0
            mu = b / A;
        else
            mu = 0;
        end
    else
        if b > 0
            mu = 0;
        else
            mu = b / A;
        end
    end                           
end

function V = clf_FL(y, dy, params)
    eta_eps = [(1/params.eps)*y; dy];    
    V = transpose(eta_eps)*params.P*eta_eps;
end

function lF_clf_ = lF_clf_FL(y, dy, params)
    F_FL_eps = [zeros(1), 1/params.eps * eye(1);
        zeros(1), zeros(1)];
    eta_eps = [(1/params.eps)*y; dy];
    lF_clf_ = transpose(eta_eps) * ...
        (transpose(F_FL_eps) * params.P + params.P * F_FL_eps) * eta_eps;
end

function lG_clf_ = lG_clf_FL(y, dy, params)
    G_FL = [0;1];
    eta_eps = [(1/params.eps)*y; dy];
    lG_clf_ = (2 * (G_FL'*params.P) * eta_eps)';
end

