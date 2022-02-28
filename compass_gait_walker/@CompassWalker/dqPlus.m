function dqPlus = dqPlus(obj, state_full, lL,mL,g,mH)
% Modified from dqPlus_param_gen

if nargin < 3
    lL = obj.lL;
end
if nargin < 4
    mL = obj.mL;
end
if nargin < 5
    g = obj.g;
end
if nargin < 6
    mH = obj.mH;
end

dq1 = state_full(7,:);
dq2 = state_full(8,:);
dx = state_full(5,:);
dy = state_full(6,:);
q1 = state_full(3,:);
q2 = state_full(4,:);
t2 = cos(q1);
t3 = cos(q2);
t4 = sin(q1);
t5 = q1+q2;
t6 = mH.*4.0;
t7 = mL.*3.0;
t8 = q1.*2.0;
t9 = q2.*2.0;
t16 = 1.0./lL;
t17 = -q2;
t10 = cos(t8);
t11 = cos(t9);
t12 = sin(t8);
t13 = sin(t9);
t14 = cos(t5);
t15 = sin(t5);
t18 = dq1.*lL.*t6;
t19 = q2+t5;
t21 = dx.*t2.*t6;
t22 = dx.*mL.*t2.*4.0;
t24 = dy.*t4.*t6;
t25 = dy.*mL.*t4.*4.0;
t26 = q1+t17;
t27 = t5.*2.0;
t29 = dq1.*lL.*mL.*t3.*2.0;
t30 = dq2.*lL.*mL.*t3.*2.0;
t20 = cos(t19);
t23 = sin(t19);
t28 = mL.*t11.*2.0;
t32 = cos(t27);
t33 = sin(t27);
t31 = -t28;
t34 = dq1.*lL.*t28;
t35 = dx.*t6.*t20;
t36 = dx.*mL.*t20.*6.0;
t37 = dy.*t6.*t23;
t38 = dy.*mL.*t23.*6.0;
t39 = t6+t7+t31;
t40 = 1.0./t39;
dqPlus = [t40.*(dx.*mH.*2.0+dx.*mL.*2.0+dx.*mH.*t32.*2.0+dy.*mH.*t33.*2.0-dx.*mL.*t10-dx.*mL.*t11+dx.*mL.*t32.*2.0-dy.*mL.*t12+dy.*mL.*t13+dy.*mL.*t33.*2.0+dq1.*lL.*mL.*t14+dq2.*lL.*mL.*t14);t40.*(dy.*mH.*2.0+dy.*mL.*2.0+dx.*mH.*t33.*2.0-dy.*mH.*t32.*2.0-dx.*mL.*t12-dx.*mL.*t13+dx.*mL.*t33.*2.0+dy.*mL.*t10-dy.*mL.*t11-dy.*mL.*t32.*2.0+dq1.*lL.*mL.*t15+dq2.*lL.*mL.*t15);-t16.*t40.*(-t22-t25+t29+t30+t34+t35+t36+t37+t38-dq1.*lL.*mH.*4.0-dq1.*lL.*mL.*3.0-dx.*mH.*t2.*4.0-dy.*mH.*t4.*4.0);-t16.*t40.*(t18+t21+t22+t24+t25-t29-t30-t36-t38-dx.*mL.*cos(t26).*2.0-dy.*mL.*sin(t26).*2.0+dq1.*lL.*mL.*4.0+dq2.*lL.*mL-dx.*mH.*t20.*4.0-dy.*mH.*t23.*4.0+dx.*mL.*t14.*4.0+dy.*mL.*t15.*4.0+dx.*t6.*t14+dy.*t6.*t15-dq1.*lL.*mL.*t11.*2.0)];
