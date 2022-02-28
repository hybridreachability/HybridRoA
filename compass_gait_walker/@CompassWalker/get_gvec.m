function gvec = get_gvec(obj, state_condensed,lL,mL,g,mH)
% Modified from gvec_q_gen

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

q2 = state_condensed(2,:);
t2 = cos(q2);
t3 = mH.*4.0;
t4 = mL.*5.0;
t6 = 1.0./lL.^2;
t5 = t2.^2;
t7 = mL.*t5.*4.0;
t8 = -t7;
t9 = t3+t4+t8;
t10 = 1.0./t9;
gvec = zeros(4, 1, size(state_condensed, 2));
gvec(3, 1, :) = t6.*t10.*(t2.*8.0-4.0);
gvec(4, 1, :) = (t6.*t10.*(mH.*1.6e+1+mL.*2.4e+1-mL.*t2.*1.6e+1))./mL;
