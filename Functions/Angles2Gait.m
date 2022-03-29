function [Gait, GaitMarkers, GaitReperes] = Angles2Gait(Angles,Sequence,Markers,Reperes,PoulaineIni,PoulaineFin,SplinedComputedPoulaine,X)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
GaitReperes = [];
GaitMarkers = [];
Gait = zeros(size(Angles,1),6);

for i = 1:size(Angles,1)
   [Gait(i,:), TmpMarkers , TmpReperes] = fcinematique(Angles(i,:),Sequence,Markers,Reperes);
   
   if nargin == 8
       TmpMarkers.LPoul = PoulaineIni(:,4:6);
       TmpMarkers.RPoul = PoulaineIni(:,1:3);
       TmpMarkers.LFPoul = PoulaineFin(:,4:6);
       TmpMarkers.RFPoul = PoulaineFin(:,1:3);
       TmpMarkers.LOPoul = SplinedComputedPoulaine(:,4:6);
       TmpMarkers.ROPoul = SplinedComputedPoulaine(:,1:3);
       TmpMarkers.X = X;
   end
   GaitMarkers = [GaitMarkers, TmpMarkers];
   GaitReperes = [GaitReperes, TmpReperes];
    
    
end
end

