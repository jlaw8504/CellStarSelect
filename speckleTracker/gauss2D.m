function f = gauss2D(x, y, a, mx, my, sx, sy)

f = a*exp(-(((x-mx)^2)/(2*sx^2)+((y-my)^2)/(2*sy^2)));