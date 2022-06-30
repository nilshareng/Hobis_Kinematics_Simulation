function cost = ArticularCostPC(NPolA, Period, Sequence, Markers, Reperes, butemin, butemax)
% 
sumcost = 0;
[~, TA] = Sampling_txt(NPolA, Period,Sequence,Markers,Reperes);

for i = 1:size(TA,1)
    etatt = TA(i,:);
    sumcost = sumcost + sum(sum(cout_butees(etatt,butemin,butemax)));
    if isinf(sumcost) || sumcost>10e20
        sumcost = sumcost + 10e20;
    end
end
cost = sumcost;
end

