function J = Jerk(NPolA)
% Les splines sont de degré 3 -> Dérivée 3è constante -> Jerk = somme de constantes par intervalle 
J = 0;
for i =1:11
    s = 0;
    tmp= NPolA(NPolA(:,1)==i,1:4);
    for j = 1:size(tmp,1)
        % On somme donc 6*le coefficient de plus grand ordre du polynôme pour chaque angle 
        s = s+abs((6*tmp(j,4)*(tmp(j,3)-tmp(j,2))));
    end
    J = J +s;
end

% Sortie = Moyenne des Jerks
J = J/11;
end

