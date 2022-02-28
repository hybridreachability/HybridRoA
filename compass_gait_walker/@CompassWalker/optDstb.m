function dOpt = optDstb(obj, ~, x, deriv, dMode)
%% Input processing
if nargin < 5
  dMode = 'max';
end

if obj.run_closed_loop
    %% For closed loop, control is determined in dynamcis. optCtrl should not be used.
    if iscell(x)
        cell_size = size(x{1});
        dOpt = cell(1, 1);
        dOpt{1} = zeros(cell_size);
    else
        dOpt = 0;
    end
    return
end


if iscell(deriv)
    LgV = -(deriv{1} .* obj.gs_grid{1} .* obj.grid.xs{4} + deriv{2} .* obj.gs_grid{2} .* obj.grid.xs{4} ...
    + deriv{3} .* obj.gs_grid{3} .* obj.grid.xs{4} + deriv{4} .* obj.gs_grid{4} .* obj.grid.xs{4});
    if strcmp(dMode, 'min')
        dOpt_array = (LgV > 0) * obj.dMin + (LgV <= 0) * obj.dMax;
    elseif strcmp(dMode, 'max')
        dOpt_array = (LgV > 0) * obj.dMax + (LgV <= 0) * obj.dMin;
    else
        error("Unknown mode!");
    end
    dOpt = cell(1, 1);
    dOpt{1} = dOpt_array;
else
    % Single vector case
    deriv = deriv';
    LgV = deriv * squeeze(-obj.get_gvec(x) .* x(4));
    eps = 0.00;
    if strcmp(dMode, 'min')
        dOpt = (LgV > eps) * obj.dMin + (LgV < -eps) * obj.dMax; % 0 when LgV == 0, 0
    elseif strcmp(dMode, 'max')
        dOpt = (LgV > eps) * obj.dMax + (LgV < -eps) * obj.dMin; % 0 when LgV == 0, 0
    else
        error("Unknown mode!");
    end
end