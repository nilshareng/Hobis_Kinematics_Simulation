function [] = Anim3DParam(Curve,n,v,Param)
mvt = Curve;
mvt =[mvt ; mvt(2:end,:)];
figure(n);
for j=0:3
    for i=1:size(mvt,1)
        tracer_posture_PCA(mvt(i,:),j,Param); pause(v);
    end   
end
end

