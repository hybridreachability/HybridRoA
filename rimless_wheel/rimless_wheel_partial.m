function alpha = rimless_wheel_partial(t, data, derivMin, derivMax, schemeData, dim)
% Inputs:
%   schemeData - problem parameters
%     .grid: grid structure

checkStructureFields(schemeData, 'grid');

g = schemeData.grid;

switch dim
  case 1
    % Control
    alpha = abs(g.xs{2});
    
  case 2
    % Control
    alpha = abs(sin(g.xs{1})); 
    
end
end