function pLeg1 = pLeg1_gen(in1)
%PLEG1_GEN
%    PLEG1 = PLEG1_GEN(IN1)

%    This function was generated by the Symbolic Math Toolbox version 8.6.
%    16-Jun-2021 01:10:33

q1 = in1(3,:);
x = in1(1,:);
ypos = in1(2,:);
pLeg1 = [x+sin(q1);ypos-cos(q1)];
