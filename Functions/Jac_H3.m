function J = Jac_H3(Angles,Fem1g,Fem6g,Tal1g,Fem1d,Fem6d,Tal1d, R_monde_local,R_Pelvis_monde_local, R_LFem_ref_local, R_LTib_ref_local, R_RFem_ref_local, R_RTib_ref_local)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

da = 0.001;
PosIni = fcine_numerique_H3(Angles,Fem1g,Fem6g,Tal1g,Fem1d,Fem6d,Tal1d, R_monde_local,R_Pelvis_monde_local, R_LFem_ref_local, R_LTib_ref_local, R_RFem_ref_local, R_RTib_ref_local);
J = zeros(max(size(PosIni)),max(size(Angles)));

for i = 1:max(size(Angles))
    deltaA = zeros(size(Angles));
    deltaA(i) = da;
    PosC = fcine_numerique_H3(Angles+deltaA,Fem1g,Fem6g,Tal1g,Fem1d,Fem6d,Tal1d, R_monde_local,R_Pelvis_monde_local, R_LFem_ref_local, R_LTib_ref_local, R_RFem_ref_local, R_RTib_ref_local);
    deltaX = PosIni - PosC;
    J(:,i) = deltaX/da;
end

end

