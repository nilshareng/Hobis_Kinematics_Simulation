clear all;
close all;
clc;

% Chemin d'acc�s aux .c3d et � l'excel compilant les donn�es de marche : 
p = 'C:\Users\nhareng\Desktop\CodeCommente\hobis\BDD\';

% R�cup�ration des donn�es de l'excel: 
% Format : Nom fichier / Frame d�but et fin cycle de marche / Frame initiale
% BornesMarches = Chiffres (BorneSup,BorneInf,FrameIni) ; Names = Noms
[BornesMarche, Names] = xlsread(strcat(p,'Classement_Pas.xlsx'),'A2:D78');

% D�f du dossier de r�c�ption des donn�es calcul�es pour ce batch
SavePath = 'C:\Users\nhareng\Desktop\CodeCommente\hobis\Resultats\Batch\11\';

% D�f du dossier contenant les donn�es pr�calcul�es :
% i.e. les Poulaines utilis�es comme cible, elles m�mes issues des 
% trajectoires angulaires de chaque fichier
PathPreSet = 'C:\Users\nhareng\Desktop\CodeCommente\hobis\Resultats\Batch\NewPresets\';
% Premi�re phase : Pour chaque fichier .c3d r�pertori� dans l'excel : -> Extraire les
% donn�es des marqueurs pendant le cycle de marche, lancer l'algo, puis sauver le r�sultat.
for ii=1%:11:length(Names)
    
    % Cr�ation d'un dossier pour cette marche - l� o� vont �tre stock�es toutes les donn�es calcul�es
    dirname= strcat(SavePath,Names{ii});
    mkdir(dirname);
    
    % Bornes = Frames D�but/Fin cycle de marche. Diff�rence avec la frame initiale pour l'initialisation  
    Bornes=[BornesMarche(ii,1)-BornesMarche(ii,3) BornesMarche(ii,2)-BornesMarche(ii,3)];
    
    % Taille de l'�chantillon de frames � s�lectionner
    Period = Bornes(2)-Bornes(1)+1;
    
    % Structure contenant les positions de marqueurs
    markers=struct;
    
    % Acquisition des marqueurs � partir des .c3d en 2�tapes
    % 1 - Acquisition
    TN{ii}=strcat(Names{ii},'.c3d');
    NewFile = strcat(p,TN{ii});
    a = btkReadAcquisition(NewFile);
    premarkers = btkGetMarkers(a);
    Tmp = struct2cell(premarkers);
    
    % 2 - Etape interm�diaire : Les noms, ordres, et nombres des marqueurs varient � chaque .c3d
    % Il faut donc rep�rer et s�lectionner ceux qui nous int�resse. 
    % S�lection G/D - FWT BWT KNE KNI ANE ANI
    
    % R�cup�ration des noms des marqueurs
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
    
    
    % Marqueurs acquis, Lancement de la premi�re phase de l'algorithme :
    % Cr�ations des rep�res articulaires, Filtrage, Cin�matique Inverse et
    % Approximation par Splines
    C3DUpdate2;

    for jj =1%:length(Names)
        % Deuxi�me phase, � la marche courante, on va successivement appliquer
        % les autres marches en tant que cibles.
        if size(Names{jj}(1:end-3),2)==size(Names{ii}(1:end-3),2)
        if Names{jj}(1:end-3)== Names{ii}(1:end-3)
            PreLoop;
            
            % Troisi�me phase, Boucle d'optimisation.
            Loop_Batch_Manip;
            close all;
            
            % Sauvegarde des donn�es dans des .mat importables
            save(strcat(dirname,'\',Names{jj},'P','.mat'),'Param','Saved','SNPCA','GT','Conv','PFin','TAFin','X','mem','Iflag','Storing')
        end
        end
    end
    
%     % Si besoin ici, sauvegarde des PreSets, ie donn�es utilis�es comme cibles
%     % dans la phase 2 et 3

%     close all;
%     save(strcat(PathPreSet,Names{ii},'.mat'),'PN','Pol','Param', 'R_monde_local','R_Pelvis_monde_local', 'R_LFem_ref_local', 'R_LTib_ref_local', 'R_RFem_ref_local', 'R_RTib_ref_local');
end
