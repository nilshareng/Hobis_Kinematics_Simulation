function res = ErrorFun2(PolA,X,Param, R_monde_local,R_Pelvis_monde_local, R_LFem_ref_local, R_LTib_ref_local, R_RFem_ref_local, R_RTib_ref_local)
% Renvoie la position de cheville associée aux TA aux instants de X selon les Données physiologiques Param 
tmpsum=[];
for i=1:size(X,1)
    %%% Eval des angles à tX
    tmpa=  zeros(1,11);
    for j = 1:11
        tmpa(j) = EvalSpline(PolA(PolA(:,1)==j,:),X(i,2));
    end
    
    
    tmp = fcine_numerique_H2(tmpa,Param(:,1)',Param(:,2)',Param(:,3)',Param(:,4)',Param(:,5)',Param(:,6)', R_monde_local,R_Pelvis_monde_local, R_LFem_ref_local, R_LTib_ref_local, R_RFem_ref_local, R_RTib_ref_local);
    if(X(i,1)<4)
        tmpsum = [tmpsum ; tmp(1:3)'];
    else
        tmpsum = [tmpsum ; tmp(4:6)'];
    end
end
res = tmpsum;
end


