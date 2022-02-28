function dq_post_impact = dq_post_impact_condensed(xs)
q1 = xs(1,:);
q2 = xs(2,:);
dq1 = xs(3,:);
dq2 = xs(4,:);

% Manually added code.
dx = -cos(q1) .* dq1;
dy = -sin(q1) .* dq1;

t2 = cos(q1);
t3 = cos(q2);
t4 = sin(q1);
t5 = q1+q2;
t6 = q1.*2.0;
t7 = q2.*2.0;
t14 = -q2;
t8 = cos(t6);
t9 = cos(t7);
t10 = sin(t6);
t11 = sin(t7);
t12 = cos(t5);
t13 = sin(t5);
t15 = dq1.*t3.*2.0;
t16 = dq2.*t3.*2.0;
t17 = q2+t5;
t21 = dx.*t2.*8.0;
t22 = q1+t14;
t23 = dy.*t4.*8.0;
t24 = t5.*2.0;
t18 = cos(t17);
t19 = sin(t17);
t20 = t9.*2.0;
t25 = -t21;
t26 = -t23;
t28 = cos(t24);
t29 = sin(t24);
t27 = dq1.*t20;
t30 = t20-7.0;
t31 = dx.*t18.*1.0e+1;
t32 = dy.*t19.*1.0e+1;
t33 = 1.0./t30;
dq_post_impact = [t33.*(dq1.*-7.0+t15+t16+t25+t26+t27+t31+t32);
    -t33.*(dq1.*-8.0-dq2+t15+t16+t25+t26+t27+t31+t32-dx.*t12.*8.0-dy.*t13.*8.0+dx.*cos(t22).*2.0+dy.*sin(t22).*2.0)];
end