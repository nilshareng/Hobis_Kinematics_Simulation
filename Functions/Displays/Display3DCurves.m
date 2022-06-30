function fig = Display3DCurves(Curves,Nfig)
%UNTITLED7 Summary of this function goes here
%   Detailed explanation goes here
if nargin == 1
    fig = figure();
elseif nargin == 2
    fig = figure(Nfig);
else
   error('Too many inputs') 
end
hold on;

[a,b] = size(Curves);

if floor(b/3)>=1
    for i = 1:floor(b/3)
        if a == 3 || a ==6 % X plottings
            plot3(Curves(:,2+i*3-2),Curves(:,2+i*3-1),Curves(:,2+i*3),'kx');
        else
            plot3(Curves(:,i*3-2),Curves(:,i*3-1),Curves(:,i*3));
        end
    end
else
    error('not enough dims in your curves')
end
end

