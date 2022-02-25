function x1 = updateStateWithResetMap(obj, u, T, x0, d)
% x1 = updateState(obj, u, T, x0, d)
% Updates state based on control
%
% Inputs:   obj - current quardotor object
%           u   - control (defaults to previous control)
%           T   - duration to hold control
%           x0  - initial state (defaults to current state if set to [])
%           d   - disturbance (defaults to [])
%
% Outputs:  x1  - final state
%
% Mo Chen, 2015-05-24

% If no state is specified, use current state
if nargin < 4 || isempty(x0)
  x0 = obj.x;
end

% If time horizon is 0, return initial state
if T == 0
  x1 = x0;
  return
end

% Default disturbance
if nargin < 5
  d = [];
end

% Do nothing if control is empty
if isempty(u)
  x1 = x0;
  return;
end

% convert u to vector if needed
if iscell(u)
  u = cell2mat(u);
end

% Do nothing if control is not a number
if isnan(u)
  warning('u = NaN')
  x1 = x0;
  return;
end

% Make sure control input is valid
if ~isnumeric(u)
  error('Control must be numeric!')
end

% Convert control to column vector if needed
if ~iscolumn(u)
  u = u';
end

% Check whether there's disturbance (this is needed since not all vehicle
% classes have dynamics that can handle disturbance)
odeOpts = odeset('Events', @(t,x)dubins_reset_map_event(t,x));
    
if isempty(d)
  [ts, x] = ode113(@(t,x) obj.dynamics(t, x, u), [0 T], x0, odeOpts);
else
  [~, x] = ode113(@(t,x) obj.dynamics(t, x, u, d), [0 T], x0, odeOpts);
end

% Update the state, state history, control, and control history
obj.u = u;

x1 = x(end, :)';
[value_end, ~, ~] = dubins_reset_map_event(ts(end), x1);
if value_end < 0
    % Apply reset map
    xPost = zeros(3, 1);
    if strcmp(obj.reset_map_type, 'identity')
        xPost(1) = x1(1);
    elseif strcmp(obj.reset_map_type, 'sqrt')
        xPost(1) = sqrt(obj.R * (x1(1) + obj.R)) - obj.R;
    elseif strcmp(obj.reset_map_type, 'diverge')
        xPost(1) = (x1(1) + obj.R)^1.5/sqrt(obj.R) - obj.R;
    elseif strcmp(obj.reset_map_type, 'parametrized')
        xPost(1) = obj.R * ((x1(1) + obj.R)/obj.R)^obj.params.alpha - obj.R;
    else
        error("reset_map_type not supported.")
    end
    
    if x1(2) <= 0
        xPost(2) = x1(2)+pi;
    else
        xPost(2) = x1(2) - pi;
    end
    
    if x1(3) <= 0
        xPost(3) = x1(3)+pi;
    else
        xPost(3) = x1(3) - pi;
    end
    obj.x = xPost;
else
    obj.x = x1;
end

obj.xhist = cat(2, obj.xhist, obj.x);
obj.uhist = cat(2, obj.uhist, u);
end