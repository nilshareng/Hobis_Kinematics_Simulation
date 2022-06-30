function cost = KinforMin(Angles,Sequence,Target,Markers,Reperes)
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here
cost = norm(Target - fcinematique(Angles,Sequence,Markers,Reperes));
end

