function res = PC_to_spline(PC,Length)
%   PC is the list of indices and values of control points for the curve (derivative zero)
%   Output is an array with the equation of the 3rd degree polynome and the interval (2 PCs) it corresponds to 
% Length -> Périodicité, en général 1-périodique

S = size(PC(:,1),1);
Pol = zeros(S,7);
count = 1;

flag = 0;

% Il faut au moins 2 PC pour faire une spline
if S==1
    return ;
end

% Construction du Pôlynome
for i = 1:S-1
    Pol(count,2)=PC(i,1);
    Pol(count,3)=PC(i+1,1);
    Pol(count,4:7)=Spline3Int(PC(i,1),PC(i,2),0,PC(i+1,1),PC(i+1,2),0);
    count=count+1;
end

Pol(count,2)=PC(S,1);
Pol(count,3)=PC(1,1)+Length;
Pol(count,4:7)=Spline3Int(PC(S,1),PC(S,2),0,PC(1,1)+Length,PC(1,2),0);

res = Pol;
end
