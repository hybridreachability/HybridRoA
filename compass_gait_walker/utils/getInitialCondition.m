function [x0] = getInitialCondition()

th0 = [pi/16;pi-pi/16];
% dth0 = [-0.9366;0.3755;]*1.8;
dth0 = [-0.9;0.9;].*[2;0.5];
lL = 1;

X0 = -lL*sin(th0(1));
Y0 = lL*cos(th0(1));
dX0 = -lL*cos(th0(1))*dth0(1);
dY0 = -lL*sin(th0(1))*dth0(1);

q0Abs = [X0;Y0;th0];
dq0Abs = [dX0;dY0;dth0];

T = [1, 0, 0, 0;0, 1, 0, 0;0, 0,1, 0;0, 0, 1, 1];
d = [0;0;0;pi];
q0 = inv(T)*q0Abs - inv(T)*d;
dq0 = inv(T)*dq0Abs;
x0 = [q0;dq0];