% Deuxieme partie de la branche 'Batch' de la simulation cinématique (cf schéma)

% Pour chaque simulation du 'Batch' : 
% Reformatage des données pour correspondre à la simulation cinématique
% 'manuelle'

answer = definput;

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

M = str2double(answer{6});

model.jointRangesMin = str2num(answer{7})*pi/180;
model.jointRangesMax = str2num(answer{8})*pi/180;

flag.steps = 1;
flag.txt = 1;

% Chemin de sauvegarde des données 
SavePath = answer{9};
Names = {DataDes(1:end-4)};

% Respectivement :
%     'Inertia - Pelvis segment, expressed at segment center of mass'...
%     'Inertia - Hip segment, expressed at segment center of mass'...
%     'Inertia - Leg segment, expressed at segment center of mass'...
%     'Inertia Center of mass position (% of segment - proximal to distal)'};
definput2 = {...
    '[60.8189 0 0 ; 0 60.8189 0 ; 0 0 52.1215]'...
    '[0.1807 0 0 ; 0 0.1807 0 ; 0 0  0.1481]'...
    '[0.0806 0 0 ; 0 0.0806 0 ; 0 0 0.0611]'...
    '[0.497,0.1,0.0465]'};

answerInertia = definput2;

Inertie.Pelvis = str2num(answerInertia{1});
Inertie.Hip = str2num(answerInertia{2});
Inertie.Leg = str2num(answerInertia{3});
Inertie.Coef = str2num(answerInertia{4});


%%
% 
[Rmarkers, RParam ] = HobisDataParser(DataRef);

[RReperes, RSeq, NRmarkers, NRParam] = ReperesFromMarkersCorrected(Rmarkers);
A = zeros(1,11);

Sequence.Pelvis = 'xyz';
Sequence.LHip = 'zyx';
Sequence.LKnee = 'z';
Sequence.RHip = 'zyx';
Sequence.RKnee = 'z';

[PosC,Markers,Reperes] = fcinematique([0 0 0 0 0 0 0 0 0 0 0], Sequence, Rmarkers, RReperes);

if flag.logs 
    disp('Formatage_Variables_Batch check'); 
end


