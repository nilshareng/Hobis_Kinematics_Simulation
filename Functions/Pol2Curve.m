function [Curve] = Pol2Curve(Pol,Int)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
Curve = [];
for i = 1:11
    tmpPol = Pol(Pol(:,1)==i,:);
    TS2 = [];
    for tc= 0:1/Int:1
        % Echantillonnage pour chaque Angle
        a= EvalSpline(tmpPol, tc);
        TS2 = [TS2;a];
    end
    Curve = [Curve, TS2];
end
end

