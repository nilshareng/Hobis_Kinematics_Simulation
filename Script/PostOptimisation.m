
%% Selection de la meilleure solution

[~,d] = min(Conv(1,:));
Mem = Mem(d);

%%

% Log.TimeEndOpti = toc(Log.TimeIniOpti);
[Gait, GaitMarkers, GaitReperes] = Angles2Gait(tmpTA2,Sequence,Markers,Reperes,model.gait*1000, ...
    P*1000,SplinedComputedPoulaine*1000,X(:,3:5)*1000);%[model.gait(4:6,:)*1000, model.gait(1:3,:)*1000]);

close all;
% fFGait = DisplayGait(GaitMarkers);

% DisplayCurves(P,2);       
% DisplayCurves([P(:,4:6), P(:,1:3)],2);
% DisplayCurves(tmpTA2,3);
% DisplayCurves([tmpTA2(:,1:3), tmpTA2(:,8:11) , tmpTA2(:,4:7)],3);

Results = struct;
Results.Inputs = answer;
Results.Mem = Mem;
Results.Sequence = Sequence;
Results.Markers = Markers;
Results.Reperes = Reperes;
if exist('InitialGait')
    Results.InitialPoulaine = InitialGait;
    Results.InitialPoulaineScaled = model.gait;
    Results.InitialPoulaineScaledIK = NewPoul;
    Results.OriginalX = InputX;
    Results.EmpreintesPoulaineInput = PX;
    Results.PoulaineEmpreintesInput = OOPN;
    Results.PoulaineEmpreintesInputScaled = OPN;
else
    Results.Details = Details;
    Results.NewDetails = NewDetails;
end
Results.GaitData = GData;
Results.InitialSplinedPoulaine = SplinedComputedPoulaine;
Results.FinalPoulaine = P;
Results.TAPostIK = NewAngles;
Results.TAFinal = TA;
Results.InitialReference = model.reference;
Results.InitialDescription = model.description;
Results.InitialSplinedAngles = SplinedAngles;

Results.EmpreintesScaled = X;
Results.InitialPolynom = PolA;
Results.FinalPolynom = NPolA;
Results.IncrementalPCModification = pModifs;
Results.Convergence = Conv;
Results.NCycles = c;
Results.Logs = Log;
if exist('PolX')
    Results.TargetPolynom = PolX;
%     Results.Target = ;
end

% Results.Figure.Conv = fConv;
% Results.Figure.FinalGait = fFGait;
Results.MemoryEC = mV;
Results.MemoryPoulaine = SaveM;
Results.GaitMarkers = GaitMarkers;

if exist('KinModelC3D')
    Results.Model(1) = KinModelC3D;
    Results.Model(2) = KinModelPrints;
end
% DisplayGait(GaitMarkers,20,'4');

Spline = [];
I = 60;
for i = 1:11
    tmpPol = Pol(Pol(:,1)==i,:);
    TS2 = [];
    for tc= 0:1/I:1
        % Echantillonnage pour chaque Angle
        a= EvalSpline(tmpPol, tc);
        if(a==-10)
            P2=[];
            TA2=[];
           return; 
        end
        TS2 = [TS2;a];
    end
    Spline = [Spline, TS2];
end