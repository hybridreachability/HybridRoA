function Lfy = Lfy_gen(in1,in2,th1d)
%LFY_GEN
%    LFY = LFY_GEN(IN1,IN2,TH1D)

%    This function was generated by the Symbolic Math Toolbox version 8.6.
%    16-Jun-2021 01:10:33

beta1 = in2(1,:);
beta2 = in2(2,:);
beta3 = in2(3,:);
beta4 = in2(4,:);
dq1 = in1(7,:);
dq2 = in1(8,:);
q1 = in1(3,:);
t2 = beta2.*q1;
t3 = q1+th1d;
t4 = q1.^2;
t5 = q1.^3;
t6 = -th1d;
t7 = beta3.*t4;
t8 = beta4.*t5;
t9 = q1+t6;
t10 = beta1+t2+t7+t8;
Lfy = dq2-dq1.*(t3.*t10+t9.*t10+t3.*t9.*(beta2+beta3.*q1.*2.0+beta4.*t4.*3.0)-2.0);