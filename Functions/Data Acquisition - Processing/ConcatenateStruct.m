<<<<<<< Updated upstream
function S3 = ConcatenateStruct(S1,S2)
% Concatenation de structures partageant des champs.
% Les données stockées dans les champs de S2 communs avec S1 sont
% concaténées dans la structure de sortie.

% Entrées : 
% Deux structures S1 et S2 partageant des champs (fieldnames).

% Sorties : 
% S3 structure partageant les champs de S1. 
% Les valeurs stockées dans S2 dans des champs communs avec S1 sont
% concaténés dans les champs de S3.

F1 = fieldnames(S1);
F2 = fieldnames(S2);

if isempty(F1)
    S3 = S2;
    return;
end

C1 = struct2cell(S1);
C2 = struct2cell(S2);

for i = 1:size(F1,1)
    if any(strcmp(F1{i},F2))
        j = find(strcmp(F1{i},F2));
        C1{i} = [C1{i} ; C2{j}];
    end
end

S3 = cell2struct(C1,F1,1);

end

=======
function S3 = ConcatenateStruct(S1,S2)
% Concatenation de structures partageant des champs.
% Les données stockées dans les champs de S2 communs avec S1 sont
% concaténées dans la structure de sortie.

% Entrées : 
% Deux structures S1 et S2 partageant des champs (fieldnames).

% Sorties : 
% S3 structure partageant les champs de S1. 
% Les valeurs stockées dans S2 dans des champs communs avec S1 sont
% concaténés dans les champs de S3.

F1 = fieldnames(S1);
F2 = fieldnames(S2);

if isempty(F1)
    S3 = S2;
    return;
end

C1 = struct2cell(S1);
C2 = struct2cell(S2);

for i = 1:size(F1,1)
    if any(strcmp(F1{i},F2))
        j = find(strcmp(F1{i},F2));
        C1{i} = [C1{i} ; C2{j}];
    end
end

S3 = cell2struct(C1,F1,1);

end

>>>>>>> Stashed changes
