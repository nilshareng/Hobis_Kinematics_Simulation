function J = JacShort(Angles, Param, Reperes)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
if size(Param,2)~=3
   Param = Param'; 
end
J = Jac_H3(Angles,Param(1,:),Param(2,:),Param(3,:),Param(4,:),Param(5,:),Param(6,:), Reperes.Monde, Reperes.Pelvis, Reperes.LFemurLocal, Reperes.LTibiaLocal, Reperes.RFemurLocal, Reperes.RTibiaLocal);
end

