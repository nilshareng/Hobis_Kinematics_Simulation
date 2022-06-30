function NewMarkers = AdaptMarkers(TargetFields,TargetCoordinates)
% Fonction d'harmonisation des champs de deux structures de type Markers.
% La fonction va restreindre les champs de 'TargetCoordinates' aux champs
% communs avec 'TmpMarkers'

% A utiliser dans le cas ou on souhaite comparer deux structures Markers
% issues de 2 markersets différents.
% i.e. issus d'un markerset .txt fourni par les Paléoanthropologues à 26 marqueurs 
% et d'un markerset de mocap en .c3d à 12-14 marqueurs
% 
% Entrées : Deux structures de type Markers : contenant des noms de
% marqueurs et des coordonnées 3D associées 
% e.g. : Markers.LANE == [X Y Z]
%

% Sorties : Une structure de type Markers 'NewMarkers', contenant les
% champs communs entre les deux structures d'entrée i.e. les marqueurs
% communs aux deux markersets. Les coordonnées sont issues de
% 'TargetCoordinates'

f = fieldnames(TargetFields);
TargetFields = struct2cell(TargetFields);
TargetFields = TargetFields(1:size(fieldnames(TargetCoordinates),1));
TargetFields = cell2struct(TargetFields,f(1:size(fieldnames(TargetCoordinates),1)));
NewMarkers = orderfields(TargetFields,TargetCoordinates);

end

