function NewMarkers = AdaptMarkers(tmpMarkers,TargetMarkers)
% - Cuts down the number of fields of 'tmpMarkers' to the same as 'TargetMarkers'
% - Renames the fields of 'tmpMarkers' to the same as 'TargetMarkers'
% 

f = fieldnames(tmpMarkers);
tmpMarkers = struct2cell(tmpMarkers);
tmpMarkers = tmpMarkers(1:size(fieldnames(TargetMarkers),1));
tmpMarkers = cell2struct(tmpMarkers,f(1:size(fieldnames(TargetMarkers),1)));
NewMarkers = orderfields(tmpMarkers,TargetMarkers);

end

