function psia = psia_gen(x1,x2)
%PSIA_GEN
%    PSIA = PSIA_GEN(X1,X2)

%    This function was generated by the Symbolic Math Toolbox version 8.6.
%    16-Jun-2021 01:10:33

t2 = abs(x2);
t3 = sign(x2);
t4 = t2.^(1.1e+1./1.0e+1);
t5 = t3.*t4.*(1.0e+1./1.1e+1);
t6 = t5+x1;
psia = -abs(t6).^(9.0./1.1e+1).*sign(t6)-t2.^(9.0./1.0e+1).*t3;
