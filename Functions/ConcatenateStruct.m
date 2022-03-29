function S3 = ConcatenateStruct(S1,S2,N)
%Concatenates S2 into S1 - for identical fieldnames, along dim N (def 1).

if nargin == 2
    dim = 1;
elseif nargin == 3
    dim = N;
end

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

