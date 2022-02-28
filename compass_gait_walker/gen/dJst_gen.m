function dJSt = dJst_gen(in1)
%DJST_GEN
%    DJST = DJST_GEN(IN1)

%    This function was generated by the Symbolic Math Toolbox version 8.6.
%    16-Jun-2021 01:10:34

dq1 = in1(7,:);
q1 = in1(3,:);
dJSt = reshape([0.0,0.0,0.0,0.0,-dq1.*sin(q1),dq1.*cos(q1),0.0,0.0],[2,4]);