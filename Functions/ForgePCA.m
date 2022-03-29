function [PCA] = ForgePCA(Angles,interval,Option)
% Trouve des PCA pour une courbe sous format TA ie 11 DDL
% 2 PCA par courbe, 4 pour le genou 
% Retourne la liste des PCA, [DDL T Theta]
%                            [DDL T Theta]

PCA=[];
n = size(interval,2);

% Ici cas inutilisé, c'était pour les tests avant la BDD
if Option == 0   
    % Ici PCA écrits en dur
    for i = 1:11
        temp = find_control_points(Angles(:,i),interval');
        PCA=[PCA ; i*ones(size(temp,1),1) , temp];
    end
    
    PCA(1,2:end)=[0.0833, -0.1193];
    PCA = [PCA(1,:);PCA(4:end,:)];
    PCA(6,2:end)=[0.1 0.001767];
    PCA = [PCA(1:6,:);PCA(9:end,:)];
    
    PCA(:,2) = round(PCA(:,2),4);
    
    for i=1:7
        tmp = PCA(PCA(:,1)==i,2:3);
        [~,I]=sort(tmp(:,1));
        PCA(PCA(:,1)==i,2:3) = tmp(I,:);
    end
    
elseif Option == 1
    % Ici PCA déterminés
        for i = 1:11
            % Fonction qui trouve des candidats pour les PCA en temps que min/max locaux 
            temp = find_control_points(Angles(:,i),interval');
            % min locaux pas garantis avec la fonction de Matlab, donc si il n'en trouve pas 2 
            % On prend directement les globaux
            % Pas garantis dans le sens si le min/max est en première ou
            % dernière position, il ne sera pas detecté...
            if size(temp,1)<2
                [a1, b1]=max(Angles(:,i));
                [a2, b2]=min(Angles(:,i));
                 temp = [(b1-1)/(n-1) a1 ; (b2-1)/(n-1) a2];
            end
            % ça revient ici à prendre min et max globaux en fait
            [~,a] = max(temp(:,2));
            T = temp(a,:);
            temp = [temp(1:a-1,:) ; temp(a+1:end,:)];
            [~,b] = min(temp(:,2));
            T = [T ;temp(b,:)];
            temp = [temp(1:b-1,:) ; temp(b+1:end,:)];
            % A l'origine, il devait y avoir plus de PCA, d'où le bordel pour un simple min/max 
            
            if i== 3 || i==7 || i ==11 %|| i==4 ||i==8 %||i==5 ||i==9 
                % Pour les genoux (7 et 11 en DDL), il faut 4 points 
                if size(temp,1)<2
                    % Si il n'en détecte pas assez, on ne peut plus prendre
                    % les min/max globaux, car déjà présent.
                    % On prend donc un des extrêmes de l'interval
                    temp = [temp ; 1-1/(n-1) Angles(end-1,i)];
                    % Pour palier en cas de forme incongrue de la courbe du
                    % genou. 
                    if size(temp,1)<2
                        temp = [temp ; 0.5-1/(n-1) Angles(end-1,i)];
                    end
                end
                % Collecte
                [~,a] = max(temp(:,2));
                T = [T ;temp(a,:)];
                temp = [temp(1:a-1,:) ; temp(a+1:end,:)];
                [~,b] = min(temp(:,2));
                T = [T ;temp(b,:)];
                temp = [temp(1:b-1,:) ; temp(b+1:end,:)];
%             elseif i==3
%                 
            end
            
            
            % Assemblage du tableau des Points de Contrôles
            PCA=[PCA ; i*ones(size(T,1),1) , T];  
            
            % Rangement par ordre de t croissant
            temp = PCA(PCA(:,1)==i,2:3);
            [~,I]=sort(temp(:,1));
            PCA(PCA(:,1)==i,2:3) = temp(I,:);
        end
end
% Si un PCA est à 0, ça peut entraîner des divergences par la suite, donc on 
%le met à eps
for i =1:size(PCA,1)
    if PCA(i,2)==0
        PCA(i,2)=eps;
    end
end

end

