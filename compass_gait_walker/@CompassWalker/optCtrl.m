function uOpt = optCtrl(obj, ~, x, deriv, uMode)

if nargin < 5
    uMode = 'min';
end

if obj.run_closed_loop
    %% For closed loop, control is determined in dynamcis. optCtrl should not be used.
    if iscell(x)
        cell_size = size(x{1});
        uOpt = cell(1, 1);
        uOpt{1} = zeros(cell_size);
    else
        uOpt = 0;
    end
    return
end


%% For open loop, compute opt ctrl based on evaluating Hamiltonian.
if iscell(deriv)
    LgV = deriv{1} .* obj.gs_grid{1} + deriv{2} .* obj.gs_grid{2} ...
    + deriv{3} .* obj.gs_grid{3} + deriv{4} .* obj.gs_grid{4};
    if strcmp(uMode, 'min')
        uOpt_array = (LgV > 0) * obj.uMin + (LgV <= 0) * obj.uMax;
    elseif strcmp(uMode, 'max')
        uOpt_array = (LgV > 0) * obj.uMax + (LgV <= 0) * obj.uMin;
    else
        error("Unknown mode!");
    end
    uOpt = cell(obj.nu, 1);
    uOpt{1} = uOpt_array;
else
    % Single vector case
    deriv = deriv';
    LgV = deriv * squeeze(obj.get_gvec(x));
    eps = 0.00;
    if strcmp(uMode, 'min')
        uOpt = (LgV > eps) * obj.uMin + (LgV < -eps) * obj.uMax; % 0 when LgV == 0, 0
    elseif strcmp(uMode, 'max')
        uOpt = (LgV > eps) * obj.uMax + (LgV < -eps) * obj.uMin; % 0 when LgV == 0, 0
    else
        error("Unknown mode!");
    end
end