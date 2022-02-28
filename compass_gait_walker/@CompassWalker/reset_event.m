function [value,isterminal,direction] = reset_event(obj, t, x)

q1 = x(1);
if strcmp(obj.event_type, 'angle')
    value = q1 - obj.gait_params(5);
elseif strcmp(obj.event_type, 'foot')    
%     pSw_y = obj.lL * cos(x(1, :)) - obj.lL * cos(x(1, :)+x(2, :));
    if q1 < obj.reset_q1_threshold
      value = 2 * x(1) + x(2);
    else
      value = -0.001;
    end
else
    error("object event type undefined.");
end     

isterminal = 1;
direction = -1; 
end