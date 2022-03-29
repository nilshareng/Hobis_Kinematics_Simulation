function X = FindFootprints(Poulaine)
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here

Poul = Poulaine(:,1:3);
S = size(Poulaine,1);
X = zeros(6,5);

[~,b1] = min(Poul(:,3));
[~,b2] = min(Poul(:,2));
[~,b3] = max(Poul(:,2));

X(1,3:5) = Poul(b1,1:3);
X(2,3:5) = Poul(b2,1:3);
X(3,3:5) = Poul(b3,1:3);

X(1,2) = b1/(S-1);
X(2,2) = b2/(S-1);
X(3,2) = b3/(S-1);

X = [X(1:3,2:5) ; X(1:3,2:5)]; 
X(X(:,1)<=0,1) = 1+ X(X(:,1)<=0,1);

X(4:6,:) = [X(4:6,1) + 0.5 , X(4:6,2)*-1 , X(4:6,3:4)];
X(X(1:6,1)>1,1) = X(X(1:6,1)>1,1) -1;
X = [[2;2;3;5;5;6] , X];

% X = Xtreat(X);

end

