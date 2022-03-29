function [NewPCA,NPolA,Iflag,NewDetails] = ModifPCA(Modifs, NPCA, Period, Sequence, Markers, Reperes, InvE, mid,...
    Threshold, PCA, c, Cflag, rate, Iflag, Details)
% Fonction pour modifier des trajectoires articulaires splinées dans la
% boucle d'optimisation.
% Contient :
% - Ajout des modifications
% - Remise dans l'ordre des bornes
% - Symétrisation D/G
% - Mise à zéro des moyennes des courbes pelviennes
% - Recalcul des bornes des Trajectoires du pelvis
% - Recalcul des polynômes
% - Transformation des détails



% Initialisation des Polynômes des TA.
    NPolA = [];
      
    % Gestion des détails ? 
    
%     Modifs = zeros(size(Modifs));
%     Modifs(3) = 0.1;
%     Modifs = Modifs + NPCA;
    
    NewPCA = NPCA;
    
    % Update des PCA en ajoutant Modifs - Initialisé à 0
    for i = 1:size(PCA,1)
        NewPCA(i,2:3) = NewPCA(i,2:3) + [Modifs(2*i-1) , Modifs(2*i)];
        if c>1 % Ajout de l'erreur commise en cas de PCA éloignés de force 
            NewPCA(i,2:3) = NewPCA(i,2:3) + [InvE(i,c) ,0];
        end
        % 1-périodicité des PCA sur t
        NewPCA(i,2) = NewPCA(i,2) - fix(NewPCA(i,2));
    end
    
    % Passage sur un intervalle positif en vue de retourner sur [0 1]
    NewPCA(NewPCA(:,2)<0,2) = NewPCA(NewPCA(:,2)<0,2)+1;
    
    NPCA = NewPCA;
    
    
    % Compteur parce que la forme des PCA c'est dla merde pour certains calculs
    count=0;
       
    % Si on a touché aux PCA, on risque 2 PCA trop proches
    if c>1
        for i = 1:7
            % Pour chaque DDL qui n'est pas symétrisé
            tmP = NPCA(NPCA(:,1)==i,:);
            % On prend tous les PC d'un DDL, et on complère l'intervalle avec le premier +1 en t 
            tmP = [tmP;tmP(1,1),tmP(1,2)+1,tmP(1,3)];
            for j=1:size(tmP,1)-1
                % Pour les PC de ce DDL
                count = count +1;
                % Si le PC courant et son voisin suivant  sont trop proches
                if(abs(tmP(j,2) - tmP(j+1,2))<Threshold)
                    % Stockage de l'occurence, du cycle et du PC
                    Iflag = [Iflag, [c;i;j]];
                    if(tmP(j,2)-tmP(j+1,2)>0)
                        % S'ils ont été inversés lors des Modifs, remise dans l'ordre 
                        a=[tmP(j+1,:);tmP(j,:)];
                        tmP(j,:)= a(1,:);
                        tmP(j+1,:)=a(2,:);
                    end
                    
                    
                    if (j==size(tmP,1)-1) % Exception dans l'ordre s'il s'agit du dernier, vu que c'est le miroir du premier 
                        % Décalage des PCA trop proches
                        tmP(1,2)=tmP(1,2)+Threshold - (tmP(end,2) - tmP(j,2));
                        % Stockage et cumul des erreurs commises
                        InvE(count-j+1,c+1)=InvE(count-j+1,c)+abs(tmP(j,2) - tmP(j+1,2));
                    else % idem mais dans le cas général
                        tmP(j+1,2)=tmP(j+1,2)+Threshold - (tmP(j+1,2) - tmP(j,2));
                        InvE(count+1,c+1)=InvE(count+1,c)+abs(tmP(j,2) - tmP(j+1,2));
                    end
                end
            end
            % On récupère les PCA ordonnés, et séparés par au moins Threshold sur t 
            NPCA(NPCA(:,1)==i,:) = tmP(1:end-1,:);
        end
    end
    
    % PCA sur DDL 1 à 7 Séparés et ordonnées
    
    
    % Symétrisation Hard des PCA
    for i=8:11
        % On symétrise en déphasant
        NPCA(NPCA(:,1)==i,2:3)=[NPCA(NPCA(:,1)==i-4,2)+mid/Period, NPCA(NPCA(:,1)==i-4,3)];
        if i==9 || i==8
            % Et en inversant pour HY et HX
            NPCA(NPCA(:,1)==i,3)= -NPCA(NPCA(:,1)==i,3);
        end
        % Rangement des PCA dans l'ordre croissant de t
        NPCA(NPCA(:,1)==i,2) = NPCA(NPCA(:,1)==i,2)- fix(NPCA(NPCA(:,1)==i,2));
        tmp = NPCA(NPCA(:,1)==i,2:3);
        [~,I]=sort(tmp(:,2));
        NPCA(NPCA(:,1)==i,2:3) = tmp(I,:);
    end
 
    % Détection et rangement en cas d'inversion n°2
    for i=1:11
        tmp = NPCA(NPCA(:,1)==i,:);
        [tmp2,I] = sort(tmp(:,2));
        if (tmp2~=tmp(:,2))
            Cflag = [Cflag,[c;i]];
        end
        NPCA(NPCA(:,1)==i,:)=tmp(I,:);
    end 

    % To prevent crashes... Toujours le pb de t =0 pour un PCA...
    for i =1:size(NPCA,1)
        if NPCA(i,2)==0
            NPCA(i,2)=eps;
        end
    end
    
    % Calcul des Polynomes NPolA entre les NPCA
    for i = 1:11
        temp = PC_to_spline(NPCA(NPCA(:,1)==i,2:3),1);
        NPolA = [NPolA ; i*ones(size(temp,1),1), temp(:,2:end)];
    end
    
    % Phase supplémentaire : remise à 0 de moyenne des angles Pelviens
    [~, tmpTA] = Sampling_txt(NPolA,Period,Sequence,Markers,Reperes);
    
    % Recalcul des Points de contrôle sur le pelvis - nécessaire après la
    % mise à zéro artificielle de la moyenne
    tmpPC = ForgePCA(tmpTA,0:1/(rate-1):1 ,1 );
    Cheat = tmpPC(tmpPC(:,1)<=2,:);
    Cheat(2:2:end,2) = Cheat(1:2:end,2) + 0.5;
    Cheat(2:2:end,3) = -1*Cheat(1:2:end,3);
    tmpPC(tmpPC(:,1)<=2,:) = Cheat;
    NPCA = [tmpPC(tmpPC(:,1)<=2,:) ; NPCA(NPCA(:,1)>2,:)];
    
    % Recalcul du Polynôme correspondant
    NPolA = [];
    for i = 1:11
        temp = PC_to_spline(NPCA(NPCA(:,1)==i,2:3),1);
        NPolA = [NPolA ; i*ones(size(temp,1),1), temp(:,2:end)];
    end
    
    NewPCA = NPCA;

    % Gestion des détails, pour l'instant n'est pas pertinent dû à l'IK.
    NewDetails = AlterDetails(Details,NPCA,NewPCA);
end



%%% Ancien code avant fonction


% % Initialisation des Polynômes des TA.
%     NPolA = [];
%      
%     % Update des PCA en ajoutant Modifs - Initialisé à 0
%     for i = 1:size(PCA,1)
%         NPCA(i,2:3) = NPCA(i,2:3) + [Modifs(2*i-1) , Modifs(2*i)];
%         if c>1 % Ajout de l'erreur commise en cas de PCA éloignés de force 
%             NPCA(i,2:3) = NPCA(i,2:3) + [InvE(i,c) ,0];
%         end
%         % 1-périodicité des PCA sur t
%         NPCA(i,2) = NPCA(i,2) - fix(NPCA(i,2));
%     end
%     
%     % Passage sur un intervalle positif en vue de retourner sur [0 1]
%     NPCA(NPCA(:,2)<0,2) = NPCA(NPCA(:,2)<0,2)+1;
%     
%     % Compteur parce que la forme des PCA c'est dla merde pour certains calculs
%     count=0;
%        
%     % Si on a touché aux PCA, on risque 2 PCA trop proches
%     if c>1
%         for i = 1:s
%             % Pour chaque DDL qui n'est pas symétrisé
%             tmP = NPCA(NPCA(:,1)==i,:);
%             % On prend tous les PC d'un DDL, et on complère l'intervalle avec le premier +1 en t 
%             tmP = [tmP;tmP(1,1),tmP(1,2)+1,tmP(1,3)];
%             for j=1:size(tmP,1)-1
%                 % Pour les PC de ce DDL
%                 count = count +1;
%                 % Si le PC courant et son voisin suivant  sont trop proches
%                 if(abs(tmP(j,2) - tmP(j+1,2))<Threshold)
%                     % Stockage de l'occurence, du cycle et du PC
%                     Iflag = [Iflag, [c;i;j]];
%                     if(tmP(j,2)-tmP(j+1,2)>0)
%                         % S'ils ont été inversés lors des Modifs, remise dans l'ordre 
%                         a=[tmP(j+1,:);tmP(j,:)];
%                         tmP(j,:)= a(1,:);
%                         tmP(j+1,:)=a(2,:);
%                     end
%                     
%                     
%                     if (j==size(tmP,1)-1) % Exception dans l'ordre s'il s'agit du dernier, vu que c'est le miroir du premier 
%                         % Décalage des PCA trop proches
%                         tmP(1,2)=tmP(1,2)+Threshold - (tmP(end,2) - tmP(j,2));
%                         % Stockage et cumul des erreurs commises
%                         InvE(count-j+1,c+1)=InvE(count-j+1,c)+abs(tmP(j,2) - tmP(j+1,2));
%                     else % idem mais dans le cas général
%                         tmP(j+1,2)=tmP(j+1,2)+Threshold - (tmP(j+1,2) - tmP(j,2));
%                         InvE(count+1,c+1)=InvE(count+1,c)+abs(tmP(j,2) - tmP(j+1,2));
%                     end
%                 end
%             end
%             % On récupère les PCA ordonnés, et séparés par au moins Threshold sur t 
%             NPCA(NPCA(:,1)==i,:) = tmP(1:end-1,:);
%         end
%     end
%     
%     % PCA sur DDL 1 à 7 Séparés et ordonnées
%     
%     
%     % Symétrisation Hard des PCA
%     for i=8:11
%         % On symétrise en déphasant
%         NPCA(NPCA(:,1)==i,2:3)=[NPCA(NPCA(:,1)==i-4,2)+mid/Period, NPCA(NPCA(:,1)==i-4,3)];
%         if i==9 || i==8
%             % Et en inversant pour HY et HX
%             NPCA(NPCA(:,1)==i,3)= -NPCA(NPCA(:,1)==i,3);
%         end
%         % Rangement des PCA dans l'ordre croissant de t
%         NPCA(NPCA(:,1)==i,2) = NPCA(NPCA(:,1)==i,2)- fix(NPCA(NPCA(:,1)==i,2));
%         tmp = NPCA(NPCA(:,1)==i,2:3);
%         [~,I]=sort(tmp(:,2));
%         NPCA(NPCA(:,1)==i,2:3) = tmp(I,:);
%     end
%  
%     % Détection et rangement en cas d'inversion n°2
%     for i=1:11
%         tmp = NPCA(NPCA(:,1)==i,:);
%         [tmp2,I] = sort(tmp(:,2));
%         if (tmp2~=tmp(:,2))
%             Cflag = [Cflag,[c;i]];
%         end
%         NPCA(NPCA(:,1)==i,:)=tmp(I,:);
%     end 
% 
%     % To prevent crashes... Toujours le pb de t =0 pour un PCA...
%     for i =1:size(NPCA,1)
%         if NPCA(i,2)==0
%             NPCA(i,2)=eps;
%         end
%     end
% 
%     
%     % Calcul des Polynomes NPolA entre les NPCA
%     for i = 1:11
%         temp = PC_to_spline(NPCA(NPCA(:,1)==i,2:3),1);
%         NPolA = [NPolA ; i*ones(size(temp,1),1), temp(:,2:end)];
%     end
%     
%     % Phase supplémentaire : remise à 0 de moyenne des angles Pelviens
%     [~, tmpTA] = Sampling_txt(NPolA,Period,Sequence,Markers,Reperes);
%     
% %     tmpTA(:,1:3) = tmpTA(:,1:3) - mean(tmpTA(:,1:3));
%     
%     tmpPC = ForgePCA(tmpTA,0:1/(rate-1):1 ,1 );
%     Cheat = tmpPC(tmpPC(:,1)<=2,:);
%     Cheat(2:2:end,2) = Cheat(1:2:end,2) + 0.5;
%     Cheat(2:2:end,3) = -1*Cheat(1:2:end,3);
%     tmpPC(tmpPC(:,1)<=2,:) = Cheat;
%     NPCA = [tmpPC(tmpPC(:,1)<=2,:) ; NPCA(NPCA(:,1)>2,:)];
%     
%     NPolA = [];
%     for i = 1:11
%         temp = PC_to_spline(NPCA(NPCA(:,1)==i,2:3),1);
%         NPolA = [NPolA ; i*ones(size(temp,1),1), temp(:,2:end)];
%     end
% 
