function ScaledKinModelInput = ScalingKinModel(KinModelInput,KinModelC3D)
%   Goal : Match 1st input kinematic model's segments to the closest
%   approximation of the 2nd by scaling
%   Scales a kinematic model's segments to match the dimensions of KinModelInput'
% 
% 

% 1 - Matrix to align the pelvic coordinate systems

TransfertPelvis = KinModelC3D.Reperes.Pelvis * KinModelInput.Reperes.Pelvis^-1;

ScaledKinModelInput.Reperes.Pelvis

% 2 - Align the BWT as close as possible - Scaling on ZPelvis

ScaledPelvZ = (norm(KinModelC3D.Markers.RBWT - KinModelC3D.Markers.LBWT)/ ...
    norm(KinModelInput.Markers.RBWT - KinModelInput.Markers.LBWT));

ScaledKinModelInput.Markers.RBWT = KinModelInput.Markers.RBWT + ...
     0.5 * ScaledPelvZ * KinModelInput.Reperes(1:3,3);
 
ScaledKinModelInput.Markers.LBWT = KinModelInput.Markers.LBWT + ...
     -0.5 * ScaledPelvZ * KinModelInput.Reperes(1:3,3);

% 3 - Align the FWT as close as possible - Scaling on XPelv

ScaledPelvX = (norm(KinModelC3D.Markers.RFWT - KinModelC3D.Markers.RBWT)/ ...
    norm(KinModelInput.Markers.RFWT - KinModelInput.Markers.RBWT));

ScaledKinModelInput.Markers.RFWT = KinModelInput.Markers.RFWT + ...
     0.5 * ScaledPelvX * KinModelInput.Reperes(1:3,1);
 
ScaledKinModelInput.Markers.LFWT = KinModelInput.Markers.LFWT + ...
     -0.5 * ScaledPelvX * KinModelInput.Reperes(1:3,1);
 
% 4 - HRC : Set as deduced in the 

ScaledKinModelInput.Markers.RHRC = KinModelC3D.AC.RHip;
ScaledKinModelInput.Markers.LHRC = KinModelC3D.AC.LHip;

% 5 Femur / Hip Segment : Scaling on YFem between mid FemPlat and HRC

ScaledHip = (norm(KinModelC3D.Markers.RFWT - KinModelC3D.Markers.RBWT)/ ...
    norm(KinModelInput.Markers.RFWT - KinModelInput.Markers.RBWT));

% Transla FemPlat - TibPlat (and KRC) Set transla as in KinModelC3D (?)

% 7 Tibia / Leg Segment : Scaling on YTib between mid TibPlat and mid Ankle



end

