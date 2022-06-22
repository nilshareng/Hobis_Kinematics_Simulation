function X = Xtreat(X,bool)
% Symétrisation, rangement, ntm
% Sym
if size(X,2)==5
    X = [X(1:3,2:5) ; X(1:3,2:5)];
end
X = [X(1:3,:) ; X(1:3,:)];
X(4:6,:) = [X(4:6,1) + 0.5 , X(4:6,2)*-1 , X(4:6,3:4)];

%Rangement ini si demandé;
if nargin <= 1
    X = [X(:,1) , X(:,3) , -1*X(:,2) , X(:,4)];
elseif nargin>2
    error('Input');
end
%Rangement ordonné
X(X(1:6,1)>1,1) = X(X(1:6,1)>1,1) -1;
X = [[2;2;3;5;5;6] , X];
end


