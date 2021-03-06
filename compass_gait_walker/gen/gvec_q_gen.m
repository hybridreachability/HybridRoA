function gvec_q = gvec_q_gen(in1,lL,mL,g,mH)
%GVEC_Q_GEN
%    GVEC_Q = GVEC_Q_GEN(IN1,LL,ML,G,MH)

%    This function was generated by the Symbolic Math Toolbox version 8.6.
%    01-Dec-2020 03:36:32

q2 = in1(2,:);
t2 = cos(q2);
t3 = mH.*4.0;
t4 = mL.*5.0;
t6 = 1.0./lL.^2;
t5 = t2.^2;
t7 = mL.*t5.*4.0;
t8 = -t7;
t9 = t3+t4+t8;
t10 = 1.0./t9;
gvec_q = [0.0;0.0;t6.*t10.*(t2.*8.0-4.0);(t6.*t10.*(mH.*1.6e+1+mL.*2.4e+1-mL.*t2.*1.6e+1))./mL];
