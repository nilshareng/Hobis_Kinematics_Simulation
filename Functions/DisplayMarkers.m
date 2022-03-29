function DisplayMarkers(markers,N,reperes)

if nargin == 1
    figure;
    hold on;
elseif nargin == 2
    figure(N);
    hold on;
elseif nargin == 3
    figure(N);
    hold on;
    tmp = struct2cell(reperes);
    for i = 1:size(fieldnames(reperes),1)
        plot3(tmp{i}(1,4) , tmp{i}(2,4) , tmp{i}(3,4) , 'kx');
        plot3(tmp{i}(1,4) + tmp{i}(1,1)*30 , tmp{i}(2,4) + tmp{i}(2,1)*30 , tmp{i}(3,4) + tmp{i}(3,1)*30 , 'rx');
        plot3(tmp{i}(1,4) + tmp{i}(1,2)*30 , tmp{i}(2,4) + tmp{i}(2,2)*30 , tmp{i}(3,4) + tmp{i}(3,2)*30 , 'gx');
        plot3(tmp{i}(1,4) + tmp{i}(1,3)*30 , tmp{i}(2,4) + tmp{i}(2,3)*30 , tmp{i}(3,4) + tmp{i}(3,3)*30 , 'bx');
    end
end
hold on;

if any(strcmp('RTarget',fieldnames(markers)))
    plot3(markers.RTarget(1),markers.RTarget(2),markers.RTarget(3),'rx');
end
if any(strcmp('LTarget',fieldnames(markers)))
    plot3(markers.LTarget(1),markers.LTarget(2),markers.LTarget(3),'rx');
end
if any(strcmp('CRTarget',fieldnames(markers)))
    plot3(markers.CRTarget(1),markers.CRTarget(2),markers.CRTarget(3),'bo');
end
if any(strcmp('CLTarget',fieldnames(markers)))
    plot3(markers.CLTarget(1),markers.CLTarget(2),markers.CLTarget(3),'bo');
end
if any(strcmp('LPoul',fieldnames(markers))) && any(strcmp('RPoul',fieldnames(markers)))
    plot3(markers.LPoul(:,1),markers.LPoul(:,2),markers.LPoul(:,3),'b');
    plot3(markers.RPoul(:,1),markers.RPoul(:,2),markers.RPoul(:,3),'r');
end
    

if size(fieldnames(markers),1)==12
    
    plot3(markers.RFWT(1,1), markers.RFWT(1,2), markers.RFWT(1,3),'ko');
    plot3(markers.LFWT(1,1), markers.LFWT(1,2), markers.LFWT(1,3),'ko');
    plot3(markers.RBWT(1,1), markers.RBWT(1,2), markers.RBWT(1,3),'kx');
    plot3(markers.LBWT(1,1), markers.LBWT(1,2), markers.LBWT(1,3),'kx');
    plot3(markers.LKNE(1,1), markers.LKNE(1,2), markers.LKNE(1,3),'yx');
    plot3(markers.RKNE(1,1), markers.RKNE(1,2), markers.RKNE(1,3),'mx');
    plot3(markers.LKNI(1,1), markers.LKNI(1,2), markers.LKNI(1,3),'yx');
    plot3(markers.RKNI(1,1), markers.RKNI(1,2), markers.RKNI(1,3),'mx');
    plot3(markers.LANE(1,1), markers.LANE(1,2), markers.LANE(1,3),'yx');
    plot3(markers.RANE(1,1), markers.RANE(1,2), markers.RANE(1,3),'mx');
    plot3(markers.LANI(1,1), markers.LANI(1,2), markers.LANI(1,3),'yx');
    plot3(markers.RANI(1,1), markers.RANI(1,2), markers.RANI(1,3),'mx');
    
    xlim([-300 300]);
    ylim([-300 300]);
    zlim([-1000 200]);
    
else%if size(fieldnames(markers),1)==24
    
    plot3(markers.RFWT(1), markers.RFWT(2), markers.RFWT(3),'ko');
    plot3(markers.LFWT(1), markers.LFWT(2), markers.LFWT(3),'ko');
    plot3(markers.RBWT(1), markers.RBWT(2), markers.RBWT(3),'kx');
    plot3(markers.LBWT(1), markers.LBWT(2), markers.LBWT(3),'kx');
    plot3(markers.LKNE(1), markers.LKNE(2), markers.LKNE(3),'yx');
    plot3(markers.RKNE(1), markers.RKNE(2), markers.RKNE(3),'mx');
    plot3(markers.LKNI(1), markers.LKNI(2), markers.LKNI(3),'kx');
    plot3(markers.RKNI(1), markers.RKNI(2), markers.RKNI(3),'kx');
    plot3(markers.LANE(1), markers.LANE(2), markers.LANE(3),'kx');
    plot3(markers.RANE(1), markers.RANE(2), markers.RANE(3),'kx');
    plot3(markers.LANI(1), markers.LANI(2), markers.LANI(3),'kx');
    plot3(markers.RANI(1), markers.RANI(2), markers.RANI(3),'kx');
    plot3(markers.RFem9(1),markers.RFem9(2),markers.RFem9(3),'mx');
    plot3(markers.LFem9(1),markers.LFem9(2),markers.LFem9(3),'yx');
    plot3(markers.RFem6(1),markers.RFem6(2),markers.RFem6(3),'mx');
    plot3(markers.LFem6(1),markers.LFem6(2),markers.LFem6(3),'yx');
    plot3(markers.RTib6(1),markers.RTib6(2),markers.RTib6(3),'mx');
    plot3(markers.LTib6(1),markers.LTib6(2),markers.LTib6(3),'yx');
    plot3(markers.RTib1(1),markers.RTib1(2),markers.RTib1(3),'mx');
    plot3(markers.LTib1(1),markers.LTib1(2),markers.LTib1(3),'yx');
    plot3(markers.RTal1(1),markers.RTal1(2),markers.RTal1(3),'mx');
    plot3(markers.LTal1(1),markers.LTal1(2),markers.LTal1(3),'yx');
    plot3(markers.RHRC(1),markers.RHRC(2),markers.RHRC(3),'mx');
    plot3(markers.LHRC(1),markers.LHRC(2),markers.LHRC(3),'yx');
    
    
    
    xlim([-600 600]);
    ylim([-600 600]);
    zlim([-1000 200]);
    
end
plot3(0, 0, 0,'kx');
plot3(30, 0, 0,'rx');
plot3(0, 30, 0,'gx');
plot3(0, 0, 30,'bx');

xlim([-800 800]);
ylim([-800 800]);
zlim([-1200 200]);


% % end
% [markers.RFWT(1,1), markers.RFWT(1,2), markers.RFWT(1,3);
% markers.LFWT(1,1), markers.LFWT(1,2), markers.LFWT(1,3);
% markers.RBWT(1,1), markers.RBWT(1,2), markers.RBWT(1,3);
% markers.LBWT(1,1), markers.LBWT(1,2), markers.LBWT(1,3);
% markers.LKNE(1,1), markers.LKNE(1,2), markers.LKNE(1,3);
% markers.RKNE(1,1), markers.RKNE(1,2), markers.RKNE(1,3);
% markers.LKNI(1,1), markers.LKNI(1,2), markers.LKNI(1,3);
% markers.RKNI(1,1), markers.RKNI(1,2), markers.RKNI(1,3);
% markers.LANE(1,1), markers.LANE(1,2), markers.LANE(1,3);
% markers.RANE(1,1), markers.RANE(1,2), markers.RANE(1,3);
% markers.LANI(1,1), markers.LANI(1,2), markers.LANI(1,3);
% markers.RANI(1,1), markers.RANI(1,2), markers.RANI(1,3);
% markers.RFem9(1,1),markers.RFem9(1,2),markers.RFem9(1,3);
% markers.LFem9(1,1),markers.LFem9(1,2),markers.LFem9(1,3);
% markers.RFem6(1,1),markers.RFem6(1,2),markers.RFem6(1,3);
% markers.LFem6(1,1),markers.LFem6(1,2),markers.LFem6(1,3);
% markers.RTib6(1,1),markers.RTib6(1,2),markers.RTib6(1,3);
% markers.LTib6(1,1),markers.LTib6(1,2),markers.LTib6(1,3);
% markers.RTib1(1,1),markers.RTib1(1,2),markers.RTib1(1,3);
% markers.LTib1(1,1),markers.LTib1(1,2),markers.LTib1(1,3);
% markers.RTal1(1,1),markers.RTal1(1,2),markers.RTal1(1,3);
% markers.LTal1(1,1),markers.LTal1(1,2),markers.LTal1(1,3)];



