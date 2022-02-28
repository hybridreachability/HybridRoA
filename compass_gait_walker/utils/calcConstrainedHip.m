function [x, y, dx, dy] = calcConstrainedHip(th1, dth1)

lL = 1;
x = lL*cos(pi/2 - th1);
y = lL*sin(pi/2 - th1);
dx = lL*sin(pi/2 - th1)*dth1;
dy = lL*cos(pi/2 - th1)*(-dth1);