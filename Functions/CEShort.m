function [res] = CEShort(Poulaine,TA,M,Markers,Reperes)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
Fem1g = Markers.LHRC /1000 ; 
Fem1d = Markers.RHRC /1000;
Fem6g = Markers.LTib1 /1000;
Fem6d = Markers.RTib1 /1000;
Tal1g = Markers.LTal1 /1000;
Tal1d = Markers.RTal1 /1000;
R_monde_local = eye(3);
R_Pelvis_monde_local = Reperes.Pelvis(1:3,1:3) ;
R_LFem_ref_local = Reperes.LFemur1(1:3,1:3) ;
R_LTib_ref_local = Reperes.LTibia(1:3,1:3) ;
R_RFem_ref_local = Reperes.RFemur1(1:3,1:3) ;
R_RTib_ref_local = Reperes.RTibia(1:3,1:3) ;

res = CE(Poulaine,TA,M,Fem1g, Fem1d, Fem6g, Fem6d, Tal1g, Tal1d, R_monde_local,R_Pelvis_monde_local, R_LFem_ref_local, R_LTib_ref_local, R_RFem_ref_local, R_RTib_ref_local);
end

