function fvec = get_fvec(obj, state_condensed,lL,mL,g,mH)
% Modified from fvec_q_gen

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

dq1 = state_condensed(3,:);
dq2 = state_condensed(4,:);
q1 = state_condensed(1,:);
q2 = state_condensed(2,:);
t2 = cos(q1);
t3 = sin(q1);
t4 = sin(q2);
t5 = dq1.^2;
t6 = dq2.^2;
t7 = mH.*4.0;
t8 = mL.*3.0;
t9 = q2.*2.0;
t12 = 1.0./lL;
t10 = cos(t9);
t11 = sin(t9);
t13 = g.*t3.*t7;
t14 = g.*mL.*t3.*4.0;
t17 = dq1.*dq2.*lL.*mL.*t4.*4.0;
t18 = lL.*mL.*t4.*t6.*2.0;
t15 = mL.*t10.*2.0;
t16 = -t15;
t19 = t7+t8+t16;
t20 = 1.0./t19;
fvec = [dq1;dq2;-t12.*t20.*(-t14+t17+t18-g.*mH.*t3.*4.0+g.*mL.*sin(q1+t9).*2.0+lL.*mL.*t4.*t5.*2.0-lL.*mL.*t5.*t11.*2.0);-t12.*t20.*(t13+t14-t17-t18+g.*mH.*t2.*t4.*8.0+g.*mL.*t2.*t4.*1.0e+1-g.*mL.*t2.*t11.*2.0-g.*mL.*t3.*t10.*2.0-lL.*mH.*t4.*t5.*8.0-lL.*mL.*t4.*t5.*1.2e+1+lL.*mL.*t5.*t11.*4.0+lL.*mL.*t6.*t11.*2.0-g.*mL.*t3.*cos(q2).*2.0+dq1.*dq2.*lL.*mL.*t11.*4.0)];
