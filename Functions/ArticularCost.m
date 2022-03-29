function [res] = ArticularCost(tmp,deltatheta2,proj,butemin, butemax)
%UNTITLED6 Summary of this function goes here
%   Detailed explanation goes here
etatt = tmp + (proj*deltatheta2')';
res = sum(sum(cout_butees(etatt,butemin',butemax')));
if isinf(res) || res>10e20
    res = 10e20;
end
end

