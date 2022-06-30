function res = CE(Poulaine,TA,M,Fem1g, Fem1d, Fem6g, Fem6d, Tal1g, Tal1d, R_monde_local,R_Pelvis_monde_local, R_LFem_ref_local, R_LTib_ref_local, R_RFem_ref_local, R_RTib_ref_local)
% Utilisation de la  fonction d'energie cinétique de G. Nicolas
P = [Poulaine;Poulaine(2,:)];
T = [TA;TA(2,:)];

[~, iChgt] =min(P(:,6)); 

n = size(P,1);

Cost = 0;

for i = 2:n
    % Calcul de la variation d'EC entre deux états consécutifs
    etatt = T(i-1,:);
    etatc = T(i,:);
    
    poulainegt = P(i-1,1:3);
    poulainegc = P(i,1:3);
    
    poulainedt = P(i-1,4:6);
    poulainedc = P(i,4:6);
    
    if (i-1<=iChgt) 
          appui=0;
%           dz=-poulaineg(j,3)+poulaineg(j-1,3);
      else
          appui=1;
%  a         dz=-poulained(j,3)+poulained(j-1,3);
    end
        
%     Cost=Cost + energie_cinetique(etatc,etatt,M, Fem1g, Fem1d, Fem6g, Fem6d, Tal1g, Tal1d,poulainegc, poulainegt,poulainedc, poulainedt, appui);
    Cost=Cost + moment_cinetique(etatc,etatt,M, Fem1g, Fem1d, Fem6g, Fem6d, Tal1g, Tal1d,poulainegc, poulainegt,poulainedc, poulainedt, appui, R_monde_local,R_Pelvis_monde_local, R_LFem_ref_local, R_LTib_ref_local, R_RFem_ref_local, R_RTib_ref_local);
    
    
    
end




res = Cost;
end

