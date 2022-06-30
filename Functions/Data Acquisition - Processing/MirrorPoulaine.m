function P = MirrorPoulaine(Poulaine,mode)
%UNTITLED8 Summary of this function goes here
%   Detailed explanation goes here

if nargin == 1
    mode = 1;    
elseif nargin >2
   error('Too many inputs') 
end

[a,b] = size(Poulaine);

if a<b
    Poulaine = Poulaine';
end

Poulaine = Poulaine(1:end-1,:);

mid = ceil(size(Poulaine,1) / 2);

if mode == 1 % Left-side based symmetry
    Poulaine = Poulaine(:,1:3);
    P = [Poulaine , ...
    [-1*[Poulaine(mid:end,1) ; Poulaine(1:mid-1,1)] , ...
    [Poulaine(mid:end,2) ; Poulaine(1:mid-1,2)] , ...
    [Poulaine(mid:end,3) ; Poulaine(1:mid-1,3)] ]];
    
else % Right-side 
    if size(Poulaine)>3
        Poulaine = Poulaine(:,4:6);
    end
    Poulaine = Poulaine(:,1:3);
    P = [[-1*[Poulaine(mid:end,1) ; Poulaine(1:mid-1,1)] , ...
        [Poulaine(mid:end,2) ; Poulaine(1:mid-1,2)] , ...
        [Poulaine(mid:end,3) ; Poulaine(1:mid-1,3)] ] , ...
        Poulaine];
end

P = [P ; P(1,:)];

end

