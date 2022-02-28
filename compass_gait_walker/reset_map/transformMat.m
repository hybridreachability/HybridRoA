function [T, d] = transformMat()

% Transformation matrix:
T = [1, 0, 0, 0;
    0, 1, 0, 0;
    0, 0, 1, 0;
    0, 0, 1, 1];
d = [0;0;0;pi];