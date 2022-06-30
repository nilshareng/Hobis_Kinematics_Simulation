function [Mat] = RotationZ(Angle)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
Mat = [cos(Angle) -sin(Angle) 0 0;  sin(Angle) cos(Angle) 0 0; 0 0 1 0; 0 0 0 1];
end

