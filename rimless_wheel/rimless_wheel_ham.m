function hamValue = rimless_wheel_ham(t, data, deriv, schemeData)
% hamValue = dubins2Dham(deriv, schemeData)
%   Hamiltonian function for Rimless wheel used with the level set toolbox
%
% Inputs:
%   schemeData - problem parameters
%     .grid:   grid structure
%     .tMode: 'backward' or 'forward'

checkStructureFields(schemeData, 'grid');

g = schemeData.grid;


%% Defaults: backward reachable set
if ~isfield(schemeData, 'tMode')
  schemeData.tMode = 'backward';
end

%% Hamiltonian control terms
% Speed control
hamValue = g.xs{2}.* deriv{1} + sin(g.xs{1}).* deriv{2};

%% Backward or forward reachable set
if strcmp(schemeData.tMode, 'backward')
  hamValue = -hamValue;
else
  error('tMode must be ''backward''!')
end
end
