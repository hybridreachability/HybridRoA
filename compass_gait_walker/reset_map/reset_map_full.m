function x_plus = reset_map_full(x_minus)
R = two_link_reflect;
qminus = x_minus(1:4);
dqminus = x_minus(5:end);    
qPlus = R*qminus;
dqPlus = R*dqPlus_gen([qminus;dqminus]);
x_plus = [qPlus;dqPlus];