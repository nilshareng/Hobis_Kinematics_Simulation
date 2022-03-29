function f = DisplayCurves(Curves,n,shape)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here



if size(Curves,1)<size(Curves,2)
    Curves = Curves';
end

if nargin == 1
    f = figure;
    hold on;
    s = min(size(Curves,2));
    k = ceil(sqrt(s));
    for i = 1:s
        subplot(k,k,i);
        hold on;
        plot(Curves(:,i));
    end
elseif nargin == 2
    figure(n);
    hold on;
    s = min(size(Curves,2));
    k = ceil(sqrt(s));
    for i = 1:s
        subplot(k,k,i);
        hold on;
        plot(Curves(:,i));
    end
end



if nargin == 3
    hold on;
    figure(n);
    hold on;
    s = min(size(Curves,2));
    k = ceil(sqrt(s));
    for i = 1:s
        subplot(k,k,i);
        hold on;
        plot(Curves(:,i),shape);
    end
end
% sgtitle(inputname(1));

end

