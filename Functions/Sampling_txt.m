function [P, TA] = Sampling_txt(NPolA, I,Sequence,Markers,Reperes)
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
    TS = [TS; (fcinematique(Spline(i,:),Sequence,Markers,Reperes))'];
end

P = TS;
TA = Spline;
end

