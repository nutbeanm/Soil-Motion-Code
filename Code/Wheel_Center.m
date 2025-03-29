function [xc,yc,r] = Wheel_Center(P1,P2,P3)

% Getting Values from Points
x1 = P1(1);
y1 = P1(2);
x2 = P2(1);
y2 = P2(2);
x3 = P3(1);
y3 = P3(2);

% Calculating xc & yc
if y1 ~= y3
    top = x2^2 + y2^2 - (x1^2 + y1^2) - ((y2-y1)/(y3-y1))*(x3^2 + y3^2 - (x1^2 + y1^2));
    bottom = 2*(x2-x1+((y2-y1)/(y3-y1))*(x1-x3));
    xc = top/bottom;
    top = x3^2 + y3^2 - (x1^2 + y1^2) + 2*xc*(x1-x3);
    bottom = 2*(y3-y1);
    yc = top/bottom;
else
    top = x3^2 + y3^2 - (x1^2 + y1^2) - ((y3-y1)/(y2-y1))*(x2^2 + y2^2 - (x1^2 + y1^2));
    bottom = 2*(x3-x1+((y3-y1)/(y2-y1))*(x1-x2));
    xc = top/bottom;
    top = x2^2 + y2^2 - (x1^2 + y1^2) + 2*xc*(x1-x2);
    bottom = 2*(y2-y1);
    yc = top/bottom;
end

% Calculating r
r = sqrt((x1-xc)^2 + (y1-yc)^2);