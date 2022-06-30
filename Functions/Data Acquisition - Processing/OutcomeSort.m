function Ncycle = OutcomeSort(Mem)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

% CellMem = struct2cell(Mem);

min(Mem)
C=[];
for i = 1:size(Mem,1)
    
    C = [C, Mem(i).Conv(1)];
    
end
[~,i] = min(C);

Ncycle = i;

end

