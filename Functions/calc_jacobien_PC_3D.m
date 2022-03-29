function [J , V, Jer] = calc_jacobien_PC_3D(NPCA,NPolA, derflag, param, X, dp, M, Cost, JerkRef ,Fem1g, Fem1d, Fem6g, Fem6d, Tal1g, Tal1d, R_monde_local,R_Pelvis_monde_local, R_LFem_ref_local, R_LTib_ref_local, R_RFem_ref_local, R_RTib_ref_local)%,Fem1g, Fem6g,Tal1g,Fem1d,Fem6d,Tal1d)
%   Calcul de la Jacobienne sur la fonction d'erreur ErrorFun
% Prends les TA sous forme de Polynome de spline (NPCA et NPolA)
% derflag pour switcher entre tangente nulle (non fonctionnel) ou non 
% param n'est pas utilis� en g�n�ral, sert � ne r�cup�rer que le gradient d'une des t�ches secondaires
% X sert pour ErrorFun
% M pour le co�t �nerg�tique
% Cost et JerkRef pour �tablir la variation sans avoir � calculer la valeur initiale 

% Pour l'�chantillonnage
if size(dp,2)==3
    Int = dp(3);
else
    Int = 60;
end

% Au cas o� il manque une partie des NPCA (les DDLs).. Je sais pas d'o� �a vient... 
if size(NPCA,2)~= 3
    NPCA = [NPCA(1:size(NPCA,1)/2), NPCA(size(NPCA,1)/2+1:end)];
    NPCA = [NPolA(:,1),NPCA];
end


npca = size(NPCA,1);
npcp = size(X,1);
Count=0;

% Initialisation
V=[];
Jer = [];



% Partie avec la d�rivation pour tangente nulle - Cass�e - Passer au else
if derflag
    J=zeros(4*npcp,2*npca);
    [Ref, RefD] = ErrorFun(NPolA,X,[Fem1g', Fem6g', Tal1g', Fem1d', Fem6d', Tal1d']);
    
    for j=1:11  % Pour chaque angle
        tempPC = NPCA(NPCA(:,1)==j,2:3);
        S=size(tempPC,1);
        for k = 1:S*2   % Pour chaque abscisse et ordonn�e de chaque PC(angles)
            Count = Count +1;
            w=ceil(k/2);
            if(mod(k,2))    % Alt�ration soit de l'abs soit de l'ord du PC
                tempPC(w,1)=tempPC(w,1)+dp(1);
            else
                tempPC(w,2)=tempPC(w,2)+dp(2);
            end
            %%% G�n�ration des 2 nouveaux polynomes cr��s en changeant le PC actuel
            PolModif = NPolA(NPolA(:,1)==j,:);
            [Modifs , ~]= ModifPol(PolModif,tempPC,0,w);
            Tmp = NPolA;
            Tmp(NPolA(:,1)==j,:) = Modifs;
            PolModif = Tmp;
            
            [P,TA] = Sampling(PolModif,Int,Fem1g, Fem1d, Fem6g, Fem6d, Tal1g, Tal1d, R_monde_local,R_Pelvis_monde_local, R_LFem_ref_local, R_LTib_ref_local, R_RFem_ref_local, R_RTib_ref_local);
            
            if(isempty(P)||isempty(TA))
                J=[];
                V=[];
                Jer=[];
                return;
            end
            
            % calcul des gradients CE / Jerk
            if(mod(k,2))
                V = [V ; (CE(P,TA,M,Fem1g, Fem1d, Fem6g, Fem6d, Tal1g, Tal1d, R_monde_local,R_Pelvis_monde_local, R_LFem_ref_local, R_LTib_ref_local, R_RFem_ref_local, R_RTib_ref_local)-Cost) /dp(1)];
                Jer = [Jer; (Jerk(PolModif)-JerkRef)/dp(1)];
            else
                V = [V ; (CE(P,TA,M,Fem1g, Fem1d, Fem6g, Fem6d, Tal1g, Tal1d, R_monde_local,R_Pelvis_monde_local, R_LFem_ref_local, R_LTib_ref_local, R_RFem_ref_local, R_RTib_ref_local)-Cost) /dp(2)];
                Jer = [Jer; (Jerk(PolModif)-JerkRef)/dp(2)];
            end
            
            
            if(mod(k,2))    % Alt�ration soit de l'abs soit de l'ord du PC
                %             [tmp, tmp1]= ErrorFun(PolModif,X(:,1:2));
                [tmp, tmp1]= ErrorFun(PolModif,X,[Fem1g', Fem6g', Tal1g', Fem1d', Fem6d', Tal1d'], R_monde_local,R_Pelvis_monde_local, R_LFem_ref_local, R_LTib_ref_local, R_RFem_ref_local, R_RTib_ref_local);
                tmp = -1*(tmp-Ref)/dp(1);
                tmp1 = (tmp1-RefD)/dp(1);
                t=zeros(4*size(tmp,1),1);
                for a = 1:size(tmp,1)
                    t(4*a-3)=tmp(a,1);
                    t(4*a-2)=tmp(a,2);
                    t(4*a-1)=tmp(a,3);
                    t(4*a)=tmp1(a,1);
                end
                J(:,Count) = t;
            else
                [tmp, tmp1]= ErrorFun(PolModif,X,[Fem1g', Fem6g', Tal1g', Fem1d', Fem6d', Tal1d'], R_monde_local,R_Pelvis_monde_local, R_LFem_ref_local, R_LTib_ref_local, R_RFem_ref_local, R_RTib_ref_local);
                tmp = -1*(tmp-Ref)/dp(2);
                tmp1 = (tmp1-RefD)/dp(2);
                t=zeros(4*size(tmp,1),1);
                for a = 1:size(tmp,1)
                    t(4*a-3)=tmp(a,1);
                    t(4*a-2)=tmp(a,2);
                    t(4*a-1)=tmp(a,3);
                    t(4*a)=tmp1(a,1);
                end
                J(:,Count) = t;
            end
            
        end
    end
    % res = J;
    
    
    
    
else
    % Partie fonctionnelle
    % Initialisation de la matrice
    J=zeros(3*npcp,2*npca);
    
    % Co�t pr�cision de r�f�rence
    Ref = ErrorFun2(NPolA,X, [Fem1g', Fem6g', Tal1g', Fem1d', Fem6d', Tal1d'], R_monde_local,R_Pelvis_monde_local, R_LFem_ref_local, R_LTib_ref_local, R_RFem_ref_local, R_RTib_ref_local);
    a = Ref;
    Ref=[];
    for i =1:size(X,1)
        Ref = [Ref; X(i,3:end)-a(i,:)];
    end
    
    for j=1:11  % Pour chaque angle
        
        % S�l�ction des t et theta des PCs de cet angle
        tempPC = NPCA(NPCA(:,1)==j,2:3);
        
        % Nombre de PC pour cet angle
        S=size(tempPC,1);
        
        for k = 1:S*2   % Pour chaque abscisse et ordonn�e de chaque PC(angles)
            Count = Count +1; % Compteur
            
            w=ceil(k/2); % Une fois t en abs, une fois theta en ord
            
            if(mod(k,2))    % Alt�ration soit de l'abs soit de l'ord du PC
                tempPC(w,1)=tempPC(w,1)+dp(1);
            else
                tempPC(w,2)=tempPC(w,2)+dp(2);
            end
            
            
            %%% G�n�ration des 2 nouveaux intervalles cr��s en changeant le
            %%% PC courant
            PolModif = NPolA(NPolA(:,1)==j,:);
            [Modifs , ~]= ModifPol(PolModif,tempPC,0,w);
            Tmp = NPolA;
            
            Tmp(NPolA(:,1)==j,:) = Modifs;
            PolModif = Tmp;
            
            % Calcul des nouvelles Courbes g�n�r�es par ce nouveau Polyn�me
            [P,TA] = Sampling(PolModif,Int,Fem1g, Fem1d, Fem6g, Fem6d, Tal1g, Tal1d, R_monde_local,R_Pelvis_monde_local, R_LFem_ref_local, R_LTib_ref_local, R_RFem_ref_local, R_RTib_ref_local);
            
            % Si probl�me -> Exit
            if(isempty(P)||isempty(TA))
                J=[];
                V=[];
                Jer=[];
                return;
            end
            
            % calcul des gradients CE / Jerk
            if(mod(k,2))
                V = [V ; (CE(P,TA,M,Fem1g, Fem1d, Fem6g, Fem6d, Tal1g, Tal1d, R_monde_local,R_Pelvis_monde_local, R_LFem_ref_local, R_LTib_ref_local, R_RFem_ref_local, R_RTib_ref_local)-Cost) /dp(1)];
                Jer = [Jer; (Jerk(PolModif)-JerkRef)/dp(1)];
            else
                V = [V ; (CE(P,TA,M,Fem1g, Fem1d, Fem6g, Fem6d, Tal1g, Tal1d, R_monde_local,R_Pelvis_monde_local, R_LFem_ref_local, R_LTib_ref_local, R_RFem_ref_local, R_RTib_ref_local)-Cost) /dp(2)];
                Jer = [Jer; (Jerk(PolModif)-JerkRef)/dp(2)];
            end
            
            
            if(mod(k,2))    % Alt�ration soit de l'abs soit de l'ord du PC
                %             [tmp, tmp1]= ErrorFun(PolModif,X(:,1:2));
                tmp = ErrorFun2(PolModif,X,[Fem1g', Fem6g', Tal1g', Fem1d', Fem6d', Tal1d'], R_monde_local,R_Pelvis_monde_local, R_LFem_ref_local, R_LTib_ref_local, R_RFem_ref_local, R_RTib_ref_local);
%                 a=tmp;
%                 tmp=[];
%                 for i =1:size(X,1)
%                     tmp = [tmp; X(i,3:end)-a(i,:)];
%                 end
                
                % D�riv�e de l'erreur par rapport au PC courant
                tmp = (tmp-Ref)/dp(1);
                
                t=zeros(3*size(tmp,1),1);
                for a = 1:size(tmp,1)
                    t(3*a-2)=tmp(a,1);
                    t(3*a-1)=tmp(a,2);
                    t(3*a)=tmp(a,3);
                end
                % Compl�tion de la Matrice, Colonne par Colonne
                J(:,Count) = t;
            else % Sym�trie entre abscisse et oronn�e
                tmp = ErrorFun2(PolModif,X,[Fem1g', Fem6g', Tal1g', Fem1d', Fem6d', Tal1d'], R_monde_local,R_Pelvis_monde_local, R_LFem_ref_local, R_LTib_ref_local, R_RFem_ref_local, R_RTib_ref_local);
%                 a=tmp;
%                 tmp=[];
%                 for i =1:size(X,1)
%                     tmp = [tmp; X(i,3:end)-a(i,:)];
%                 end
                tmp = (tmp-Ref)/dp(2);
                
                t=zeros(3*size(tmp,1),1);
                for a = 1:size(tmp,1)
                    t(3*a-2)=tmp(a,1);
                    t(3*a-1)=tmp(a,2);
                    t(3*a)=tmp(a,3);
                end
                J(:,Count) = t;
            end
            
        end
    end
    
end



if param == 1
    J=V';
    V=[];
    Jer=[];
    return;
elseif param ==2
    J =Jer';
    Jer=[];
    V=[];
    return;
end
end





