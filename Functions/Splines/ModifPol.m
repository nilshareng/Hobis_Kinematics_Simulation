function [NewPol, inds ]= ModifPol(Pol,NewPC,NewTan,Ind)
% Je me souvenais meme plus de cette fonction
% Elle permet de ne pas recalculer tout le polynome à chaque fois, mais
% juste les intervalles impactés par une modification du PC d'indice Ind en NewPC,
% avec une tangente de NewTan

% Retourne le nouveau Polynôme, et les indices des intervalles modifiés


S = size(Pol,1);

if (Ind==S)
    Pol(Ind-1,3) = NewPC(Ind,1);
    Pol(Ind,2) = NewPC(Ind,1);
    Pol(Ind-1,4:7) = Spline3Int(NewPC(Ind-1,1),NewPC(Ind-1,2),0,NewPC(Ind,1),NewPC(Ind,2),NewTan);
    Pol(Ind,4:7) = Spline3Int(NewPC(Ind,1),NewPC(Ind,2),NewTan,NewPC(1,1)+1,NewPC(1,2),0);
    inds = [Ind-1, Ind];

elseif (Ind==1)
    Pol(Ind,2) = NewPC(Ind,1);
    Pol(S,3) = NewPC(Ind,1)+1;
    Pol(Ind,4:7) = Spline3Int(NewPC(Ind,1),NewPC(Ind,2),NewTan,NewPC(Ind+1,1),NewPC(Ind+1,2),0);
    Pol(S,4:7) = Spline3Int(NewPC(S,1),NewPC(S,2),0,NewPC(Ind,1)+1,NewPC(Ind,2),NewTan);
    inds = [S, Ind];

else
    Pol(Ind-1,3) = NewPC(Ind,1);
    Pol(Ind,2) = NewPC(Ind,1);
    Pol(Ind-1,4:7) = Spline3Int(NewPC(Ind-1,1),NewPC(Ind-1,2),0,NewPC(Ind,1),NewPC(Ind,2),NewTan);
    Pol(Ind,4:7) = Spline3Int(NewPC(Ind,1),NewPC(Ind,2),NewTan,NewPC(Ind+1,1),NewPC(Ind+1,2),0);
    inds = [Ind-1, Ind];

end

NewPol = Pol;

end

