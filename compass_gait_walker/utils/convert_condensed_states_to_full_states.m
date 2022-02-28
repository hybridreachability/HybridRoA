function xs_full = convert_condensed_states_to_full_states(xs_condensed, init_stance_position)
%% Conversion from 4D state representation to Full (8D) state representation
% Inputs:   xs_condensed: N * 4 history of state
%           reset_indices: indices at which reset map is applied
%           init_stance_position: initial position (x, y) of the stance
%           foot.           
% WARNING: If reset map is applied among xs_condensed, positions
% (xs_full(:,1:2)) will not be able to capture this. (TODO)
if nargin < 2
    init_stance_position = [0; 0];
end
xs_full = zeros(size(xs_condensed, 1), 8);
xs_full(:, [3, 4, 7, 8]) = xs_condensed;
for i =1:size(xs_condensed, 1)        
    xs_full(i, [1, 2]) = [init_stance_position(1)-sin(xs_condensed(i, 1));
        init_stance_position(2)+cos(xs_condensed(i, 1))];
    xs_full(i, [5, 6]) = [-cos(xs_condensed(i, 1))*xs_condensed(i, 3);
        -sin(xs_condensed(i, 1))*xs_condensed(i, 3)];
end