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
%%% Sorties : Donn�es issues de la boucle d'optimisation, sauvegard�es en .mat dans SavePath
%%% suivant la variable 'Savepath'

clear all;
close all;
clc;    

p = genpath('.');
addpath(p);
%addpath("C:\Users\nhareng\Desktop\CodeCommente\hobis");

flag = struct;

flag.c3d = 0;
flag.txt = 0;
flag.dyn = 0;
flag.prints =0;

%% Input part
%Antho012 - Antho056

definput = {'C:\Users\nhareng\Desktop\CodeCommente\hobis\Ressources\',...
    'C:\Users\nhareng\Desktop\CodeCommente\hobis\Ressources\descriptionFuse.txt',...
    'C:\Users\nhareng\Desktop\CodeCommente\hobis\Ressources\referenceFuse.txt',...
    'C:\Users\nhareng\Desktop\CodeCommente\hobis\Ressources\Presets\',...
    '',...
    '70',...
    '[45 45 45 100 45 30 -110 20 45 30 -110]',...
    '[-45 -45 -90 -90 -30 60 15 -90 -30 -60 15]',...
    'C:\Users\nhareng\Desktop\CodeCommente\hobis\Resultats\Txt'...
    '1'... 
    '1'...
    '1'...
    '1'...
    }; % Last 4 are : toggle auto Ratio / Ratio X - Joints are Min/Max


RPath = 'C:\Users\nhareng\Desktop\CodeCommente\hobis\Ressources\AdaptedPresets\';
Ressources = ls(RPath);

% Poulaines
FileSelect1 = [1 1 1 3 ...
    12 ...
    12 12 12 14 ...
    23 ...
    23 23 23 25 ...
    34 ...
    34 34 34 36 ...
    45 ...
    45 45 45 47 ...
    56 ...
    ] + 2;

%Empreintes
FileSelect2 = [1 3 12 1 ... 
    1 ...
    12 14 23 12 ...
    12 ... 
    23 25 34 23 ...
    23 ...
    34 36 45 34 ...
    34 ...
    45 47 56 45 ...
    45 ...
    ] + 2;

% 
FileNames = {...
    'P_antho012_E_antho012', 'P_antho012_E_antho028' , 'P_antho012_E_armel012' , 'P_antho028_E_antho012', ...
    'P_armel012_E_antho012',...
    'P_armel012_E_armel012', 'P_armel012_E_armel028', 'P_armel012_E_hassane012', 'P_armel028_E_armel012', ...
    'P_hassane012_E_armel012',...
    'P_hassane012_E_hassane012', 'P_hassane012_E_hassane028' , 'P_hassane012_E_laurent012', 'P_hassane028_E_hassane012'...
    'P_laurent012_E_hassane012', ...
    'P_laurent012_E_laurent012', 'P_laurent012_E_laurent028' , 'P_laurent012_E_richard012', 'P_laurent028_E_laurent012'...
    'P_richard012_E_laurent012', ...
    'P_richard012_E_richard012', 'P_richard012_E_richard028' , 'P_richard012_E_seb012', 'P_richard028_E_richard012'...
    'P_seb012_E_richard012', ...
    };

for iii = 11:size(FileSelect1,2)
    % Loading the Footprints according to the FileSelect2 list
    load(strcat(RPath, Ressources(FileSelect2(iii),:)));
    
    OPN = PN;

    close all;
    clc;
    clearvars -except definput flag p RPath Ressources iii X OX OPN FileNames FileSelect1 FileSelect2
    % Poulaine loading according to the FileSelect1 list
    definput{5} = strcat(definput{4},Ressources(FileSelect1(iii),:));
    Formatage_Variables_Batch;
    save(strcat(SavePath, '\', ...
    FileNames{iii},num2str(MaxLoop),'-PasModifs-', num2str(PasModifs),'-PasDelta-', num2str(PasDelta), ...
    '-NoFMS--50-NoSecCost','.mat'),'Results');
end

Results;

% PostTreatment(strcat(SavePath,'\Batch3\'));
