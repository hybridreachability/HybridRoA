function on_surface = check_on_switching_surface(x0, reset_type, reset_q1_threshold)
if nargin < 2
    reset_type = 'foot';
end
if nargin < 3
    reset_q1_threshold = -0.03;
end

if length(x0) == 4
    % condensed coordinate
    q1 = x0(1); q2 = x0(2);
    dq1 = x0(3); dq2 = x0(4);
elseif length(x0) == 8
    q1 = x0(3); q2 = x0(4);
    dq1 = x0(7); dq2 = x0(8);    
else
    error("wrong size.");
end
    
if q1 < reset_q1_threshold && q2 == -2 * q1 && 2 * dq1 + dq2 <= 0
    on_surface = true;
else
    on_surface = false;
end
