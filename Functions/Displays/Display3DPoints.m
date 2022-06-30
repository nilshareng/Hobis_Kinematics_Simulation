function [fig] = Display3DPoints(Points,NFig)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

if nargin == 1
    fig = figure();
elseif nargin == 2
    fig = figure(NFig);
else
    error('Input error');
end

hold on;

for i = 1:size(Points,1)
    plot3(Points(:,1), Points(:,2), Points(:,3), 'kx');
end

end

