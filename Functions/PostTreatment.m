function [Distances,Stats] = PostTreatment(Path,Display)
% Stats and displays of results from previous algo
close all;
Ressources = ls(Path);
Ressources = Ressources(5:end,:); % Sale, valable pour \Batch3\
p = genpath('C:\Users\nhareng\Desktop\CodeCommente\hobis\');
addpath(p);
S = size(Ressources,1);

% PoulainesCollector
% TACollector

mkdir(Path,'Figures')

i = 0;

for i = 1:S
    
    load(strcat(Path, Ressources(i,:)));
    D1 = Results;
    
    if Display
        DisplayCurves(D1.InitialPoulaine(:,1:3),i,'--');
        DisplayCurves(D1.PoulaineEmpreintesInput(:,1:3),i,'--');
        DisplayCurves(D1.PoulaineEmpreintesInputScaled(:,1:3),i,'--');
        DisplayCurves(D1.FinalPoulaine(:,1:3),i);
        DisplayCurves(D1.Mem.P(:,1:3),i);
        
        DisplayCurves(D1.Mem.TA(:,1:7),S+i);
        DisplayCurves(D1.TAFinal(:,1:7),S+i);
        DisplayCurves(D1.TAPostIK(:,1:7),S+i);
        
        sgtitle(Ressources(i,1:end-4),'Interpreter','none');
        
        IniTA = Pol2Curve(Results.InitialPolynom,size(Results.InitialPoulaine,1));
        FinalTA = Pol2Curve(Results.FinalPolynom,size(Results.InitialPoulaine,1));
        
        f = figure(i);
        hold on;
        legend('Poulaine Initiale Scalée','Poulaine Empreintes','Poulaine Empreintes Scalée','Poulaine Finale','','','','','','','Position',[ 0.75, 0.1, 0.1, 0.1]);
        DisplayX(D1.OriginalX, size(D1.PoulaineEmpreintesInput,1),i,'ro');
        DisplayX(D1.EmpreintesScaled, size(D1.PoulaineEmpreintesInput,1),i,'rx');
        
        subplot(3,3,7);
        plot(D1.Convergence(1,:));
        subplot(3,3,8);
        plot(D1.Convergence(2,:));
        cd(strcat(Path,'\Figures\'))
        saveas(f,strcat(num2str(i),'.png'));
        
    end
end


Distances = struct;

A = [];
B = [];
C = [];
D = [];
E = [];
F = [];
G = [];
H = [];
I = [];
J = [];
for i = 1:S
    load(strcat(Path, Ressources(i,:)));
    
    Results.FinalPoulaine = Results.Mem.P;
    Results.TAFinal = Results.Mem.TA;
    
%     if size(Results.FinalPoulaine,1) ~= size(Results.PoulaineEmpreintesInput,1)
%         Results.FinalPoulaineCompa = Pol2Curve(FinalPol);
%     end
    
    PolP = [];
    
    for i = 1:6
        [~, tpol]=Curve2Spline(Results.PoulaineEmpreintesInput(:,i));  
        tpol(:,1) = i * ones(size(tpol,1),1);
        PolP = [PolP ; tpol];
    end
    
    PoulaineEmpreintesSampled = Pol2Curve(PolP);
    
    
    if size(Results.FinalPoulaine,1) ~= size(Results.InitialPoulaine,1)
        Results.FinalPoulaine = Results.FinalPoulaine(1:end-1,:) ;
        Results.TAFinal = Results.TAFinal(1:end-1,:);
    end
    
%     IniTA = spline_to_curve_int(Results.InitialPolynom,size(Results.InitialPoulaine,1));
    
    IniXTA = Pol2Curve(Results.TargetPolynom,size(Results.TAFinal,1)-1);
    
%     FinalTA = spline_to_curve_int(Results.Mem.Pol,size(Results.InitialPoulaine,1));
    
    A = [A, Results.Mem.Conv(1,end)];
    B = [B, Results.Mem.Conv(2,end) / Results.Convergence(2,1)];
    C = [C, sum(sum(sqrt((Results.FinalPoulaine - Results.InitialPoulaine).^2)))];
%     D = [D, sum(sum(sqrt((Results.FinalPoulaine - Results.InitialSplinedPoulaine).^2)))];
    E = [E, Results.Convergence(1,1)];

    F = [F; sqrt(mean((-1* Results.FinalPoulaine + Results.PoulaineEmpreintesSampled).^2)) ];
%     G = [G; sqrt(mean((-1* Results.FinalPoulaine + Results.InitialSplinedPoulaine).^2)) ];
    H = [H; sqrt(mean((-1* Results.TAFinal + IniXTA).^2))];    
    I = [I, corr2(Results.PoulaineEmpreintesInput(:,1:3),Results.FinalPoulaine(:,1:3))];
    J = [J, corr2(IniXTA(:,1:7),Results.TAFinal(:,1:7))];
end

Distances.RToEmpreintes = A;
Distances.IniToEmpreintes = E;
Distances.DistCostVar = A./E;
Distances.MechCostChange = B;
Distances.RToOriginalPoulaine = C;
Distances.RToOriginalOptimPoulaine = D;
Distances.RMSP = F;
% Distances.RMSPNS = G;
Distances.RMSTAIK =  H;
% Distances.PCorr = I;
Distances.TACorr = J;

Stats.MeanDistToEmpreintes = mean(Distances.RToEmpreintes);
Stats.StdDistToEmpreintes = std(Distances.RToEmpreintes);
Stats.MeanMechCostChange = mean(Distances.MechCostChange);
Stats.StdMechCostChange = std(Distances.MechCostChange);
Stats.MeanDistToOriginalPoulaine = mean(Distances.RToOriginalPoulaine);
Stats.StdDistToOriginalPoulaine = std(Distances.RToOriginalPoulaine);
Stats.MeanDistToOriginalOptimPoulaine = mean(Distances.RToOriginalOptimPoulaine);
Stats.StdDistToOriginalOptimPoulaine = std(Distances.RToOriginalOptimPoulaine);
Stats.MeanDistCostVar = mean(Distances.DistCostVar);
Stats.StdDistCostVar = std(Distances.DistCostVar);
Stats.MeanDistIniToEmpreintes = mean(Distances.IniToEmpreintes);
Stats.StdDistIniToEmpreintes = std(Distances.IniToEmpreintes);

Stats.MeanRMSPoulaine = mean(Distances.RMSP);
Stats.StdRMSPoulaine = std(Distances.RMSP);
% Stats.MeanRMSPoulaineNoSpline = mean(Distances.RMSPNS);
% Stats.StdRMSPoulaineNoSpline = std(Distances.RMSPNS);
Stats.MeanRMSTA = mean(Distances.RMSTAIK);
Stats.StdRMSTA = std(Distances.RMSTAIK);


% Stats.meanPCorr = mean(Distances.PCorr);
% Stats.stdPCorr = std(Distances.PCorr);
Stats.meanTACorr = mean(Distances.TACorr);
Stats.stdTACorr = std(Distances.TACorr);

save(strcat(Path,'Stats.mat'),'Stats','Distances');

end

