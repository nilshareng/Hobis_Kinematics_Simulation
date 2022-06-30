function [P] = DisplayModel(Markers,N,fields)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here

if nargin == 1
    f =figure;
elseif nargin == 2
    f =figure(N);
elseif nargin == 3
    f =figure(N);
    if iscell(Markers)
        Markers = cell2struct(Markers,fields,1);
    end
end
f.WindowState='maximized';


hold on;

Pelv = [Markers.RBWT(1:3) ; Markers.LBWT(1:3) ; Markers.LFWT(1:3) ; Markers.RFWT(1:3) ; Markers.RBWT(1:3) ; Markers.RFWT(1:3) ; (Markers.RFWT(1:3) + Markers.LFWT(1:3))/2 ];%; Markers.RHRC ; (Markers.RFWT(1:3) + Markers.LFWT(1:3))/2 ; Markers.LHRC];
LFem = [Markers.LHRC(1:3) ; Markers.LKNE(1:3) ; Markers.LFem6(1:3) ; Markers.LFem9(1:3) ; Markers.LHRC(1:3) ; Markers.LFem6(1:3)]; 
LTib = [Markers.LKNI(1:3) ; Markers.LANE(1:3) ; Markers.LTal1(1:3) ; Markers.LANI(1:3) ; Markers.LTib6(1:3) ; Markers.LKNI(1:3) ; Markers.LTib1(1:3) ; Markers.LTal1(1:3) ];
RFem = [Markers.RHRC(1:3) ; Markers.RKNE(1:3) ; Markers.RFem6(1:3) ; Markers.RFem9(1:3) ; Markers.RHRC(1:3) ; Markers.RFem6(1:3)]; 
RTib = [Markers.RKNI(1:3) ; Markers.RANE(1:3) ; Markers.RTal1(1:3) ; Markers.RANI(1:3) ; Markers.RTib6(1:3) ; Markers.RKNI(1:3) ; Markers.RTib1(1:3) ; Markers.RTal1(1:3) ];

LSide = [Pelv ; LFem ; LTib];
RSide = [RFem ; RTib];

P(1) = plot3(Pelv(:,1), Pelv(:,2), Pelv(:,3),'-');
P(2) = plot3(LFem(:,1), LFem(:,2), LFem(:,3),'-');
P(3) = plot3(LTib(:,1), LTib(:,2), LTib(:,3),'-');
P(4) = plot3(RFem(:,1), RFem(:,2), RFem(:,3),'-');
P(5) = plot3(RTib(:,1), RTib(:,2), RTib(:,3),'-');

RC = [(Markers.RFWT(1:3) + Markers.LFWT(1:3))/2 ; Markers.LHRC ; Markers.RHRC ; Markers.LFem6 ; Markers.RFem6]; 

P(6) = plot3(RC(:,1), RC(:,2), RC(:,3),'ko');

% xlim([-600 600]);
% ylim([-600 600]);
% zlim([-1000 200]);
end

