function [cost] = KinforMinAllMarkers(Angles,Sequence,Markers,Reperes,TargetMarkers,TargetPos)% [cost, Cdists, Sdists] = KinforMinAllMarkers(Angles,Sequence,Markers,Reperes,TargetMarkers,TargetPos)
% TargetMarkers contains the position to match for the desired set of
% markers
% Markers MUST AT LEAST contain all the fields of TargetMarkers
cost = 0;

if nargin == 6
    tmp = {};
    for i = 0:fix(size(TargetPos,2)/3)-1 
        tmp{i+1} = TargetPos(3*i+1:3*(i+1));
    end
    Targets = cell(tmp);
    Tfields = TargetMarkers;
    
elseif nargin == 5
    Targets = struct2cell(TargetMarkers);
    Tfields = fieldnames(TargetMarkers);
end


[~, tmpMarkers] = fcinematique(Angles,Sequence,Markers,Reperes);

tmpMarkers = AdaptMarkers(tmpMarkers,TargetMarkers);



CurrentPos = struct2cell(tmpMarkers);
dists = {};

for i = 9:max(size(Targets))
    cost = cost + norm(Targets{i} - CurrentPos{i})^2;
    %     dists{i} = Targets{i} - CurrentPos{i};
end

% Cdists = dists';
% Sdists = cell2struct(dists', Tfields);

end

