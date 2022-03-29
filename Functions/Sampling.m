function [P, TA] = Sampling(NPolA, I, Fem1g, Fem1d, Fem6g, Fem6d, Tal1g, Tal1d, R_monde_local,R_Pelvis_monde_local, R_LFem_ref_local, R_LTib_ref_local, R_RFem_ref_local, R_RTib_ref_local)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

% Calcul des I+1 points échantillonés sur un intervalle [0 1]
Spline = [];
for i = 1:11
    Pol = NPolA(NPolA(:,1)==i,:);
    TS = [];
    for tc= 0:1/I:1
        % Echantillonnage pour chaque Angle
        a= EvalSpline(Pol, tc);
        if(a==-10)
            P=[];
            TA=[];
           return; 
        end
        TS = [TS;a];
    end
    Spline = [Spline, TS];
end

TS = [];
for i=1:size(Spline,1)
    % Evaluation de la Poulaine associée
    TS = [TS; (fcine_numerique_H2(Spline(i,:),Fem1g,Fem6g,Tal1g,Fem1d,Fem6d,Tal1d, R_monde_local,R_Pelvis_monde_local, R_LFem_ref_local, R_LTib_ref_local, R_RFem_ref_local, R_RTib_ref_local))'];
end

P = TS;
TA = Spline;
end

