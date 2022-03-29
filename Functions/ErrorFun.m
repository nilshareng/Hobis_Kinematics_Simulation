function [res,tmpderap] = ErrorFun(PolA,X,Param, R_monde_local,R_Pelvis_monde_local, R_LFem_ref_local, R_LTib_ref_local, R_RFem_ref_local, R_RTib_ref_local)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
tmpsum=[];
tmpderap=[];
tmpderav=[];
for i=1:size(X,1)
    %%% Eval des thetas à ti
    tmpa=  zeros(3,11);
    for j = 1:11
        tmpa(1,j) = EvalSpline(PolA(PolA(:,1)==j,:),X(i,2));
        tmpa(2,j) = EvalSpline(PolA(PolA(:,1)==j,:),X(i,2)+0.001);
        tmpa(3,j) = EvalSpline(PolA(PolA(:,1)==j,:),X(i,2)-0.001);
    end
    
    tmp = fcine_numerique_H2(tmpa(1,:),Param(:,1)',Param(:,2)',Param(:,3)',Param(:,4)',Param(:,5)',Param(:,6)', R_monde_local,R_Pelvis_monde_local, R_LFem_ref_local, R_LTib_ref_local, R_RFem_ref_local, R_RTib_ref_local)';%,Fem1g,Fem6g,Tal1g,Fem1d,Fem6d,Tal1d);
    tmp2= fcine_numerique_H2(tmpa(2,:),Param(:,1)',Param(:,2)',Param(:,3)',Param(:,4)',Param(:,5)',Param(:,6)', R_monde_local,R_Pelvis_monde_local, R_LFem_ref_local, R_LTib_ref_local, R_RFem_ref_local, R_RTib_ref_local)';%,Fem1g,Fem6g,Tal1g,Fem1d,Fem6d,Tal1d);
    tmp3= fcine_numerique_H2(tmpa(3,:),Param(:,1)',Param(:,2)',Param(:,3)',Param(:,4)',Param(:,5)',Param(:,6)', R_monde_local,R_Pelvis_monde_local, R_LFem_ref_local, R_LTib_ref_local, R_RFem_ref_local, R_RTib_ref_local)';%,Fem1g,Fem6g,Tal1g,Fem1d,Fem6d,Tal1d);
    
    if(X(i,1)<4)
%         tmpsum = [tmpsum ; X(i,3:5) - tmp(1:3)];
        tmpsum = [tmpsum ; tmp(1:3)];
        tmpderap=[tmpderap ; (-tmp(X(i,1))+tmp2(X(i,1)) ) /0.001];
        tmpderav=[tmpderav ; (tmp(X(i,1))-tmp3(X(i,1)) ) /0.001];
    else
%         tmpsum = [tmpsum ; X(i,3:5) - tmp(4:6)];
        tmpsum = [tmpsum ; tmp(4:6)];
        tmpderap=[tmpderap ; (-tmp(X(i,1))+tmp2(X(i,1)) ) /0.001];
        tmpderav=[tmpderav ; (tmp(X(i,1))-tmp3(X(i,1)) ) /0.001];
    end
end
tmpderap = ((tmpderav + tmpderap)/2);
res = tmpsum;
end
