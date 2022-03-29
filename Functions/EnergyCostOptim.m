function [res] = EnergyCostOptim(deltatheta2, tmp, Proj, NPCA, Period, Sequence, Markers, Reperes, InvE,...
    mid, Threshold, PCA, c, Cflag, rate, M, Inertie, Iflag)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
etatt = tmp + (Proj*deltatheta2);

[~,NPolA] = ModifPCA(etatt, NPCA, Period, Sequence, Markers, Reperes, InvE, mid, Threshold, PCA, ...
    c, Cflag, rate, Iflag);

[P, TA] = Sampling_txt(NPolA,Period,Sequence,Markers,Reperes);

res = sum(sum(ECShort(P,TA,M,Markers,Inertie)));

if res>10e20
    res = 10e20;
end
end

