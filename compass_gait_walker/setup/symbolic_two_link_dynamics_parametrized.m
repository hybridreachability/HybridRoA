% clear
%% Define symbolic variables for cofiguration variables and mechanical parameters
% Ayush Agrawal
% ayush.agrawal@berkeley.edu

syms q1 q2 x y real
syms dq1 dq2 dx dy real
syms u real
% model params
syms lL mL g mH real

% Position Variable vector
q = [x;y;q1;q2];

% Velocity variable vector
dq = [dx;dy;dq1;dq2];

% Inputs
tau = [u];

% # of Degrees of freedom
NDof = length(q);
%% Lagrangian Dynamics

% Find the absolute angle associated with each link

q1Absolute = q1;
% Leg 2
q2Absolute = pi + q1 + q2;

% Leg 1
pComLeg1 = [x + lL*sin(q1)/2;...
       y - lL*cos(q1)/2];

pComLeg2 = [x - lL*sin(pi-q2Absolute)/2;...
       y - lL*cos(pi-q2Absolute)/2];

% Leg 1
pLeg1 = [x + lL*sin(q1);...
       y - lL*cos(q1)];
% Leg 2
pLeg2 = [x - lL*sin(pi-q2Absolute);...
       y - lL*cos(pi-q2Absolute)];
   
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
KELeg1 = 0.5*mL*dpComLeg1(1)^2 + 0.5*mL*dpComLeg1(2)^2;

% Leg 2
KELeg2 = 0.5*mL*dpComLeg2(1)^2 + 0.5*mL*dpComLeg2(2)^2;

KEHip = 0.5*mH*dx^2 + 0.5*mH*dy^2;
% Total KE
KE = simplify(KELeg1 + KELeg2 + KEHip);

% Total potential energy = Sum of Potential energy of each link

%Leg 1
PELeg1 = mL*g*pComLeg1(2);

% Leg 2
PELeg2 = mL*g*pComLeg2(2);

% Hip
PEHip = mH*g*y;

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
[D, C, G, B] = LagrangianDynamics(KE, PE, q, dq, qActuated);


%% Problem 3: Dynamics of Systems with Constraints
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

H = C*dq + G;
alpha = 0;
% Constraint Force to enforce the holonomic constraint:
FSt = - pinv(JSt*(D\JSt'))*(JSt*(D\(-H + B*tau)) + dJSt*dq + 2*alpha*JSt*dq + alpha^2*pst);
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

% postImpact = [qPlus;F_impact];
% Here, q, dq represent the pre-impact positions and velocities
[postImpact] = ([D, -JSw';JSw, zeros(2)])\[D*dq;zeros(2,1)];

% Post Impact velocities
dqPlus = simplify(postImpact(1:NDof));

% Impact Force Magnitude
Fimpact = simplify(postImpact(NDof+1:NDof+2));

%% Compute the f and g vectors

fvec = [dq;inv(D)*(- H + JSt'*Fst_nu)];
fvec = simplify(fvec);
gvec_u = [sym(zeros(NDof,1));
        inv(D)*(B*tau + JSt'*(Fst_u*tau))]; % gvec*u
gvec = jacobian(gvec_u, tau); % gvec

gvec = simplify(gvec);

state = [q;dq];
s = [q1; q2; dq1; dq2];
fvec_q = fvec([3, 4, 7, 8]);
gvec_q = gvec([3, 4, 7, 8], :);
%% ASK AYUSH
dqPlus_dq1 = dqPlus(3);
dqPlus_dq1 = subs(dqPlus_dq1, [dx, dy], [-lL*cos(q1)*dq1, -lL*sin(q1)*dq1]);
dqPlus_dq2 = dqPlus(4);
dqPlus_dq2 = subs(dqPlus_dq2, [dx, dy], [-lL*cos(q1)*dq1, -lL*sin(q1)*dq1]);
dqPlus_new = simplify([dqPlus_dq1; dqPlus_dq2]);

dqPlus_new_matrix = [jacobian(dqPlus_new, dq1), jacobian(dqPlus_new, dq2)];
matlabFunction(dqPlus, 'File', 'gen/dqPlus_param_gen', 'Vars', {state, lL, mL, g, mH});
% matlabFunction(dqPlus_new_matrix, 'File', 'gen/dqPlus_matrix_gen', 'Vars', {s, lL, mL, g, mH});
% matlabFunction(fvec_q, 'File', 'gen/fvec_q_gen', 'Vars', {s, lL, mL, g, mH});
% matlabFunction(gvec_q, 'File', 'gen/gvec_q_gen', 'Vars', {s, lL, mL, g, mH});