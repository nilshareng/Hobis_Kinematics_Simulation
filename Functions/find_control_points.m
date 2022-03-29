function res = find_control_points(curve, interval)
%
%   Returns the Control points of the curve corresponding to local extrema.
%   Extremely sensitive to noise -> Filtered data are necessary
%   PC = [Indices ; Values]
PC=islocalmin(curve)+ islocalmax(curve);
if sum(PC)==1
    PC(end-1) = PC(end-1) +1;
end
k=unique(find(PC));
res=[interval(k'),curve(k)];

end

