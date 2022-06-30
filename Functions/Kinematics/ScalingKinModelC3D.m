function ScaledKinModel = ScalingKinModelC3D(KinModelInput,KinModelC3D)
%   Goal : Match 1st input kinematic model's segments to the closest
%   approximation of the 2nd by scaling
%   Scales a kinematic model's segments to match the dimensions of KinModelInput'
% 
% 

% 0 - New Model CS = Input Model CS

ScaledKinModel.Reperes = KinModelInput.Reperes;

% 1 - Matrix to align the pelvic coordinate systems from the 2 models

TMocap2Input = KinModelInput.Reperes.Pelvis * KinModelC3D.Reperes.Pelvis^-1;
Tmp = struct2cell(KinModelC3D.Markers);

% 2 - Set all the C3D markers in the new pelvic CS

for i=1:size(KinModelC3D.Markers)
    Tmp{i} = rotateAndCenter(Tmp{i}, [0 0 0], TPelvMocap2Input);
end

ScaledKinModel.Markers = cell2struct(Tmp{i},fieldnames(KinModelC3D.Markers));


% 3 - Pelvic Segment - Scaling on ZPelvis

ScaledPelvZ = norm(KinModelInput.Markers.RBWT - KinModelInput.Markers.LBWT)/ ...
    norm(KinModelC3D.Markers.RBWT - KinModelC3D.Markers.LBWT);

ScaledKinModel.Markers.RBWT = KinModelInput.Markers.RBWT * ...
    ScaledPelvZ * KinModeInput.Reperes.Pelvis(1:3,3);

ScaledKinModel.Markers.LBWT = KinModelInput.Markers.LBWT * ...
    ScaledPelvZ * KinModelInput.Reperes.Pelvis(1:3,3);
 
ScaledKinModel.Markers.RFWT = KinModelInput.Markers.RBWT * ...
    ScaledPelvZ * KinModelInput.Reperes.Pelvis(1:3,3);

ScaledKinModel.Markers.LFWT = KinModelInput.Markers.LBWT * ...
    ScaledPelvZ * KinModelInput.Reperes.Pelvis(1:3,3);

% 4 - Pelvic Segment - Scaling on XPelvis

ScaledPelvX = norm(KinModelInput.Markers.RFWT - KinModelInput.Markers.RBWT) / ...
    norm(KinModelC3D.Markers.RFWT - KinModelC3D.Markers.RBWT);

ScaledKinModel.Markers.RFWT = KinModelInput.Markers.RFWT * ...
     ScaledPelvX * KinModelInput.Reperes.Pelvis(1:3,1);
 
ScaledKinModel.Markers.LFWT = KinModelInput.Markers.LFWT * ...
     ScaledPelvX * KinModelInput.Reperes.Pelvis(1:3,1);
 
% 5 - HRC : Set as in the Input Model

ScaledKinModel.Markers.RHRC = KinModelInput.AC.RHip;
ScaledKinModel.Markers.LHRC = KinModelInput.AC.LHip;

% 6R Femur / Hip Segment : Scaling on YFem between mid FemPlat and HRC

ScaledFemR = norm(KinModelInput.Markers.RFem6 - KinModelInput.Markers.RBWT) / ...
    norm(KinModelC3D.AC.RKnee - KinModelC3D.AC.RHip);

ScaledKinModel.Markers.LKNE = KinModelInput.Markers.RFWT * ...
     ScaledPelvX * KinModelInput.Reperes.Pelvis(1:3,1);
 
% 6L Femur / Hip Segment : Scaling on YFem between mid FemPlat and HRC

ScaledFemL = norm(KinModelInput.Markers.LFem6 - KinModelInput.Markers.LBWT) / ...
    norm(KinModelC3D.AC.LKnee - KinModelC3D.AC.LHip);


% Transla FemPlat - TibPlat (and KRC) Set transla as in KinModelC3D (?)

% 7 Tibia / Leg Segment : Scaling on YTib between mid TibPlat and mid Ankle



end

