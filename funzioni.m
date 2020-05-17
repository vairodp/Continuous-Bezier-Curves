function [ cerchio ] = funzioni(x,y,r)
hold on
th = 0:pi/50:2*pi;
xunit = r * cos(th) + x;
yunit = r * sin(th) + y;
cerchio = plot(xunit, yunit);
hold off
end

