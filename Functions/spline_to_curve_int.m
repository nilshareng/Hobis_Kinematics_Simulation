function res = spline_to_curve_int(Pol, T)
%   T = periodicity wished
%   Pol = spline polynom for the curve
%   interval fixed at [0 1] with the condition f(0)==f(1)

f= 1/T;
% L'intervalle dans le polynome est entre 2 PC
interval = Pol(1,2):f:Pol(end,3);
S = size(interval,2);

NewCurve = [];
k=1;
w=0;

for i = 1:S
    if(interval(i)-1<(f/2))
        w=i;
    end
    if (interval(i)>Pol(k,3))
        k=k+1;
    end
    % Sélection du bon intervalle entre les PC pour évaluer
    NewCurve = [NewCurve , polyval(Pol(k,4:7),interval(i))];
end

% Sert à la remise sur un intervalle [0 1], pour que chaque courbe soit sur le même intervalle 
NewCurve = [NewCurve(w+1:end), NewCurve(1:w)];

% NewCurve(end,:) = NewCurve(1,:);

res = NewCurve;
end


