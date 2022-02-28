clear
%% Define symbolic variables for cofiguration variables and mechanical parameters
% Ayush Agrawal
% ayush.agrawal@berkeley.edu

syms q1 q2 x ypos real
syms dq1 dq2 dx dy real
syms d2q1 d2q2 d2x d2y real
syms u real

% Position Variable vector
q = [x;ypos;q1;q2];

% Velocity variable vector
dq = [dx;dy;dq1;dq2];

d2q = [d2x;d2y;d2q1;d2q2];
% Inputs
tau = [u];

% parameters          
lL = 1;
lT = 0.5;
mL = 1;
JL = 0;
g = 9.81;
mH = 1;

% # of Degrees of freedom
NDof = length(q);
%% Lagrangian Dynamics

% Find the absolute angle associated with each link
q1Absolute = q1;
% Leg 2
q2Absolute = pi + q1 + q2;
% Leg 1
pComLeg1 = [x + lL*sin(q1)/2;...
       ypos - lL*cos(q1)/2];
pComLeg2 = [x - lL*sin(pi-q2Absolute)/2;...
       ypos - lL*cos(pi-q2Absolute)/2];
% Leg 1
pLeg1 = [x + lL*sin(q1);...
       ypos - lL*cos(q1)];
% Leg 2
pLeg2 = [x - lL*sin(pi-q2Absolute);...
       ypos - lL*cos(pi-q2Absolute)];
% Find the CoM velocity of each link
% Leg 1
dpComLeg1 = simplify(jacobian(pComLeg1, q)*dq);
% Leg 2
dpComLeg2 = simplify(jacobian(pComLeg2, q)*dq);


%% Find absolute angular velocity associated with each link:
% Leg 1
dq1Absolute = dq1;
% Leg 2
dq2Absolute = dq1 + dq2;

% Total Kinetic energy = Sum of kinetic energy of each link
% Leg 1
KELeg1 = 0.5*mL*dpComLeg1(1)^2 + 0.5*mL*dpComLeg1(2)^2 + 0.5*JL*dq1Absolute^2;
% Leg 2
KELeg2 = 0.5*mL*dpComLeg2(1)^2 + 0.5*mL*dpComLeg2(2)^2 + 0.5*JL*dq2Absolute^2;

KEHip = 0.5*mH*dx^2 + 0.5*mH*dy^2;
% Total KE
KE = simplify(KELeg1 + KELeg2 + KEHip);
% Total potential energy = Sum of Potential energy of each link
%Leg 1
PELeg1 = mL*g*pComLeg1(2);
% Leg 2
PELeg2 = mL*g*pComLeg2(2);
% Hip
PEHip = mH*g*ypos;

% Total PE
PE = simplify(PELeg1 + PELeg2 + PEHip);

% Lagrangian
L = KE - PE;

% Equations of Motion
EOM = jacobian(jacobian(L,dq), q)*dq - jacobian(L, q)' ;
EOM = simplify(EOM);

% Find the D, C, G, and B matrices
% Actuated variables
qActuated = [q2];

% D, C, G, and B matrices
[Dmat, Cmat, Gvec, Bmat] = LagrangianDynamics(KE, PE, q, dq, qActuated);


%% Dynamics of Systems with Constraints
%Compute the Ground reaction Forces
% Compute the position of the stance foot (Leg 1) 
pst = pLeg1;
% Compute the jacobian of the stance foot
JSt = jacobian(pst, q);
% Compute the time derivative of the Jacobian
dJSt = sym(zeros(size(JSt)));
for i = 1:size(JSt, 1)
    for j = 1:size(JSt, 2)
        dJSt(i, j) = simplify(jacobian(JSt(i, j), q)*dq);
    end
end

Hvec = Cmat*dq + Gvec;
alpha = 0;
% Constraint Force to enforce the holonomic constraint:
FSt = - pinv(JSt*(Dmat\JSt'))*(JSt*(Dmat\(-Hvec + Bmat*tau)) + dJSt*dq + 2*alpha*JSt*dq + alpha^2*pst);
FSt = simplify(FSt);

% Split FSt into 2 components: 1. which depends on tau and 2. which does
% not depend on tau 
% Note: FSt is linear in tau
Fst_u = jacobian(FSt, tau); % FSt = Fst_u*tau + (Fst - Fst_u*tau)
Fst_nu = FSt - Fst_u*tau; % Fst_nu = (Fst - Fst_u*tau)

%% Impact Map
% Compute the swing leg position (leg 2)
pSw = pLeg2;
JSw = jacobian(pSw, q);
% Here, q, dq represent the pre-impact positions and velocities
[postImpact] = ([Dmat, -JSw';JSw, zeros(2)])\[Dmat*dq;zeros(2,1)];
% Post Impact velocities
dqPlus = simplify(postImpact(1:NDof));
% Impact Force Magnitude
Fimpact = simplify(postImpact(NDof+1:NDof+2));

%% Compute the f and g vectors
fvec = [dq;inv(Dmat)*(- Hvec + JSt'*Fst_nu)];
fvec = simplify(fvec);
gvec_u = [sym(zeros(NDof,1));
        inv(Dmat)*(Bmat*tau + JSt'*(Fst_u*tau))]; % gvec*u
gvec = jacobian(gvec_u, tau); % gvec
gvec = simplify(gvec);

%% Output dynamics
state = [q;dq];
beta = sym('beta', [4,1]);
syms th1d real
q2AbsDes = -q1Absolute + (beta(1)+beta(2)*q1Absolute + beta(3)*q1Absolute^2 + beta(4)*q1Absolute^3)*(q1Absolute + th1d)*(q1Absolute - th1d)+pi;
y = [q2Absolute - q2AbsDes];
Lfy = jacobian(y, state)*fvec;
Lf2y = jacobian(Lfy, state)*fvec;
LgLfy = jacobian(Lfy, state)*gvec;

dpSw = JSw*dq;
%% Export functions
% mkdir('gen')
% matlabFunction(fvec, 'File', 'gen/fvec_gen', 'Vars', {state});
% matlabFunction(gvec, 'File', 'gen/gvec_gen', 'Vars', {state});
% matlabFunction(y, 'File', 'gen/y_gen', 'Vars', {state,beta,th1d});
% matlabFunction(Lfy, 'File', 'gen/Lfy_gen', 'Vars', {state,beta,th1d});
% matlabFunction(Lf2y, 'File', 'gen/Lf2y_gen', 'Vars', {state,beta,th1d});
% matlabFunction(LgLfy, 'File', 'gen/LgLfy_gen', 'Vars', {state,beta,th1d});
% matlabFunction(FSt, 'File', 'gen/Fst_gen', 'Vars', {state, tau});
% matlabFunction(dqPlus, 'File', 'gen/dqPlus_gen', 'Vars', {state});
% matlabFunction(psia, 'File', 'gen/psia_gen', 'Vars', {x1, x2});
% matlabFunction(pSw, 'File', 'gen/pSw_gen', 'Vars', {state});
% matlabFunction(pSw, 'File', 'gen/pSw_gen', 'Vars', {state});
% matlabFunction(dpSw, 'File', 'gen/dpSw_gen', 'Vars', {state});
% matlabFunction(pst, 'File', 'gen/pSt_gen', 'Vars', {state});
% matlabFunction(pComLeg1, 'File', 'gen/pComLeg1_gen', 'Vars', {state});
% matlabFunction(pComLeg2, 'File', 'gen/pComLeg2_gen', 'Vars', {state});
% matlabFunction(pLeg1, 'File', 'gen/pLeg1_gen', 'Vars', {state});
% matlabFunction(pLeg2, 'File', 'gen/pLeg2_gen', 'Vars', {state});
% matlabFunction(JSt, 'File', 'gen/Jst_gen', 'Vars', {state});
% matlabFunction(dJSt, 'File', 'gen/dJst_gen', 'Vars', {state});
% matlabFunction(Dmat, 'File', 'gen/Dmat_gen', 'Vars', {state});
% matlabFunction(Cmat, 'File', 'gen/Cmat_gen', 'Vars', {state});
% matlabFunction(Gvec, 'File', 'gen/Gvec_gen_', 'Vars', {state});
% matlabFunction(Bmat, 'File', 'gen/Bmat_gen', 'Vars', {state});

