%%% MàJ 06/09/2021
%%% Script principal pour le lancer de batchs de tests
%%% Entrées : Chemins précisés ci-dessous (p et PathPreSet) menant aux données c3d et aux trajectoires cibles
%%% Sorties : Données issues de la boucle d'optimisation, sauvegardées en .mat dans SavePath
clear all;
close all;
clc;

% Chemin local
Path = pwd;

% Ajouter les fichiers et sous fichiers dans le PATH matlab
addpath(genpath(Path));

flag = struct;

flag.c3d = 0;
flag.txt = 0;
flag.dyn = 0;
flag.prints =0;

%% Input part

prompt = ...
    {'Enter Ressources directory (absolute) path:',...
    'Enter Description Posture file (absolute) path:',...
    'Enter Reference Posture file (absolute) path:',...
    'Enter PreSets files directory (absolute) path:',...
    'Initial Poulaine (absolute) path:',...
    'Model Mass:', ...
    'Model Articular Range of Motion Min Boundaries in degrees (Pelv*3, RHip*3, RKnee*1, LHip*3, LKnee*1):',...
    'Model Articular Range of Motion Max Boundaries in degrees (Pelv*3, RHip*3, RKnee*1, LHip*3, LKnee*1):',...
    'Initial Footprints Path - either a .mat containing necessary variable, or an Ankle Traj file .mat or .txt',...
    'Footprints (target) left footstrike (gait% X Y Z):',...
    'Footprints (target) left toe off (gait% X Y Z):',...
    'Footprints (target) left min Z (gait% X Y Z):'...
    'Automatic Scaling of Ankle Traj & Footprints (to match the model) - 0 no / 1 yes',...
    'Desired scaling factors for Ankle Traj and Footprints (X Y Z , Pelvis reference)',...
    'Enter Save folder Path:'};
%     'Footprints (target) right footstrike (gait% X Y Z):',...
%     'Footprints (target) right toe off (gait% X Y Z):',...
%     'Footprints (target) right min Z (gait% X Y Z):'...
dlgtitle = 'Inputs';
dims = [1 120];
definput = {strcat(Path,'\Ressources\'),...
    strcat(Path,'\Ressources\description.txt'),...
    strcat(Path,'\Ressources\reference.txt'),...
    strcat(Path,'\Ressources\NewestPresets'),...
    strcat(Path,'\Ressources\NewPresets2\antho012.mat'),...
    '70',...
    '[45 45 45 20 45 30 110 20 45 30 110]',...
    '[-45 -45 -45 -90 -30 -60 15 -90 -30 -60 15]',...
    strcat(Path,'\Ressources\PoulainesBabouin\Frim_2-5kmh\1.txt'),...
    '[0.2000    0.0650   -0.0188   -0.7755]',...
    '[0.7333    0.1135    0.0585   -0.6367]',...
    '[0.2833    0.0656    0.0595   -0.7840]'...
    '1',...
    '[1 1 1]',...
    strcat(Path,'\Resultats\Txt')};

answer = inputdlg(prompt,dlgtitle,dims,definput);

model = struct;

p = answer{1};
DataDes = load(answer{2});
model.description = DataDes;

DataRef = load(answer{3});
model.reference = DataRef;

if isempty(answer{4})
    flag.presets = 1;
    mkdir p 'Presets'
    PathPreSet = strcat(answer{1},'Presets\');
else
    PathPreSet = answer{4};
    flag.presets = 0;
end

InitialGaitPath = answer{5};
if size(InitialGaitPath,2)==7
    InitialGaitPath = InitialGaitPath(:,2:end);
end
% model.gait = InitialGaitPath;

M = str2double(answer{6});

model.jointRangesMin = str2num(answer{7})*pi/180;
model.jointRangesMax = str2num(answer{8})*pi/180;

InitialPrintsPath = answer{9};

X = [str2num(answer{10}) ; str2num(answer{11}) ; str2num(answer{12})];%; str2num(answer{12}) ; str2num(answer{13}) ; str2num(answer{14})];

AutoScaleFlag = answer{13};

ScalingFactors = str2num(answer{14});

X = Xtreat(X,1);
InputX = X;

flag.steps = 1;
flag.txt = 1;
SavePath = answer{15};
Names = {DataDes(1:end-4)};

prompt = {...
    'Inertia - Pelvis segment, expressed at segment center of mass'...
    'Inertia - Hip segment, expressed at segment center of mass'...
    'Inertia - Leg segment, expressed at segment center of mass'...
    'Inertia Center of mass position (% of segment - proximal to distal)'};

dlgtitle = 'Inertial inputs';
dims = [1 110];
definput = {...
    '[60.8189 0 0 ; 0 60.8189 0 ; 0 0 52.1215]'...
    '[0.1807 0 0 ; 0 0.1807 0 ; 0 0  0.1481]'...
    '[0.0806 0 0 ; 0 0.0806 0 ; 0 0 0.0611]'...
    '[0.497,0.1,0.0465]'};

answerInertia = inputdlg(prompt,dlgtitle,dims,definput);

Inertie.Pelvis = str2num(answerInertia{1});
Inertie.Hip = str2num(answerInertia{2});
Inertie.Leg = str2num(answerInertia{3});
Inertie.Coef = str2num(answerInertia{4});


%%

% Si pas de données précalculées, faire tourner une fois en mettant presets
% à 1. - Dégueu, mais utilisé pour l'instant

% Première phase : Pour chaque fichier .c3d répertorié dans l'excel : -> Extraire les
% données des marqueurs pendant le cycle de marche, lancer l'algo, puis sauver le résultat.
for ii=1:length(Names)%1%:11:length(Names)
    
    % Création d'un dossier pour cette marche - là où vont être stockées toutes les données calculées
    dirname= strcat(SavePath,Names{ii});
%     mkdir(dirname);
    
    
    if flag.c3d
        
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
        b = fieldnames(premarkers);
        if flag.dyn
            for j = 1:size(b,1)
                tempName = b{j};
                if size(tempName,2) > 4
                    tempName = tempName(end-3:end);
                end
                %             tempName = tempName(end-3:end);
                switch tempName
                    case 'RASIS'
                        markers.RFWT = Tmp{j};
                    case 'LASIS'
                        markers.LFWT = Tmp{j};
                    case 'RPSIS'
                        markers.RBWT = Tmp{j};
                    case 'LPSIS'
                        markers.LBWT = Tmp{j};
                    case 'LECE'
                        markers.LKNE = Tmp{j};
                    case 'RECE'
                        markers.RKNE = Tmp{j};
                    case 'LICE'
                        markers.LKNI = Tmp{j};
                    case 'RICE'
                        markers.RKNI = Tmp{j};
                    case 'LEMAL'
                        markers.LANE = Tmp{j};
                    case 'RIMAL'
                        markers.RANE = Tmp{j};
                    case 'LIMAL'
                        markers.LANI = Tmp{j};
                    case 'REMAL' % REMAL et RIMAL inversés pour normal_walking_4
                        markers.RANI = Tmp{j};
                        
                        
                end
            end
            
        elseif flag.c3d
            for j = 3:size(b,1)
                tempName = b{j};
                if size(tempName,2) > 4
                    tempName = tempName(end-3:end);
                end
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
            
        end
        % Marqueurs acquis, Lancement de la première phase de l'algorithme :
        % Créations des repères articulaires, Filtrage, Cinématique Inverse et
        % Approximation par Splines
        
        C3DUpdate2;
        
    elseif flag.txt
        Period = 100;
%         [Dmarkers, DParam ]= HobisDataParser(DataDes);
        [Rmarkers, RParam ] = HobisDataParser(DataRef);
%         [DReperes DSeq NDmarkers NDParam] = ReperesFromMarkers(Dmarkers);
        [RReperes, RSeq, NRmarkers, NRParam] = ReperesFromMarkersCorrected(Rmarkers);
        A = zeros(1,11);   
        
        Sequence.Pelvis = 'xyz';
        Sequence.LHip = 'zyx';
        Sequence.LKnee = 'z';
        Sequence.RHip = 'zyx';
        Sequence.RKnee = 'z';
        
        [PosC,Markers,Reperes] = fcinematique([0 0 0 0 0 0 0 0 0 0 0], Sequence, Rmarkers, RReperes);
        
        DisplayMarkers(Markers,1,Reperes);
        
    end
    if flag.presets
        close all;
        save(strcat(PathPreSet,Names{ii},'.mat'),'PN','Pol','Param', 'R_monde_local','R_Pelvis_monde_local', 'R_LFem_ref_local', 'R_LTib_ref_local', 'R_RFem_ref_local', 'R_RTib_ref_local');
        jj=ii;
        PreLoop;
        save(strcat(PathPreSet,Names{ii},'.mat'),'PN','Pol','Param','X', 'R_monde_local','R_Pelvis_monde_local', 'R_LFem_ref_local', 'R_LTib_ref_local', 'R_RFem_ref_local', 'R_RTib_ref_local');
        
    else
        for jj =1%1:length(Names)%1:length(Names)-1
            %             jj
            % Deuxième phase, à la marche courante, on va successivement appliquer
            % les autres marches en tant que cibles.
            if size(Names{jj}(1:end-3),2)==size(Names{ii}(1:end-3),2) || flag.dyn
                if flag.dyn %Names{jj}(1:end-3)== Names{ii}(1:end-3) || flag.dyn
                    PreLoop;
                    
                    % Troisième phase, Boucle d'optimisation.
                    Loop_Batch;
                    close all;
                    
                    % Sauvegarde des données dans des .mat importables
                    save(strcat(dirname,'\',Names{jj},'P','.mat'),'Param','Saved','SNPCA','GT','Conv','PFin','TAFin','X','mem','Iflag','Storing')
                else
                    if flag.txt
                        
                        KinModelC3D = Loadc3dKinModel(strcat(Path,'\Ressources\BDD\'), ...
                            'hassane012','Classement_Pas.xlsx');
                        
                        KinModelPrints = Loadc3dKinModel(strcat(Path,'\Ressources\BDD\'), ...
                            'armel012','Classement_Pas.xlsx');
                        
                        Pre_Traitements;
                        PreLoop;
                        Boucle_Optimisation;
                        close all;
                    end
%                     PreLoop;
%                     Loop_Batch;
                    close all; % Just in case
                    
                    save(strcat(SavePath,'\',num2str(fix(clock)),'.mat'),'Results');
                end
            end
        end
    end
    %     % Si besoin ici, sauvegarde des PreSets, ie données utilisées comme cibles
    %     % dans la phase 2 et 3
    
end




