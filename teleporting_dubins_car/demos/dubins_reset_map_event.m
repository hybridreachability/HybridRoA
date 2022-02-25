function [value, isterminal, direction] = dubins_reset_map_event(t, x)

if sin(x(2)) < 0 && sin(x(3)) < 0
    value = -1;
else
    value = 1;
end

isterminal = 1;
direction = 1;
end