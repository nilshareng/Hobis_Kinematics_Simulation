function [Mat] = RotationX(Angle)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
Mat = [1 0 0 0;  0 cos(Angle) -sin(Angle) 0; 0 sin(Angle) cos(Angle) 0 ; 0 0 0 1];
end

