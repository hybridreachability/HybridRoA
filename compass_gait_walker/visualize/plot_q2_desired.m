function plot_q2_desired(beta_var, th1d, q1_range)
beta1 = beta_var(1,:);
beta2 = beta_var(2,:);
beta3 = beta_var(3,:);
beta4 = beta_var(4,:);
q1s = linspace(q1_range(1), q1_range(2), 100);
q2s = -q1s.*2.0+(q1s+th1d).*(q1s-th1d).*(beta1+beta2.*q1s+beta3.*q1s.^2+beta4.*q1s.^3);
figure;
hax = axes;
p = plot(q1s, q2s); hold on;
p.LineWidth = 2;
p.Color = 'black';
line([-th1d, -th1d],get(hax,'YLim'),'Color',[1 0 0]);
line([th1d, th1d],get(hax,'YLim'),'Color',[1 0 0]);
yline(-2*th1d, 'Color', [1, 0, 0]);
yline(2*th1d, 'Color', [1, 0, 0]);
grid on;
xlabel("q1");
ylabel("q2");
end
