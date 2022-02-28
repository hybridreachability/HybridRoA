function [D, C, G, B] = LagrangianDynamics(T, U, q, dq, q_act)

D = simplify( jacobian(jacobian(T,dq), dq) ) ;
for k=1:length(q)
    for j=1:length(q)
        C(k,j) = sym(0) ;
        for i=1:length(q)
            C(k,j) = C(k,j) + 1/2 * ( diff(D(k,j),q(i)) + diff(D(k,i),q(j)) - diff(D(i,j),q(k)) ) * dq(i) ;
        end
    end
end

C = simplify(C) ;
G = simplify( jacobian(U,q) )' ;
B = jacobian(q_act, q)' ;