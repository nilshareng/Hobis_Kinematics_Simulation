function [res,tmpderap] = ErrorFun4(PolA,X,Sequence,Markers,Reperes)
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
    
    tmp = fcinematique(tmpa(1,:),Sequence,Markers,Reperes);
    tmp2= fcinematique(tmpa(2,:),Sequence,Markers,Reperes);
    tmp3= fcinematique(tmpa(3,:),Sequence,Markers,Reperes);
    
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
