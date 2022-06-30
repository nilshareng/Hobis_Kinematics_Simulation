function [NewX, NewPoulaineCible] = Ratio2merde(XP1,P1,XP2,P2,MaxReach)
% XP1 --> Empreintes Poulaine d'entrée
% P1 --> Poulaine d'entrée
% XP2 --> Empreintes d'entrée
% P2 --> Poulaine des empreintes d'entrée
% MaxReach --> Maximum length of kin chain (best if counting with joint limits...)
% NewX --> duh
% NewPoulaineCible --> duh
NewX = XP2;
NewPoulaineCible = P1;

XP1 = XP1(1:3,:);
XP2 = XP2(1:3,:);
TXP1 = XP1;
TXP2 = XP2;

% Check if the Poulaines are reachable / Adapt them and the footprints to ensure reachability 
N = [];
for i = 1:size(P1,1)
    N = [N ;norm(P1)]; 
end
R = 1;
if  max(N)>MaxReach
    R = MaxReach/max(N);
end


TXP1(:,3:end) = TXP1(:,3:end)*R;
TP1 = P1*R;
N = [];
for i = 1:size(P2,1)
    N = [N ;norm(P2)]; 
end
R = 1;
if  max(N)>MaxReach
    R = MaxReach/max(N);
end
TXP2(:,3:end) = TXP2(:,3:end)*R;
TP2 = P2*R;

% Compute the DXs X12 - X11 // X22 - X21

[~,b1] = sort(TXP1(:,5));
[~,b2] = sort(TXP2(:,5));

DX1 = norm(XP1(b1(1),3:5) - XP1(b1(2),3:5)); 
DX2 = norm(XP2(b2(1),3:5) - XP2(b2(2),3:5)); 

XRatio = DX2/DX1;

% Ratio them // adapt X1 to match X2 // Ratio P1 accordingly // check reachability

TP1 = TP1 * XRatio; % --> X2X1 length equal
TXP1(:,3:5) = TXP1(:,3:5) * XRatio;

% Displace to match deltaed footprints

DX11 = TXP2(b2(2),3:5) - TXP1(b1(2),3:5);

NewPoulaineCible = TP1(:,1:3) + DX11;
NewX = TXP1(:,3:5)+ DX11;
NewPoulaineCible = MirrorPoulaine(NewPoulaineCible,1);


% Check if the Poulaines are reachable / Adapt them and the footprints to ensure reachability 
N = [];
for i = 1:size(P1,1)
    N = [N ;norm(P1)]; 
end
R = 1;
if  max(N)>MaxReach
    R = MaxReach/max(N);
end


TXP1(:,3:end) = TXP1(:,3:end)*R;
TP1 = P1*R;
N = [];
for i = 1:size(P2,1)
    N = [N ;norm(P2)]; 
end
R = 1;
if  max(N)>MaxReach
    R = MaxReach/max(N);
end
TXP2(:,3:end) = TXP2(:,3:end)*R;
TP2 = P2*R;


% 3D Check Display

% Display3DCurves(P1,1);
% Display3DCurves(P2,1);
% Display3DCurves(NewPoulaineCible,1);
% Display3DCurves(XP1,1);
% Display3DCurves(XP2,1);
% Display3DCurves(TXP1,1);
% Display3DCurves(TXP2,1);

% legend('Inp 1', 'Inp 2', 'Out');

% DropRoll&Cry


end

