function dq_tilde_from_qdq = dq_tilde_from_qdq_gen(in1,in2,in3)
%DQ_TILDE_FROM_QDQ_GEN
%    DQ_TILDE_FROM_QDQ = DQ_TILDE_FROM_QDQ_GEN(IN1,IN2,IN3)

%    This function was generated by the Symbolic Math Toolbox version 8.4.
%    05-Dec-2021 17:20:46

beta1 = in3(1,:);
beta2 = in3(2,:);
beta3 = in3(3,:);
beta4 = in3(4,:);
dq1 = in2(3,:);
dq2 = in2(4,:);
dx = in2(1,:);
dy = in2(2,:);
q1 = in1(3,:);
th1d = in3(5,:);
t2 = q1.^2;
t3 = th1d.^2;
dq_tilde_from_qdq = [dx;dy;dq1+dq2-dq1.*(beta1.*q1.*2.0+beta2.*t2.*3.0-beta2.*t3+beta3.*q1.^3.*4.0+beta4.*t2.^2.*5.0-beta3.*q1.*t3.*2.0-beta4.*t2.*t3.*3.0-1.0);dq1];