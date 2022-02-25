function dx = dynamics(obj, ~, x, u, ~)
% State:    x_1 = \bar{r} (r - R), r is the first polar coord. of the car
%           x_2 = alpha, the 2nd polar coord of the car.
%           x_3 = theta, heading of the car
if iscell(x)
    dx = cell(length(obj.dims), 1);    
    for i = 1:length(obj.dims)
        dx{i} = dynamics_cell_helper(obj, x, u, obj.dims(i));
    end
    %% Stopping condition
    idx_not_freeze = (sin(x{2}) > 0);
    for i = 1:length(obj.dims)
        dx{i} = dx{i} .* (idx_not_freeze);
    end       
else
    dx = zeros(obj.nx, 1);
    dx(1) = obj.v * cos(x(2) - x(3));
    dx(2) = obj.v * sin(x(3) - x(2)) / (x(1) + obj.R);
    dx(3) = u;
end

end


function dx = dynamics_cell_helper(obj, x, u, dim)
switch dim
    case 1
        dx = obj.v * cos(x{obj.dims==2} - x{obj.dims==3});
    case 2
        dx = obj.v * sin(x{obj.dims==3} - x{obj.dims==2}) ./ (x{obj.dims==1} + obj.R);
    case 3
        dx = u;
    otherwise
        error("Dimension index not defined.")
end
end