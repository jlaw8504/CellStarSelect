function [newKinet1, newKinet2] = sAxisYX(spb1,spb2, kinet1, kinet2)
%%xAxisYX Return YX coordinates of kinet foci along spindle axis in vector.

%% Calculate distance of kinet1 to spindle axis (newY)
spbSub = spb2 - spb1;
dist = sqrt(spbSub(1)^2 + spbSub(2)^2);
newY1 = (abs(spbSub(1)*kinet1(2) - spbSub(2)*kinet1(1)...
    + spb2(2)*spb1(1) - spb2(1)*spb1(2)))/dist;
newY2 = (abs(spbSub(1)*kinet2(2) - spbSub(2)*kinet2(1)...
    + spb2(2)*spb1(1) - spb2(1)*spb1(2)))/dist;
%% Calculate new X
newX1 = real(sqrt(norm(spb1-kinet1)^2 - newY1^2));
newX2 = real(sqrt(norm(spb2-kinet2)^2 - newY2^2));
%% Assign newXs and newYs
newKinet1 = [newY1, newX1];
newKinet2 = [newY2, newX2];
