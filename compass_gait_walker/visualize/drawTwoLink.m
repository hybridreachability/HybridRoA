function drawTwoLink(q, swing_color)
palette = get_palette_colors();
if nargin < 2
    swing_color = palette.blue;
end

x = q(1);
y = q(2);

pSw = pSw_gen([q;zeros(5,1)]);
pSt = pSt_gen([q;zeros(5,1)]);
hold on
l2 = line([x;pSw(1)], [y;pSw(2)], 'Color', swing_color, 'LineWidth', 6);
l3 = line([x;pSt(1)], [y;pSt(2)], 'Color', palette.magenta, 'LineWidth', 6);
plot(pSw(1), pSw(2), 'bo', 'MarkerSize',6,'MarkerEdgeColor',swing_color,'MarkerFaceColor',palette.yellow)
plot(pSt(1), pSt(2), 'ro', 'MarkerSize',6,'MarkerEdgeColor',palette.magenta,'MarkerFaceColor',palette.yellow)
plot(x, y, 'ko', 'MarkerSize',12,'MarkerEdgeColor',palette.white,'MarkerFaceColor',palette.yellow)