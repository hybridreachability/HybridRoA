function x0 = get_init_condition_from_opt_var(x_opt)


th0 = x_opt(1:2);% + rand(2,1);
dth0 = x_opt(3:4);
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

end