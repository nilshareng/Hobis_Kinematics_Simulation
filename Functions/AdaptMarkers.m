function NewMarkers = AdaptMarkers(tmpMarkers,TargetMarkers)
% Entries : Two Markers struct. tmpMarkers contains more fields than the TargetMarkers. 
% TargetMarkers MUST at least contain 

% Outs : A new Marker struct with the fields of TargetMarkers
% - Cuts down the number of fields of 'tmpMarkers' to the same as 'TargetMarkers'
% - Renames the fields of 'tmpMarkers' to the same as 'TargetMarkers'
% 

f = fieldnames(tmpMarkers);
tmpMarkers = struct2cell(tmpMarkers);
tmpMarkers = tmpMarkers(1:size(fieldnames(TargetMarkers),1));
tmpMarkers = cell2struct(tmpMarkers,f(1:size(fieldnames(TargetMarkers),1)));
NewMarkers = orderfields(tmpMarkers,TargetMarkers);

end

