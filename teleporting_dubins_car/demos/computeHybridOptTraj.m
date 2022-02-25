function [traj, traj_tau, traj_u] = computeHybridOptTraj(g, data, tau, dynSys, extraArgs)
% [traj, traj_tau] = computeOptTraj(g, data, tau, dynSys, extraArgs)
%   Computes the optimal trajectories given the optimal value function
%   represented by (g, data), associated time stamps tau, dynamics given in
%   dynSys.
%
% Inputs:
%   g, data - grid and value function
%   tau     - time stamp (must be the same length as size of last dimension of
%                         data)
%   dynSys  - dynamical system object for which the optimal path is to be
%             computed
%   extraArgs
%     .uMode        - specifies whether the control u aims to minimize or
%                     maximize the value function
%     .visualize    - set to true to visualize results
%     .fig_num:   List if you want to plot on a specific figure number
%     .projDim      - set the dimensions that should be projected away when
%                     visualizing
%     .fig_filename - specifies the file name for saving the visualizations

if nargin < 5
  extraArgs = [];
end

% Default parameters
uMode = 'min';
visualize = false;
subSamples = 4;

if isfield(extraArgs, 'uMode')
  uMode = extraArgs.uMode;
end

ctrlMode = 'opt'; % 'both'; 'pid;'
if isfield(extraArgs, 'ctrlMode')
    ctrlMode = extraArgs.ctrlMode;
end

tMax = tau(end);
if isfield(extraArgs, 'tMax')
    tMax = extraArgs.tMax;
end

% Visualization
if isfield(extraArgs, 'visualize') && extraArgs.visualize
  visualize = extraArgs.visualize;
  
  showDims = find(extraArgs.projDim);
  hideDims = ~extraArgs.projDim;
  
  if isfield(extraArgs,'fig_num')
    f = figure(extraArgs.fig_num);
  else
    f = figure;
  end
end

if isfield(extraArgs, 'subSamples')
  subSamples = extraArgs.subSamples;
end

clns = repmat({':'}, 1, g.dim);

if any(diff(tau)) < 0
  error('Time stamps must be in ascending order!')
end

% Time parameters
iter = 1;
dtSmall = (tau(2) - tau(1))/subSamples;
tauLength = length(tau);
% maxIter = 1.25*tauLength;

% Initialize trajectory
traj = nan(g.dim, tauLength);
traj(:,1) = dynSys.x;
traj_u = nan(g.dim, tauLength-1);
tEarliest = 1;

while iter <= length(tau)
    if ~strcmp(ctrlMode, 'pid')
      % Determine the earliest time that the current state is in the reachable set
      % Binary search
      if ~(abs(dynSys.x(1) - dynSys.R) < 0.03 && abs(dynSys.x(3) - dynSys.x(2) - .5 * pi) < 0.01)
          upper = floor(tMax/(tau(2) - tau(1)));
          lower = tEarliest;

          tEarliest = find_earliest_BRS_ind(g, data, dynSys.x, upper, lower)

          % BRS at current time
          BRS_at_t = data(clns{:}, tEarliest);
      end
      % Visualize BRS corresponding to current trajectory point
    %   if visualize
    %     plot(traj(showDims(1), iter), traj(showDims(2), iter), 'k.')
    %     hold on
    %     [g2D, data2D] = proj(g, BRS_at_t, hideDims, traj(hideDims,iter));
    %     visSetIm(g2D, data2D);
    %     tStr = sprintf('t = %.3f; tEarliest = %.3f', tau(iter), tau(tEarliest));
    %     title(tStr)
    %     drawnow
    %     
    %     if isfield(extraArgs, 'fig_filename')
    %       export_fig(sprintf('%s%d', extraArgs.fig_filename, iter), '-png')
    %     end
    % 
    %     hold off
    %   end

%       if tEarliest == tauLength
%         % Trajectory has entered the target
%         break
%       end
    Deriv = computeGradients(g, BRS_at_t);
    end
  
  % Update trajectory
  for j = 1:subSamples
      if strcmp(ctrlMode, 'pid')
         x_m  = dynSys.x';
         if x_m(2) == x_m(3)
             u = dynSys.uMax;
         else
             eps = 1;
             k_r = 5;
             k_rdot = 6;             
             mu = -k_r * x_m(1) / eps^2 - k_rdot * dynSys.v * cos(x_m(2)-x_m(3)) / eps;
             u_ff = - sin(x_m(2)-x_m(3)) / (x_m(1) + dynSys.R);
             u_fb = mu / (dynSys.v * sin(x_m(2)-x_m(3)));
             u = u_ff + u_fb;
         end
         u = min(u, dynSys.uMax);
         u = max(u, dynSys.uMin);
         disp(u)
      else
          if abs(dynSys.x(1)) < 0.02 && abs(dynSys.x(3) - dynSys.x(2) - .5 * pi) < 0.01
             x_m  = dynSys.x';
              eps = 1;
             k_r = 5;
             k_rdot = 6;             
             mu = -k_r * x_m(1) / eps - k_rdot * dynSys.v * cos(x_m(2)-x_m(3)) / eps^2;
             u_ff = - sin(x_m(2)-x_m(3)) / (x_m(1) + dynSys.R);
             u_fb = mu / (dynSys.v * sin(x_m(2)-x_m(3)));
             u = u_ff + u_fb;
          else
              deriv = eval_u(g, Deriv, dynSys.x);
            u = dynSys.optCtrl(tau(tEarliest), dynSys.x, deriv, uMode);
          end
      end
    dynSys.updateStateWithResetMap(u, dtSmall, dynSys.x);
  end
    
  % Record new point on nominal trajectory
  traj_u(:, iter) = u;
  iter = iter + 1;
  traj(:,iter) = dynSys.x;
end

% Delete unused indices
traj(:,iter:end) = [];
traj_tau = tau(1:iter-1);
traj_u(:, iter:end) = [];
end