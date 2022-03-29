clear all;
close all;
clc;

% Chemin d'accès aux .c3d et à l'excel compilant les données de marche : 
p = 'C:\Users\nhareng\Desktop\CodeCommente\hobis\BDD\';

% Récupération des données de l'excel: 
% Format : Nom fichier / Frame début et fin cycle de marche / Frame initiale
% BornesMarches = Chiffres (BorneSup,BorneInf,FrameIni) ; Names = Noms
[BornesMarche, Names] = xlsread(strcat(p,'Classement_Pas.xlsx'),'A2:D78');

% Déf du dossier de récéption des données calculées pour ce batch
SavePath = 'C:\Users\nhareng\Desktop\CodeCommente\hobis\Resultats\Batch\11\';

% Déf du dossier contenant les données précalculées :
% i.e. les Poulaines utilisées comme cible, elles mêmes issues des 
% trajectoires angulaires de chaque fichier
PathPreSet = 'C:\Users\nhareng\Desktop\CodeCommente\hobis\Resultats\Batch\NewPresets\';
% Première phase : Pour chaque fichier .c3d répertorié dans l'excel : -> Extraire les
% données des marqueurs pendant le cycle de marche, lancer l'algo, puis sauver le résultat.
for ii=1%:11:length(Names)
    
    % Création d'un dossier pour cette marche - là où vont être stockées toutes les données calculées
    dirname= strcat(SavePath,Names{ii});
    mkdir(dirname);
    
    % Bornes = Frames Début/Fin cycle de marche. Différence avec la frame initiale pour l'initialisation  
    Bornes=[BornesMarche(ii,1)-BornesMarche(ii,3) BornesMarche(ii,2)-BornesMarche(ii,3)];
    
    % Taille de l'échantillon de frames à sélectionner
    Period = Bornes(2)-Bornes(1)+1;
    
    % Structure contenant les positions de marqueurs
    markers=struct;
    
    % Acquisition des marqueurs à partir des .c3d en 2étapes
    % 1 - Acquisition
    TN{ii}=strcat(Names{ii},'.c3d');
    NewFile = strcat(p,TN{ii});
    a = btkReadAcquisition(NewFile);
    premarkers = btkGetMarkers(a);
    Tmp = struct2cell(premarkers);
    
    % 2 - Etape intermédiaire : Les noms, ordres, et nombres des marqueurs varient à chaque .c3d
    % Il faut donc repérer et sélectionner ceux qui nous intéresse. 
    % Sélection G/D - FWT BWT KNE KNI ANE ANI
    
    % Récupération des noms des marqueurs
    b= fieldnames(premarkers);
    for j = 3:size(b,1)
        tempName = b{j};
        tempName = tempName(end-3:end);
        switch tempName
            case 'RFWT'
                markers.RFWT = Tmp{j};
            case 'LFWT'
                markers.LFWT = Tmp{j};
            case 'RBWT'
                markers.RBWT = Tmp{j};
            case 'LBWT'
                markers.LBWT = Tmp{j};
            case 'LKNE'
                markers.LKNE = Tmp{j};
            case 'RKNE'
                markers.RKNE = Tmp{j};
            case 'LKNI'
                markers.LKNI = Tmp{j};
            case 'RKNI'
                markers.RKNI = Tmp{j};
            case 'LANE'
                markers.LANE = Tmp{j};
            case 'RANE'
                markers.RANE = Tmp{j};
            case 'LANI'
                markers.LANI = Tmp{j};
            case 'RANI'
                markers.RANI = Tmp{j};
            
            
        end
        
        
        
    end
    
    
    % Marqueurs acquis, Lancement de la première phase de l'algorithme :
    % Créations des repères articulaires, Filtrage, Cinématique Inverse et
    % Approximation par Splines
    C3DUpdate2;

    for jj =1%:length(Names)
        % Deuxième phase, à la marche courante, on va successivement appliquer
        % les autres marches en tant que cibles.
        if size(Names{jj}(1:end-3),2)==size(Names{ii}(1:end-3),2)
        if Names{jj}(1:end-3)== Names{ii}(1:end-3)
            PreLoop;
            
            % Troisième phase, Boucle d'optimisation.
            Loop_Batch_Manip;
            close all;
            
            % Sauvegarde des données dans des .mat importables
            save(strcat(dirname,'\',Names{jj},'P','.mat'),'Param','Saved','SNPCA','GT','Conv','PFin','TAFin','X','mem','Iflag','Storing')
        end
        end
    end
    
%     % Si besoin ici, sauvegarde des PreSets, ie données utilisées comme cibles
%     % dans la phase 2 et 3

%     close all;
%     save(strcat(PathPreSet,Names{ii},'.mat'),'PN','Pol','Param', 'R_monde_local','R_Pelvis_monde_local', 'R_LFem_ref_local', 'R_LTib_ref_local', 'R_RFem_ref_local', 'R_RTib_ref_local');
end
