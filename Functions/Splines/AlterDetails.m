function [NewDetails] = AlterDetails(Details,PCA,NPCA)
% entries : 
% - Details : Matrice 11 * 
% 

% outs :



% For each angle :
% - for each PC interval :
%   - for t : dilatate or compress the error : if int goes from 0.5 to 0.55
%       the same error profile should be spread on the new interval
%   - for theta : apply factor : alpha = (deltaPCnew)/(deltaPCold) to the
%       error on the interval
S = max(size(Details.Symetric));
c = 0;
NewDetails = Details;
for i = 1:PCA(end,1)
    kO = 0;
    kN = 0;
    TmpS = [];
    TmpA = [];
    for j = 1:size(PCA(PCA(:,1)==i),1)
        c = c+1;
        if j~=size(PCA(PCA(:,1)==i),1) 
            % Nouveaux intervalles temporels
            OIntT = [PCA(c,2), PCA(c+1,2)];
            NIntT = [NPCA(c,2), NPCA(c+1,2)];
            % Nouveaux ratio angulaire
            ORA = PCA(c+1,3) - PCA(c,3);
            NRA = NPCA(c+1,3) - NPCA(c,3);
        else
            OIntT = [PCA(c,2), PCA(c-j+1,2)+1.0];
            NIntT = [NPCA(c,2), NPCA(c-j+1,2)+1.0];
            % Nouveaux ratio angulaire
            ORA = PCA(c-j+1,3) - PCA(c,3);
            NRA = NPCA(c-j+1,3) - NPCA(c,3);
        end
        
        Alpha = ORA / NRA;
        
        % Selection de l'intervalle de détail correspondant
        O = fix((kO + OIntT(2)-OIntT(1)) * (S-1));
        N = fix((kN + NIntT(2)-NIntT(1)) * (S-1));
        
        OldInt = kO:1/(S-1):O/(S-1);
        NewInt = kN:1/(S-1):N/(S-1);
        
        sN = size(NewInt);
        
        % Attention a ne pas reprendre 2 fois le même point... Exclure une 
        % extr de l'int
        Sp1 = spline(OldInt,Details.Symetric(fix(OldInt*(S-1))+1,i)*Alpha,NewInt);
        Sp2 = spline(OldInt,Details.Asymetric(fix(OldInt*(S-1))+1,i)*Alpha,NewInt);
        
        TmpS = [TmpS , Sp1(1:end-1)];
        TmpA = [TmpA , Sp2(1:end-1)];
        s = size(TmpS);
        
        if j == size(PCA(PCA(:,1)==i),1)
            TmpS = [TmpS , Sp1(end), TmpS(1)];
            TmpA = [TmpA , Sp2(end), TmpA(1)];
            s = size(TmpS);
        end
        
        
%         if j==1
%             TmpS = [TmpS , Sp1];
%             TmpA = [TmpA , Sp2];
%         elseif isempty(TmpS) || isempty(Sp1)
%             TmpS = [TmpS , Sp1];
%             TmpA = [TmpA , Sp2];
%             warning('Pb')
%             warning('Merde ici');
%         elseif TmpS(end) == Sp1(1)
%             TmpS = [TmpS , Sp1(2:end)];
%             TmpA = [TmpA , Sp2(2:end)];
%         else
%             TmpS = [TmpS , Sp1];
%             TmpA = [TmpA , Sp2];
%         end
        
        kO = kO+(OIntT(2)-OIntT(1));
        kN = kN+(NIntT(2)-NIntT(1));
    end
%     c
%     i
%     s
%     sN
%     NewDetails.Symetric(:,i) = TmpS';Z
%     NewDetails.Asymetric(:,i) = TmpA';
    % A modifier, gestion dégueu ici
%     if max(size(TmpS)) == max(size(NewDetails.Symetric(:,i)))
%         NewDetails.Symetric(:,i) = TmpS';
%         NewDetails.Asymetric(:,i) = TmpA';
%     elseif max(size(TmpS)+1) == max(size(NewDetails.Symetric(:,i)))
%         
        NewDetails.Symetric(:,i) = spline(0:1/(size(TmpS,2)-1):1,TmpS,0:1/(size(NewDetails.Symetric(:,i),1)-1):1);%;TmpS(1)];
        NewDetails.Asymetric(:,i) = spline(0:1/(size(TmpA,2)-1):1,TmpA,0:1/(size(NewDetails.Asymetric(:,i),1)-1):1);%;TmpA(1)];
%     else
%         max(size(TmpS));
%         max(size(NewDetails.Symetric(:,i)));
%         warning('Pb taille Details');
%         if max(size(TmpS))>max(size(NewDetails.Symetric(:,i)))
%             TmpS = TmpS(1:end-abs(max(size(TmpS))-max(size(NewDetails.Symetric(:,i)))));
%             TmpA = TmpA(1:end-abs(max(size(TmpA))-max(size(NewDetails.Symetric(:,i)))));
%         else
%             TmpS = [TmpS(1:end), TmpS(1:abs(max(size(TmpS))-max(size(NewDetails.Symetric(:,i)))))];
%             TmpA = [TmpA(1:end), TmpA(1:abs(max(size(TmpA))-max(size(NewDetails.Symetric(:,i)))))];
%         end
%         NewDetails.Symetric(:,i) = TmpS';
%         NewDetails.Asymetric(:,i) = TmpA';
%     end
end



end

