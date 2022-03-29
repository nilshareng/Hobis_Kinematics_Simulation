function [res] = ECShort(Poulaine,TA,M,Markers,Inertie)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
Fem1g = Markers.LHRC /1000 ;
Fem1d = Markers.RHRC /1000;
Fem6g = Markers.LTib1 /1000;
Fem6d = Markers.RTib1 /1000;
Tal1g = Markers.LTal1 /1000;
Tal1d = Markers.RTal1 /1000;

Cost = 0;

[~, iChgt] = min(Poulaine(:,6));

n = size(Poulaine,1);

for i = 2:n
    % Calcul de la variation d'EC entre deux états consécutifs
    etatt = TA(i-1,:);
    etatc = TA(i,:);
    
    poulainegt = Poulaine(i-1,1:3);
    poulainegc = Poulaine(i,1:3);
    
    poulainedt = Poulaine(i-1,4:6);
    poulainedc = Poulaine(i,4:6);
    
    if (i-1<=iChgt)
        appui=0;
    else
        appui=1;
    end
%     Cost = Cost + energie_cinetique(etatc,etatt,M, Fem1g, Fem1d, Fem6g, Fem6d, Tal1g, Tal1d,poulainegc, poulainegt,poulainedc, poulainedt, appui);
    Cost = Cost + energie_cinetique(etatc,etatt,M, Fem1g, Fem1d, Fem6g, Fem6d, Tal1g, Tal1d,poulainegc, poulainegt,poulainedc, poulainedt, appui,Inertie);

    
    
end
res = Cost;

% res = energie_cinetique(etatc,etatt,M, Fem1g, Fem1d, Fem6g, Fem6d, Tal1g, Tal1d,poulainegc, poulainegt,poulainedc, poulainedt, appui);
end

