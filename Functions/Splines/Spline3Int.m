function res = Spline3Int(t0,c0, d0, tf, cf, df)
%   t0 the abscissa of the first point of the interval. 
%   y0 the ordinate of t0 using the function to approximate
%   d0 the ordinate of t0 using the derivative of the function to approximate
%   tf, yf, df idem for the last point of the interval
%   res = 3rd degree polynom corresponding to the approximated function for the interval

M = [t0^3 t0^2 t0 1 ; 3*t0^2 2*t0 1 0 ; tf^3 tf^2 tf 1 ; 3*tf^2 2*tf 1 0];

res = (M\[c0 ; d0 ; cf ; df])' ;
end

