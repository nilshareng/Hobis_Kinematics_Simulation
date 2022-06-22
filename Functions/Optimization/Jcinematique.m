function J = Jcinematique(Angles,Sequence,Markers,Reperes)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
da = 0.001;
PosIni = fcinematique(Angles,Sequence,Markers,Reperes);
J = zeros(max(size(PosIni)),max(size(Angles)));

for i = 1:max(size(Angles))
    deltaA = zeros(size(Angles));
    deltaA(i) = da;
    PosC = fcinematique(Angles+deltaA,Sequence,Markers,Reperes);
    deltaX = PosIni - PosC;
    J(:,i) = deltaX/da;
end

end


