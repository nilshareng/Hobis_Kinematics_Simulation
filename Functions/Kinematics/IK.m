function NewAngles = IK(Targets, Threshold, Angles, Param, Reperes,x0)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here

if size(Angles,2)~=1
   Angles = Angles';
end
if size(Targets,2)~=6
    Targets = Targets';
end

options = optimset('TolFun',Threshold);

NewAngles = x0;

for i = 1:size(Targets,1)
    NAngles=  NewAngles(:,end);
    NewAngles =[NewAngles, fminsearch(@(Angles) KinforMin(Angles,Targets(i,:),Param,Reperes),NAngles,options)];
end
    
end

