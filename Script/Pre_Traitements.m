%%% Handles the difference between loading a .c3d walk and a simple model

flag.prints = 1;
flag.IntermX = 1;

% Load Initial Gait - Gait to be transformed / 11 * 100 vector of joint coordinates in splines

MaxReachL = norm(Markers.LTal1 - Markers.LFem6) + norm(Markers.LFem6 - Markers.LHRC) + norm(Markers.LHRC - [0 0 0]);
MaxReachR = norm(Markers.RTal1 - Markers.RFem6) + norm(Markers.RFem6 - Markers.RHRC) + norm(Markers.RHRC - [0 0 0]);
MaxReach = (MaxReachL+MaxReachR)/2;

% GData = GaitFromPath(InitialGaitPath);
Period = size(KinModelC3D.TA,1);
% GData.ROGait = [-1*GData.ROGait(:,1),GData.ROGait(:,2) ,GData.ROGait(:,3),-1*GData.ROGait(:,4),GData.ROGait(:,5) ,GData.ROGait(:,6)];
model.gait = KinModelC3D.Poulaine/1000;

%% Compute full Initial Articular Trajectories corresponding to Initial Gait - Full IK, puis Spline 
% IK :
anglesR2I = zeros(11,1);

J = [];
PosC = model.gait(1,:); 
deltaX = 0;
Angles = zeros(((max(size(model.gait)))+1)*10,11);
Angles(1,:) = anglesR2I';   
NAngles = Angles(1,:);
d = 0.01;
thresh = 0.01;

% Premiere IK pour positionner en Ref ---> All markers 
NAngles = zeros(11,1);
Target= model.gait(1,:)';
Target = [Rmarkers.LTal1' ; Rmarkers.RTal1']/1000;
Angles = zeros(11,1);
KinforMin(Angles,Sequence,Target,Markers,Reperes)
options = optimset('TolFun',1e-5);
AnglesDesc2Ref = fminsearch(@(Angles) KinforMin(Angles,Sequence,Target,Markers,Reperes),NAngles,options);
[CurrentPos] = fcinematique(AnglesDesc2Ref,Sequence,Markers,RReperes);
error = CurrentPos*1000 - [Rmarkers.LTal1' ; Rmarkers.RTal1'];
norm(error);

%%% Fonctionnel au dessus

% Deuxieme IK pour positionner en frame initiale de la marche
TmpAngles = zeros(1,11);
thresh = 0.01;
options = optimset('TolFun',thresh);
mem = [];
steplength=0.01;
globaltarget = [model.gait(1,1:3) , model.gait(1,4:6)]';
globalerror = [];
globalerror =  [globalerror , globaltarget - CurrentPos];
[CurrentPos, Cmarkers, Creperes] = fcinematique(TmpAngles,Sequence,Markers,RReperes);

TmpMarkers = Markers;
TmpMarkers.LTarget = globaltarget(1:3)*1000;
TmpMarkers.RTarget = globaltarget(4:6)*1000;
currenttarget = CurrentPos + (globaltarget-CurrentPos) / norm(globaltarget-CurrentPos) * steplength;
TmpMarkers.CRTarget = currenttarget(4:6)*1000;
TmpMarkers.CLTarget = currenttarget(1:3)*1000;
c = 0;

options = optimset('Display','Iter','TolFun',1e-5);
NewAngles = [];
NewPoul = [];

A = model.gait(:,3);
B = model.gait(:,6);

A = A - (max((max(abs(A)*1000 - MaxReach)),0) - (max(abs(A)*1000))*0.05)*0.001;
B = B -  (max((max(abs(B)*1000 - MaxReach)),0) - (max(abs(B)*1000))*0.05)*0.001;

model.gait(:,3) = A;
model.gait(:,6) = B;

N=[]; 
for i = 1:size(model.gait,1)
    N = [N ; norm(model.gait(i,1:3)), norm(model.gait(i,4:6))];
end
MaxPoul = max(max(N))*1000;

PoulaineRatio = 1;
if MaxPoul > MaxReach 
    PoulaineRatio = MaxReach / (MaxPoul+100) ;
end

%% IK sur plusieurs markers pour le cycle de marche


X = FindFootprints(KinModelPrints.Poulaine*10^-3);
X = [X(2,:) ; X(2,:); X(2,:) ;X(5,:) ; X(5,:) ; X(5,:)];

% KinModelInput = struct;
% KinModelInput.Markers = NRMarkers;
% KinModelInput.Reperes = RReperes;
% KinModelInput.ParamPhy = NRParam;

% ScaledKinModelInput = ScalingKinModel(KinModelC3D,KinModelInput);

% KinModelInput.

% [RReperes, RSeq, NRmarkers, NRParam]

tmpMarkers = AdaptMarkers(Markers,KinModelC3D.Markers);

[c] = KinforMinAllMarkers(zeros(1,11),Sequence,Markers,RReperes,tmpMarkers);

% IK fminsearch
if 1
    Angles = AnglesDesc2Ref;
    NAngles = zeros(11,1);
    CellTargetMarkers = struct2cell(KinModelC3D.Markers);
    Period = max(size(CellTargetMarkers{1}));

    options = optimset('TolFun',1e-5,'MaxIter',1000);
    
    NewPoul = [];
    GaitMarkers = [];
    NewAngles = [];
    s = 10;
    
    for i = 1:max(size(CellTargetMarkers{1}))
        CycleTargetMarkers = {};
        for j = 1:max(size(fieldnames(KinModelC3D.Markers)))
            CycleTargetMarkers{j} = CellTargetMarkers{j}(i,:);
        end
        CycleTargetMarkers = cell2struct(CycleTargetMarkers',fieldnames(KinModelC3D.Markers));
        
        Angles = AnglesDesc2Ref;
        
        AnglesDesc2Ref = fminsearch(@(Angles) ...
            KinforMinAllMarkers(Angles,Sequence,Markers,Reperes,CycleTargetMarkers),NAngles,options);
        
        RA = AnglesDesc2Ref;
        
        AnglesDesc2Ref = fminsearch(@(Angles) ...
            KinforMinAllMarkersL(Angles,Sequence,Markers,Reperes,CycleTargetMarkers),NAngles,options);
        
        LA = AnglesDesc2Ref;
        
        AnglesDesc2Ref = [(RA(1)+LA(1))/2 , (RA(2)+LA(2))/2 , (RA(3)+LA(3))/2 ,...
            RA(4) , RA(5) , RA(6) , RA(7) , ...
            LA(8) , LA(9) , LA(10) , LA(11)]';
        
        [CurrentPos, Cmarkers, Creperes] = fcinematique(AnglesDesc2Ref,Sequence,Markers,RReperes);
        

%         DisplayMarkers(AdaptMarkers(Cmarkers,KinModelC3D.Markers),7);
%         DisplayMarkers(cell2struct(CellTargetMarkers,fieldnames(KinModelC3D.Markers)),7);
        
        NewAngles = [NewAngles ; AnglesDesc2Ref'];
        
        GaitMarkers = [GaitMarkers,Cmarkers];
        NewPoul = [NewPoul ; CurrentPos'];
%         DisplayMarkers(CycleTargetMarkers,9);
%         DisplayMarkers(Cmarkers,9);
    end
end

freq=5;
[b,a] = butter(2 , freq/(0.5*Period) , 'low');
S = size(NewAngles, 1);
NewAnglesF=filtfilt(b,a,NewAngles);

GaitMarkers = [];
NewPoul = [];

for i = 1:max(size(CellTargetMarkers{1}))
    [CurrentPos, Cmarkers, Creperes] = fcinematique(NewAnglesF(i,:),Sequence,Markers,RReperes);
    NewPoul = [NewPoul ; CurrentPos'];

    GaitMarkers = [GaitMarkers,Cmarkers];
end
DisplayGait(GaitMarkers,8);
error = CurrentPos*1000 - [Rmarkers.LTal1' ; Rmarkers.RTal1'];%/1000
norm(error);

for i =1:size(model.gait,1)
    GaitMarkers(i).LOPoul = NewPoul(:,1:3)*1000;
    GaitMarkers(i).ROPoul = NewPoul(:,4:6)*1000;
    GaitMarkers(i).X = X(:,3:5)*1000;
end


%%% Filtering the noisy results
freq=5;
[b,a] = butter(2 , freq/(0.5*Period) , 'low');
S = size(NewAngles, 1);
NewAnglesF=filtfilt(b,a,[NewAngles ; NewAngles ; NewAngles]);
GaitMarkers2 = [];
NewPoul2 = [];

for i = 1:Period
    [tmp, tmpMarkers, tmpReperes] = fcinematique(NewAnglesF(S+i,:),Sequence,Markers,RReperes);
    GaitMarkers2 = [GaitMarkers2,tmpMarkers];
    
    NewPoul2 = [NewPoul2 ; tmp'];
end
    
[b,a] = butter(2 , freq/(0.5*Period) , 'low');
NewPoulF=filtfilt(b,a,[NewPoul; NewPoul; NewPoul]);
rate = Period;
%%% Display 
f=figure;
hold on;
model.invgait = [model.gait(:,4:6) , model.gait(:, 1:3)];
for i = 1:6
    subplot(2,3,i)
    hold on;
    plot(NewPoulF(size(NewPoul,1)+1:2*size(NewPoul,1),i));
    plot(NewPoul2(:,i));
    plot(model.gait(:,i));
end

figure;
hold on;
for i = 1:11
    subplot(4,3,i)
    plot(NewAnglesF(S+1:2*S,i));
end

NewPoulF = NewPoulF(size(NewPoul,1)+1:2*size(NewPoul,1),:);
% DisplayGait(GaitMarkers,7);

NewAnglesF = NewAnglesF(S+1:2*S,:);

%%
close all;
MarkersReference = Markers;
% NewPoul = NewPoul';
% figure;
% for i=1:6
%     subplot(2,3,i)
%     hold on;
%     plot([NewPoulF(:,i);NewPoulF(1,i)]);
% %     plot(model.gait(:,i));
% %     plot(model.Ngait(:,i));
% end
% Approximation par spline des Traj Angulaires
PolA = [];
SplinedAngles = [];
tmp = GaitSymetrisation(NewAnglesF);

for i = 1:11
        [Var , PolT] = Curve2Spline(tmp(:,i));
        SplinedAngles(:,i) = Var';
        PolA = [PolA ; [i*ones(size(PolT(:,2:end),1),1) , PolT(:,2:end)]];
end

% Symetrisation
% NewCurve = GaitSymetrisation(SplinedAngles);
NewCurve=SplinedAngles;

PCA = ForgePCA(SplinedAngles,0:1/(rate-1):1 ,1 );

Details = struct;
Details.Asymetric = NewAnglesF - tmp;
Details.Symetric = tmp - NewCurve;

% Expression de la poulaine correspondante à l'approximation TA
ComputedPoulaine =[];
for i = 1:max(size(NewCurve))
    ComputedPoulaine = [ComputedPoulaine ; fcinematique(NewCurve(i,:),Sequence, MarkersReference, RReperes)'];
end

% NewSplines
PolP = [];
SplinedComputedPoulaine = [];
for i = 1:6
        [Var, PolT] = Curve2Spline(ComputedPoulaine(:,i));
        SplinedComputedPoulaine(:,i) = Var';
        PolP = [PolP ; [i*ones(size(PolT(:,2:end),1),1) , PolT(:,2:end)]];
end

tmpPCA = ForgePCA(SplinedAngles,0:1/(rate-1):1 ,1 );
Cheat = tmpPCA(tmpPCA(:,1)<=2,:);
Cheat(2:2:end,2) = Cheat(1:2:end,2) + 0.5;
Cheat(2:2:end,3) = -1*Cheat(1:2:end,3);
tmpPCA(tmpPCA(:,1)<=2,:) = Cheat;
NPCA = [tmpPCA(tmpPCA(:,1)<=2,:) ; PCA(PCA(:,1)>2,:)];

NPolA = [];
for i = 1:11
    temp = PC_to_spline(NPCA(NPCA(:,1)==i,2:3),1);
    NPolA = [NPolA ; i*ones(size(temp,1),1), temp(:,2:end)];
end

[tmpP2, tmpTA2] = Sampling_txt(NPolA,Period,Sequence,Markers,Reperes);


%% Affichages comparatif

% Setting up variables to plug into the PreLoop / Loop
PN = SplinedComputedPoulaine;

GT = model.gait;
Pol = PolA;
mid = fix(max(size(SplinedComputedPoulaine,1))/2);
NewCurve = SplinedAngles;






















%%%