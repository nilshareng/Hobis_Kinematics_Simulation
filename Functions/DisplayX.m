function [fig] = DisplayX(X, N, NFig, Color)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

if nargin == 2
    fig = figure;
    Color = 'kx';
elseif nargin == 3 
    fig = figure(NFig);   
    Color = 'kx'; 
elseif nargin == 4
    fig = figure(NFig);  
end

hold on;

flag = 0;

for i = 1:size(X,1)
    if X(i,1) > 3
        flag = 1;
    end
    subplot(3,3,1+3*flag);
    hold on;
    plot(X(i,2)*N,X(i,3),Color);
    
    subplot(3,3,2+3*flag);
    hold on;
    plot(X(i,2)*N,X(i,4),Color);
    
    subplot(3,3,3+3*flag);
    hold on;
    plot(X(i,2)*N,X(i,5),Color);
end

end

