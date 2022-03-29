function [f] = DisplayGait(GaitMarkers,N,POV)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

if nargin == 1
    f=figure(1);
    N = 1;
elseif nargin >= 1
    f=figure(N);
end

hold on;
f.WindowState='maximized';

C = struct2cell(GaitMarkers);
field = fieldnames(GaitMarkers); 
for i = 1:size(C,3)
    
    plot3(0 ,0 , 0.1);
    xlim([-800 800]);
    ylim([-800 800]);
    zlim([-1200 200]);
    hold on;
    tmp =  cell2struct(C(:,:,i),field,1); 
    
    if any(strcmp('RTarget',fieldnames(GaitMarkers)))
        plot3(tmp.RTarget(1),tmp.RTarget(2),tmp.RTarget(3),'rx');
    end
%     hold on;
    if any(strcmp('LTarget',fieldnames(tmp)))
        plot3(tmp.LTarget(1),tmp.LTarget(2),tmp.LTarget(3),'rx');
    end
    if any(strcmp('CRTarget',fieldnames(tmp)))
        plot3(tmp.CRTarget(1),tmp.CRTarget(2),tmp.CRTarget(3),'bo');
    end
    if any(strcmp('CLTarget',fieldnames(tmp)))
        plot3(tmp.CLTarget(1),tmp.CLTarget(2),tmp.CLTarget(3),'bo');
    end
    if any(strcmp('LPoul',fieldnames(tmp))) && any(strcmp('RPoul',fieldnames(tmp)))
        
        plot3(tmp.LPoul(:,1),tmp.LPoul(:,2),tmp.LPoul(:,3),'r--','LineWidth', 1);
%         f = figure('WindowState','maximized');
        xlim([-600 600]);
        ylim([-600 600]);
        zlim([-1000 200]);
        
        hold on;
        plot3(tmp.RPoul(:,1),tmp.RPoul(:,2),tmp.RPoul(:,3),'b--','LineWidth', 1);
    end
     if any(strcmp('LFPoul',fieldnames(tmp))) && any(strcmp('RFPoul',fieldnames(tmp)))
        
        plot3(tmp.LFPoul(:,1),tmp.LFPoul(:,2),tmp.LFPoul(:,3),'r','LineWidth', 1);
%         f = figure('WindowState','maximized');
        xlim([-600 600]);
        ylim([-600 600]);
        zlim([-1000 200]);
        
        hold on;
        plot3(tmp.RFPoul(:,1),tmp.RFPoul(:,2),tmp.RFPoul(:,3),'b','LineWidth', 1);
     end
     if any(strcmp('LOPoul',fieldnames(tmp))) && any(strcmp('ROPoul',fieldnames(tmp)))
        
        plot3(tmp.LOPoul(:,1),tmp.LOPoul(:,2),tmp.LOPoul(:,3),'m');
%         f = figure('WindowState','maximized');
        xlim([-600 600]);
        ylim([-600 600]);
        zlim([-1000 200]);
        
        hold on;
        plot3(tmp.ROPoul(:,1),tmp.ROPoul(:,2),tmp.ROPoul(:,3),'c');
     end
     if any(strcmp('X',fieldnames(tmp)))
        for ii = 1:size(tmp.X,1)
        plot3(tmp.X(ii,1),tmp.X(ii,2),tmp.X(ii,3),'kx','LineWidth', 2);
        hold on;
        end
%         f = figure('WindowState','maximized');
        xlim([-600 600]);
        ylim([-600 600]);
        zlim([-1000 200]);
        
    end
    
    if nargin == 3
        switch POV
            case '1'%'Sagittal1' || '1'
                view([1 0 0]);
            case '2'%'Sagittal2' || '2'
                view([-1 0 0]);
            case '3'%'Frontal1' || '3'
                view([0 1 0]);
            case '4'%'Frontal2' || '4'
                view([0 -1 0]);
            case '5'%'Vertical1' || '5'
                view([0 0 1]);
            case '6'%'Vertical2' || '6'
                view([0 0 -1]);
        end
    end
    
    P = DisplayModel(tmp,N);
    pause(1/20);
    hold off;

%     delete(P);
end
% P = DisplayModel(tmp,N);
end

