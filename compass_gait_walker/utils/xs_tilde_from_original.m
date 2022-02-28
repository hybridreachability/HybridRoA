function xs_tilde = xs_tilde_from_original(xs, gait_params)
    qs_tilde = q_tilde_from_q_gen(xs(:, 1:4)', gait_params);
    dqs_tilde = dq_tilde_from_qdq_gen(xs(:, 1:4)', xs(:, 5:8)', gait_params);
    xs_tilde = [qs_tilde', dqs_tilde'];
end