%%% M�J 29/03/2022

%%% Script principal pour le lancer des batchs de tests
%%% Ce script agit comme la premi�re partie de 'MainBatch' :
%%% - D�claration des entr�es pour les diff�rentes simulations � lancer
%%% - Mise en forme compatible avec le format 'pop up' des variables
%%% utilisateurs de 'MainBatch'
%%% - Lancement des simulations dans la boucle finale
%%% - Sauvegarde des r�sultats en fin de simulation, puis effacement des
%%% donn�es superflues avant la simulation suivante.

%%% Entr�es : Contenu de 'definput' - mis par d�faut ci-dessous pour lancer
%%% une vingtaine de simulations sur les donn�es de \Ressources\BDD
%%% Sorties : Données issues de la boucle d'optimisation, sauvegard�es en .mat dans SavePath
%%% suivant la variable 'Savepath'

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
flag.logs = 1;

%% Input part

definput = {strcat(Path,'\Ressources\'),...
    strcat(Path,'\Ressources\description.txt'),...
    strcat(Path,'\Ressources\reference.txt'),...
    strcat(Path,'\Ressources\NewestPresets'),...
    strcat(Path,'\Ressources\NewPresets2\antho012.mat'),...
    '70',...
    '[45 45 45 20 45 30 110 20 45 30 110]',...
    '[-45 -45 -45 -90 -30 -60 15 -90 -30 -60 15]',...
    strcat(Path,'\Ressources\PoulainesBabouin\Frim_2-5kmh\1.txt'),...
    '1'... 
    '1'...
    '1'...
    '1'...
    }; % Last 4 are : toggle auto Ratio / Ratio X - Joints are Min/Max

% Selection des .c3d Contenus dans Ressources
RPath = strcat(Path,'\Ressources\BDD\');
Ressources = string(ls(RPath));
Ressources = char(Ressources(contains(Ressources,'.c3d')));

%% Partie immonde, à changer soit en selection de fichiers par utilisateur, soit en croisée de tous les fichiers de 'Ressources'

%%% Exemples de sélections de fichiers pour la simulation. 
%%% Chaque indice sous "Poulaines" correspond à un fichier de mocap dont
%%% est extrait une trajectoire de cheville d'entrée qui sera déformée par l'algo.
%%% 
%%% Chaque indice sous "Empreintes" correspond à un fichier de mocap dont
%%% est extrait des empreintes soit des coordonnées 3D de points d'intérêt
%%% de la cheville durant le cycle de marche.

% Poulaines

disp("Please select the input ankle trajectory files");
PoulaineFiles = uigetfile({'*.c3d';'*.txt'},'Select a file',strcat(Path,'\Ressources\BDD\'));
if size(PoulaineFiles,1)==1
    PoulaineFiles = {PoulaineFiles};
end

%Empreintes
disp("Please select the input footprints files");
FootprintsFiles = uigetfile({'*.c3d';'*.txt'},'Select a file',strcat(Path,'\Ressources\BDD\'));
if size(FootprintsFiles,1)==1
    FootprintsFiles = {FootprintsFiles};
end

%%
for iii = 1:size(PoulaineFiles,1)
    for jjj = 1:size(FootprintsFiles,1)
        %     % Loading the Footprints according to the FileSelect2 list
        %     load(strcat(RPath, Ressources(FileSelect2(iii),:)));
        %
        %     OPN = PN;
        
        % RaZ des variables, pourrait être évité en appellant une fonction pour
        % la simulation ...
        
        close all;
        clc;
        clearvars -except definput flag p Path RPath Ressources iii jjj X OX ...
            OPN FileNames PoulaineFiles FootprintsFiles
        
        % Fix temporaire : Les fichiers sélectionnés sont en dur ici, doivent
        % passer en dynamique selon la sélection au dessus (FileSelect)
        
        KinModelC3D = Loadc3dKinModel(strcat(Path,'\Ressources\BDD\'), ...
            PoulaineFiles{iii}(1:end-4),'Classement_Pas.xlsx');
        
        KinModelPrints = Loadc3dKinModel(strcat(Path,'\Ressources\BDD\'), ...
            FootprintsFiles{jjj}(1:end-4),'Classement_Pas.xlsx');
        
        % Poulaine the PoulaineFiles list
%         definput{5} = strcat(definput{4},KinModelC3D.Poulaine);
        definput{5}= {};
        % Script de simulation ci-dessous
        Formatage_Variables_Batch;
        
        Pre_Traitements;
        
        Boucle_Optimisation;
        
        PostOptimisation;

        
        % Sauvegarde des résultats
        save(strcat(Path, '\Resultats\', ...
            num2str(MaxLoop),'-PasModifs-', num2str(PasModifs),...
            '-PasDelta-', num2str(PasDelta), ...
            '-NoFMS--50-NoSecCost','.mat'),'Results');
    end
end

Results;

% PostTreatment(strcat(SavePath,'\Batch3\'));

