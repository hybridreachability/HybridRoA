function [value,isterminal,direction] = two_link_event(t, x, params, event_type)
if nargin < 4
    event_type  = 'foot';
end

q1 = x(3);
reset_q1_threshold = -0.03;
if strcmp(event_type, 'angle')
    value = q1 - params.th1d;
elseif strcmp(event_type, 'foot')
%     pSw = pSw_gen(x(1:4));
    if q1< reset_q1_threshold
      value= 2 * x(3) + x(4);
    else
      value=-0.001;
    end
else
    error("event type undefined.");
end        

isterminal = 1;
direction = -1; 
end