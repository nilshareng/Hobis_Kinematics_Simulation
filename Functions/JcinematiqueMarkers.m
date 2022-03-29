function J = JcinematiqueMarkers(Angles,Sequence,Markers,Reperes,TargetMarkers)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
da = 0.001;
[~, IniMarkers] = fcinematique(Angles,Sequence,Markers,Reperes);
IniMarkers = AdaptMarkers(IniMarkers,TargetMarkers);

PosIni = MarkersStruct2Vector(IniMarkers);

J = zeros(max(size(struct2cell(IniMarkers))*3),max(size(Angles)));

for i = 1:max(size(Angles))
    deltaA = zeros(size(Angles));
    deltaA(i) = da;
    [~, CurrentMarkers] = fcinematique(Angles+deltaA,Sequence,Markers,Reperes);
    CurrentMarkers = AdaptMarkers(CurrentMarkers,TargetMarkers);
    
    PosC = MarkersStruct2Vector(CurrentMarkers);
    
%     PosC = struct2cell(CurrentMarkers);
    
    DX = PosC - PosIni;
    
    J(:,i) = DX*10^-3/da;
end

end


