%%% Handles the difference between loading a .c3d walk and a simple model

flag.prints = 1;
flag.IntermX = 1;

% Load Initial Gait - Gait to be transformed / 11 * 100 vector of joint coordinates in splines

MaxReachL = norm(Markers.LTal1 - Markers.LFem6) + norm(Markers.LFem6 - Markers.LHRC) + norm(Markers.LHRC - [0 0 0]);
MaxReachR = norm(Markers.RTal1 - Markers.RFem6) + norm(Markers.RFem6 - Markers.RHRC) + norm(Markers.RHRC - [0 0 0]);
MaxReach = (MaxReachL+MaxReachR)/2;

GData = GaitFromPath(InitialGaitPath);
Period = size(GData.ROGait,1);
GData.ROGait = [-1*GData.ROGait(:,1),GData.ROGait(:,2) ,GData.ROGait(:,3),-1*GData.ROGait(:,4),GData.ROGait(:,5) ,GData.ROGait(:,6)];
model.gait = GData.ROGait;

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


KinModelC3D = Loadc3dKinModel('C:\Users\nhareng\Desktop\CodeCommente\hobis\Ressources\BDD\', ...
'hassane012','Classement_Pas.xlsx');

KinModelPrints = Loadc3dKinModel('C:\Users\nhareng\Desktop\CodeCommente\hobis\Ressources\BDD\', ...
'armel012','Classement_Pas.xlsx');

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
 %% Second IK - Using J
% 
% 
% tmpMarkers = AdaptMarkers(Markers,KinModelC3D.Markers);
% 
% [c] = KinforMinAllMarkers(zeros(1,11),Sequence,Markers,RReperes,tmpMarkers);
% 
% 
% NAngles = zeros(11,1);
% CellTargetMarkers = struct2cell(KinModelC3D.Markers);
% 
% NewPoul = [];
% GaitMarkers = [];
% NewAngles = [];
% s = 10;
% 
% [CurrentPos, Cmarkers, Creperes] = fcinematique(zeros(1,11),Sequence,Markers,RReperes);
% CurrentMarkerPos = AdaptMarkers(Cmarkers,KinModelC3D.Markers);
% PosC = struct2cell(CurrentMarkerPos);
% 
% DeltaX = {};
% 
% 
% for i = 1:max(size(CellTargetMarkers{1}))
%     tmp = AnglesDesc2Ref;
%     
%     i
%     
%     CycleTargetMarkers = {};
%     for j = 1:max(size(fieldnames(KinModelC3D.Markers)))
%         CycleTargetMarkers{j} = CellTargetMarkers{j}(i,:);
%     end
%     CycleTargetMarkers = cell2struct(CycleTargetMarkers',fieldnames(KinModelC3D.Markers));
%     GlobalTarget = struct2cell(CycleTargetMarkers);
%     
%     for j = 1:s
%         DeltaX = [];
%         for k = 1:max(size(PosC))
%             DeltaX = [DeltaX ; ((-GlobalTarget{k}' + PosC{k}')/(s+1-j))];
%         end
%         
%         J = JcinematiqueMarkers(tmp,Sequence,Markers,RReperes,KinModelC3D.Markers);
%         Jp = pinv(J);
%         deltatheta =  Jp * DeltaX*10^-3; 
% %         proj = Jp*J;
%         tmp = mod(tmp + deltatheta,2*pi);
%         
%     end
%     
%     
%     
%     [CurrentPos, Cmarkers, Creperes] = fcinematique(tmp,Sequence,Markers,RReperes);    
%     CurrentMarkerPos = AdaptMarkers(Cmarkers,KinModelC3D.Markers);
%     
%     PosC = struct2cell(CurrentMarkerPos);
%     
%     NewAngles = [NewAngles ; tmp'];
% 
%     GaitMarkers = [GaitMarkers,Cmarkers];
%     NewPoul = [NewPoul ; CurrentPos'];
% end
% 
% 
% 
% %%
% 
% 
% % Ik J
% NewPoul=[];
% 
% 
% 
% % % % % % % NewPoul = [];
% % % % % % % GaitMarkers = [];
% % % % % % % NewAngles = [];
% % % % % % % s = 20;
% % % % % % % 
% % % % % % % TargetFields = fieldnames(KinModelC3D.Markers);
% % % % % % % Period = max(size(CellTargetMarkers{1}));
% % % % % % % Angles = AnglesDesc2Ref;
% % % % % % % tmp = AnglesDesc2Ref;
% % % % % % % NAngles = zeros(11,1);
% % % % % % % CellTargetMarkers = struct2cell(KinModelC3D.Markers);
% % % % % % % 
% % % % % % % % Setting the current Markers positions - Reference posture
% % % % % % % [~ , CurrentPosMarkers , ~] = fcinematique(AnglesDesc2Ref,Sequence,Markers,RReperes);
% % % % % % % 
% % % % % % % CurrentPosMarkers = AdaptMarkers(CurrentPosMarkers,KinModelC3D.Markers);
% % % % % % % CurrentPos = MarkersStruct2Vector(CurrentPosMarkers);
% % % % % % % 
% % % % % % % for i = 1:20%max(size(CellTargetMarkers{1}))
% % % % % % %         CycleTargetMarkersCell = {};
% % % % % % %         for j = 1:max(size(fieldnames(KinModelC3D.Markers)))
% % % % % % %             CycleTargetMarkersCell{j} = CellTargetMarkers{j}(i,:);
% % % % % % %         end
% % % % % % %         
% % % % % % %         CycleTargetMarkers = MarkersStruct2Vector(cell2struct(CycleTargetMarkersCell',...
% % % % % % %             fieldnames(KinModelC3D.Markers)));
% % % % % % % %         tmp = AnglesDesc2Ref;
% % % % % % %         for j = 1:s
% % % % % % %             CycleLocalTargetMarkers =  CurrentPos + ((CycleTargetMarkers - CurrentPos)/(s+1-j));
% % % % % % %             
% % % % % % %             deltaX = (CurrentPos - CycleLocalTargetMarkers)/1000;
% % % % % % %             J = JcinematiqueMarkers(tmp,Sequence,Markers,Reperes,KinModelC3D.Markers);
% % % % % % % %             J(1:12,1:3) = zeros(12,3);
% % % % % % %             Jp = pinv(J);
% % % % % % %             deltatheta =  Jp * deltaX;
% % % % % % %             
% % % % % % %             tmp = tmp + deltatheta;
% % % % % % %             
% % % % % % %             [CP, CurrentPosMarkers] = fcinematique(tmp,Sequence,Markers,RReperes);
% % % % % % %             CurrentPos = MarkersStruct2Vector(CurrentPosMarkers,KinModelC3D.Markers);
% % % % % % %         end
% % % % % % %         NewAngles = [NewAngles ; tmp'];
% % % % % % % %         [CP, CurrentPosMarkers, Creperes] = fcinematique(tmp,Sequence,Markers,RReperes);
% % % % % % %         NewPoul = [NewPoul ; CP'];
% % % % % % %         GaitMarkers = [GaitMarkers,CurrentPosMarkers];
% % % % % % % end
% % % % % % % 
% % % % % % % DisplayCurves(NewPoul,1);
% % % % % % % DisplayCurves(NewAngles,2);
% % % % % % % DisplayCurves(KinModelC3D.Poulaine/1000,1);
% % % % % % % DisplayCurves(KinModelC3D.TA/1000,2);

%     for j = 1:s
% 
%         localtarget = CurrentPos + ((globaltarget - CurrentPos)/(s+1-j));
%         deltaX = CurrentPos - localtarget;
%         J = Jcinematique(TmpAngles,Sequence,Markers,RReperes);
%         Jp = pinv(J);
%         deltatheta =  Jp * deltaX; 
% %         proj = Jp*J;
%         tmp = tmp + deltatheta';
% %         deltatheta2 = ones(1,11)*0.001;
% %         delta2 = fminsearch(@(deltatheta2) ArticularCost(tmp,deltatheta2,proj,model.jointRangesMin, ...
% %             model.jointRangesMax),deltatheta2);
% %         tmp = tmp + (proj*delta2')';
%          
%         
% %         CurrentMarkers = cell2struct(struct2cell(CurrentMarkers),TargetFields);
%         
%     end
%     NewAngles = [NewAngles ; tmp];
%     [CurrentPos, Cmarkers, Creperes] = fcinematique(tmp,Sequence,Markers,RReperes);
%     
% %     Cmarkers.CRTarget = globaltarget(1:3)'*1000;
% %     Cmarkers.CLTarget = globaltarget(4:6)'*1000;
% %     Cmarkers.RPoul = model.gait(:,1:3)*1000;
% %     Cmarkers.LPoul = model.gait(:,4:6)*1000;
%     
%     
%     NewPoul = [NewPoul ; CurrentPos'];
% 
% end

% 


%%
% model.gait = model.gait  * PoulaineRatio;
% NewPoul=[];
% 
% GaitMarkers = [];
% s = 10;
% %%% "IK" Disgusting fminseach instead, cause it (kinda) works 
% for i =1:size(model.gait,1)
%     globaltarget = [model.gait(i,1:3) , model.gait(i,4:6)]';
% %     tmp = fminsearch(@(Angles) KinforMin(Angles,Sequence,globaltarget,Markers,Reperes),TmpAngles,options);
%     tmp = TmpAngles;
%     for j = 1:s
% %         localtarget = CurrentPos + ((globaltarget - CurrentPos)/norm(globaltarget - CurrentPos)) /10;
%         localtarget = CurrentPos + ((globaltarget - CurrentPos)/(s+1-j));
%         deltaX = CurrentPos - localtarget;
%         J = Jcinematique(TmpAngles,Sequence,Markers,RReperes);
%         Jp = pinv(J);
%         deltatheta =  Jp * deltaX; 
%         proj = Jp*J;
%         tmp = tmp + deltatheta';
%         deltatheta2 = ones(1,11)*0.001;
%         delta2 = fminsearch(@(deltatheta2) ArticularCost(tmp,deltatheta2,proj,model.jointRangesMin, ...
%             model.jointRangesMax),deltatheta2);
%         tmp = tmp + (proj*delta2')';
%         CurrentPos = fcinematique(tmp,Sequence,Markers,RReperes);
%     end
%     NewAngles = [NewAngles ; tmp];
%     [CurrentPos, Cmarkers, Creperes] = fcinematique(tmp,Sequence,Markers,RReperes);
%     Cmarkers.CRTarget = globaltarget(1:3)'*1000;
%     Cmarkers.CLTarget = globaltarget(4:6)'*1000;
%     Cmarkers.RPoul = model.gait(:,1:3)*1000;
%     Cmarkers.LPoul = model.gait(:,4:6)*1000;
%     
%     GaitMarkers = [GaitMarkers,Cmarkers];
%     
%     NewPoul = [NewPoul ; CurrentPos'];
% %     DisplayMarkers(Cmarkers,1,Creperes);
% %     pause(1/60); 
% 
% end
%%


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

% for i = 1:size(GaitMarkers.RFWT,1)
%     
%     DisplayMarkers(,2)
% end
%%%
%%
% %%
% for i = 1:1/steplength
% % c=0;
% % while norm(model.gait(1,:)' - CurrentPos)> thresh
% %     c=c+1
%     Target = (model.gait(1,:)' - CurrentPos);
%     Target = CurrentPos + (Target*steplength / norm(Target))*i;
%     TmpAngles = fminsearch(@(Angles) KinforMin(Angles,Target,DParam,DReperes),TmpAngles,options);
% %     if KinforMin(TmpAngles,Target,DParam,DReperes)>thresh
% %         Target = (CurrentPos + model.gait(1,:)')* i/50;
% %         TmpAngles = fminsearch(@(Angles) KinforMin(Angles,Target,DParam,DReperes),TmpAngles,options);
% %     end
%     CurrentPos = fcineshort(TmpAngles,DParam,DReperes);
%     mem = [mem, CurrentPos];
%     if size(mem,2)>2 && norm(mem(:,end-1)-mem(:,end))<thresh/10
%         warning('shit happened here')
%         break;
%     end
%     error = [error, CurrentPos - Target];
%     globalerror = [globalerror , (model.gait(1,:)' - CurrentPos)];
%     norm(error(:,end))
% end
% AnglesRef2Ini1 = TmpAngles;
% %%%
% % Target = model.gait(1,:)';
% % AnglesRef2Ini2 = fminsearch(@(Angles) KinforMin(Angles,Target,DParam,DReperes),AnglesRef2Ini1,options);
% % CurrentPos = fcineshort(AnglesRef2Ini2,DParam,DReperes);
% % CurrentPos - Target
% 
% 
% %%%
% test = zeros(11,1);
% option=[1 200*10 0.03 2 0.5 0.002];
% AnglesRef2Ini = MDS('KinforMin',test,AnglesDesc2Ref,Target,DParam,DReperes)
% fcineshort(AnglesRef2Ini,DParam,DReperes) - model.gait(1,:)'
% 
% 
% % IK sur le cycle de marche visé
% 
% x0 = AnglesDesc2Ref;
% NewAngles = IK(model.Ngait,thresh,NAngles,RParam,RReperes,x0)';
% figure;
% plot(NewAngles);
% 
% NewPoul= [];
% for i = 1:size(NewAngles,1)
%     NewPoul =[NewPoul, fcineshort(NewAngles(i,:), NRParam, RReperes)];
% end
% NewPoul = NewPoul';
% figure;
% for i=1:6
%     subplot(2,3,i)
%     hold on;
%     plot([NewPoul(:,i);NewPoul(1,i)]);
%     plot(model.gait(:,i));
%     plot(model.Ngait(:,i));
% end
% 
% %
% 
% for i = 1:(max(size(model.gait)))
%     if i == (max(size(model.gait)))
%         TargetX = model.gait(2,:)';
%     else
%         TargetX = model.gait(i+1,:)';
%     end
% %     deltaX = (TargetX - PosC);
% %     delta = norm(deltaX)*d;
%     
%     deltaX = (TargetX - PosC);
%     tmp = Angles(i,:);
%     figure;
%     hold on;
%     while (norm(deltaX) > thresh)
%         deltaX = (TargetX - PosC);
%         delta = (deltaX/norm(deltaX)) * d;
%         J = JacShort(NAngles, NRParam, RReperes);
%         NAngles = pinv(J)*delta;
%         PosC = fcineshort(NAngles, NRParam, RReperes);
%         tmp = tmp + NAngles';
%         plot(norm(deltaX));
%     end
%     i
% %     for j = 1:10
% %         deltaX = (TargetX - PosC);
% %         deltax = deltaX/delta*d*j;%(1/100-j);
% %         J = JacShort(NAngles, NRParam, RReperes);
% %         NAngles = pinv(J) * deltax;
% %         % TODO passer en fcineH3
% %         %     PosC = fcine_numerique_H2(NAngles,Param(:,1)',Param(:,2)',Param(:,3)',Param(:,4)',Param(:,5)',Param(:,6)', R_monde_local,R_Pelvis_monde_local, R_LFem_ref_local, R_LTib_ref_local, R_RFem_ref_local, R_RTib_ref_local);
% %         PosC = fcineshort(NAngles, NRParam, RReperes);
% %         
% %         Angles((i-1)*10+j,:) = NAngles';
% %     end
%     Angles(i+1,:) = tmp';
% end
% figure;
% plot(Angles)
% Angles = Angles(2:end-1,:);
% rate = 60;
% 
% angles = [];
% for i =10:10:600
%     angles =[angles ;Angles(i,:)]; 
% end
% Angles = angles;
% figure;
% plot(Angles);
% NewPoul = [];
% 
% for i = 1:size(Angles,1)
%     NewPoul =[NewPoul, fcineshort(Angles(i,:), NRParam, RReperes)];
% end
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

% figure(6);
% hold on;
% % DisplayCurves(tmpTA2,6);
% % DisplayCurves(SplinedAngles,6);
% 
% figure(2);
% hold on;
% % DisplayCurves(tmpP2,2);
% % DisplayCurves(ComputedPoulaine,2);
% for i = 1   :3
%     subplot(3,3,X(i,1));
%     hold on;
%     plot(X(i,2)*(size(PN,1)-2)+1,X(i,X(i,1)+2),'kx');
% end
% for i = 4:6
%     subplot(3,3,X(i,1));
%     hold on;
%     plot(X(i,2)*(size(PN,1)-2)+1,X(i,X(i,1)-1),'kx');
% end








%% Affichages comparatif

% if flag.prints
%        figure;
%        hold on;
%        title('Comparison loaded poulaine vs Splined poulaine');
%        for i = 1:6
%            subplot(2,3,i)
%            hold on;
%            plot(InitialGait(:,i));
%            plot(SplinedPoulaine(:,i));
%            plot(ComputedPoulaine(:,i));
%            plot(SplinedComputedPoulaine(:,i));
%        end
% end


% Setting up variables to plug into the PreLoop / Loop
PN = SplinedComputedPoulaine;

GT = model.gait;
Pol = PolA;
mid = fix(max(size(SplinedComputedPoulaine,1))/2);
NewCurve = SplinedAngles;
% for i = 1:max(size(SplinedAngles),1)
%     PCA = [PolA(i,1:2), EvalSpline(PolA(i,:),PolA(i,2)) ]; % PC : N X T : idNumber, Xvalue, Time value
% end
% for i = 1:max(size(SplinedComputedPoulaine))
%     PCP = [PolP(i,1:2), ]; % PC : N X T : idNumber, Xvalue, Time value
% end
% 





















%%%