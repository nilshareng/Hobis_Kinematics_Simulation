function [markers, Param]= HobisDataParser(Data)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
markers = struct;
dd = Data;

Param = zeros(6,3);
% Terminologie et variables de 'JeuEssaiDM' - G.Nicolas 2009

% Inversion G/D sur les dd opérée le 01/02/22 car incohérente avec repère
% monde actuel
% -> Reversed 08/03/22

if size(dd,1)==27
    Pelv1=dd(1,:);
    Pelv2g=dd(2,:);
    Pelv4g=dd(3,:);
    Pelv5g=dd(4,:);
    
    Fem1g=dd(5,:);
    Fem9g=dd(6,:);
    Fem10g=dd(7,:);
    Fem6g=dd(8,:);
    
    Tib5g=dd(9,:);
    Tib6g=dd(10,:);
    Tib1g=dd(11,:);
    
    Tal2g=dd(12,:);
    Tal3g=dd(13,:);
    Tal1g=dd(14,:);
    %
    Pelv2d=dd(15,:);
    Pelv4d=dd(16,:);
    Pelv5d=dd(17,:);
    
    Fem1d=dd(18,:);
    Fem9d=dd(19,:);
    Fem10d=dd(20,:);
    Fem6d=dd(21,:);
    
    Tib5d=dd(22,:);
    Tib6d=dd(23,:);
    Tib1d=dd(24,:);
    
    Tal2d=dd(25,:);
    Tal3d=dd(26,:);
    Tal1d=dd(27,:);
    
    Param = [Fem1g',Fem6g',Tal1g', Fem1d', Fem6d', Tal1d']/1000;
    
    markers.RBWT = Pelv4d;
    markers.LBWT = Pelv4g;
    markers.RFWT = Pelv5d;
    markers.LFWT = Pelv5g;
    markers.RKNE = Fem10d;
    markers.LKNE = Fem10g;
    markers.RKNI = Tib5d;
    markers.LKNI = Tib5g;
    markers.RANE = Tal2d;
    markers.LANE = Tal2g;
    markers.RANI = Tal3d;
    markers.LANI = Tal3g;
    markers.RHRC = Fem1d;
    markers.LHRC = Fem1g;
    markers.RFem9 = Fem9d;
    markers.LFem9 = Fem9g;
    markers.RFem6 = Fem6d;
    markers.LFem6 = Fem6g;
    markers.RTib6 = Tib6d;
    markers.LTib6 = Tib6g;
    markers.RTib1 = Tib1d;
    markers.LTib1 = Tib1g;
    markers.RTal1 = Tal1d;
    markers.LTal1 = Tal1g;
    
    
elseif size(dd,1)==18
    warning('deprecated');
    
    markers.RFWT = dd(1,:);
    markers.LFWT = dd(2,:);
    markers.RBWT = dd(3,:);
    markers.LBWT = dd(4,:);
    markers.RKNE = dd(5,:);
    markers.LKNE = dd(6,:);
    markers.RKNI = dd(7,:);
    markers.LKNI = dd(8,:);
    markers.RANE = dd(9,:);
    markers.LANE = dd(10,:);
    markers.RANI = dd(11,:);
    markers.LANI = dd(12,:);
    
    Param = [dd(13,:)',dd(14,:)',dd(15,:)', dd(16,:)', dd(17,:)', dd(18,:)']/1000;
    
else
    error('Error in input file size');
end

% Param Physiologiques : vecteur OPelv-OHanche ; OHanche-OGenou ; OGenous-Cheville




end

