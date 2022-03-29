clear all;
close all;
clc;

path = 'C:\Users\nhareng\Desktop\CodeCommente\hobis\BDD\Classement_Pas.xlsx';
[~, Names] = xlsread(path,'A2:D78');

PathPreSet = 'C:\Users\nhareng\Desktop\CodeCommente\hobis\Resultats\Batch\NewPresets\';
SavePath = 'C:\Users\nhareng\Desktop\CodeCommente\hobis\Resultats\Batch\9 - SameName\';
SavePath2 = 'C:\Users\nhareng\Desktop\CodeCommente\hobis\Resultats\Batch\7 - Self\';


p = 'C:\Users\nhareng\Desktop\BDD AH Marche\BDD\';
d = dir(strcat(p,'*012.c3d'));

cind =0;

Resultats = struct;

printflag=1;


for ii=1:length(d)
    
    load(strcat(PathPreSet,Names{1+11*(ii-1)},'.mat'));
    POrig = PN;
    PolPreset = Pol;
    clear Pol;
    
    d2 = dir(strcat(SavePath,Names{1+11*(ii-1)},'\','*.mat'));
    for jj = 1:length(d2)
        if jj==1
            load(strcat(PathPreSet,Names{1+11*(ii-1)+jj-1},'.mat'));
            PolIni = Pol;
            load(strcat(SavePath2,Names{1+11*(ii-1)},'\',d2(jj).name));
            [~,Ind]= min(Conv(1,20:end));
            Ind = Ind+19;
%             TAIni = GT;
        else
            load(strcat(PathPreSet,Names{1+11*(ii-1)+jj-1},'.mat'));
            PolIni = Pol;
            load(strcat(SavePath,Names{1+11*(ii-1)},'\',d2(jj).name));
            [~,Ind]= min(Conv(1,:));
%             TAIni = GT;
        end
        %         GT = PN;
        m=min(Conv(1,2:end));
        if size(Conv,2)>1 % Selection du nombre de cycles effectués min pour afficher une courbe
            cind=cind+1;
%             Names{1+11*(ii-1)} , Names{1+11*(ii-1)+jj-1}
            %         [~, Ind] = min(Conv(1,:));
            
%             [~,Ind]= min(Conv(1,:));
            
%             Ind
            
            Period = size(GT,1)-1;
            PCA = Storing(Storing(:,1)==Ind-1,2:end);
%             PCAIni  = Storing(Storing(:,1)==0,2:end);
            
            Pol = [];
%             PolIni = [];
            for i =1:PCA(end,1)
                Pol = [Pol ; PC_to_spline(PCA(PCA(:,1)==i,2:3),1)];
%                 PolIni = [PolIni ; PC_to_spline(PCAIni(PCAIni(:,1)==i,2:3),1)];
            end
            Pol(:,1) = PCA(:,1);
%             PolIni(:,1) = PCAIni(:,1);
            
            TAFin = [];
            TACible = [];
            TAIni = [];
%             for i =1:Pol(end,1)
%                 TAFin = [TAFin , spline_to_curve_int(Pol(Pol(:,1)==i,:),Period)'];
%             end
            for i =1:Period+1
                tmp=zeros(1,11);
                tmp1=zeros(1,11);
                tmp2=zeros(1,11);
                for j=1:11
                    tmp(j) = EvalSpline(Pol(Pol(:,1)==j,:),((i-1))/Period);
                    tmp1(j) = EvalSpline(PolPreset(PolPreset(:,1)==j,:),((i-1))/Period);
                    tmp2(j) = EvalSpline(PolIni(PolIni(:,1)==j,:),((i-1))/Period);
                end
                TAFin = [TAFin ; tmp];
                TACible = [TACible ; tmp1];
                TAIni = [TAIni ; tmp2];
            end
            
            PFin=[];
            PCible = [];
            PIni = [];
            for i =1:size(GT,1)
                PFin = [PFin; fcine_numerique_H2(TAFin(i,:),Param(:,1)',Param(:,2)',Param(:,3)',Param(:,4)',Param(:,5)',Param(:,6)', R_monde_local,R_Pelvis_monde_local, R_LFem_ref_local, R_LTib_ref_local, R_RFem_ref_local, R_RTib_ref_local)'];
                PCible = [PCible; fcine_numerique_H2(TACible(i,:),Param(:,1)',Param(:,2)',Param(:,3)',Param(:,4)',Param(:,5)',Param(:,6)', R_monde_local,R_Pelvis_monde_local, R_LFem_ref_local, R_LTib_ref_local, R_RFem_ref_local, R_RTib_ref_local)'];
                PIni = [PIni; fcine_numerique_H2(TAIni(i,:),Param(:,1)',Param(:,2)',Param(:,3)',Param(:,4)',Param(:,5)',Param(:,6)', R_monde_local,R_Pelvis_monde_local, R_LFem_ref_local, R_LTib_ref_local, R_RFem_ref_local, R_RTib_ref_local)'];            
            end
            
            
            TAFin = TAFin *180/pi;
            TACible = TACible *180/pi;
            TAIni = TAIni * 180/pi;
            
            Resultats(1+11*(ii-1)+jj-1).PoulaineSimulee = PFin;
            Resultats(1+11*(ii-1)+jj-1).PoulaineOriginale = POrig;
            Resultats(1+11*(ii-1)+jj-1).PoulaineIni = PIni;
            Resultats(1+11*(ii-1)+jj-1).TASimulee = TAFin;
            Resultats(1+11*(ii-1)+jj-1).TAIni = TAIni;
            Resultats(1+11*(ii-1)+jj-1).PCAOrig = Storing(Storing(:,1)==0,2:end);
            Resultats(1+11*(ii-1)+jj-1).TACible = TACible;
            Resultats(1+11*(ii-1)+jj-1).PolCible = PolPreset;
            Resultats(1+11*(ii-1)+jj-1).PolTA = Pol;
            Resultats(1+11*(ii-1)+jj-1).Period = Period;
            Resultats(1+11*(ii-1)+jj-1).Empreintes = X;
            Resultats(1+11*(ii-1)+jj-1).Convergences = Conv;
            Resultats(1+11*(ii-1)+jj-1).IndiceConv = Ind;
            
            if printflag
                figure;
                hold on;
                for i=1:6
                    subplot(2,3,i);
                    
                end
                
                
                
                
                figure;
                hold on;
                for i =1:11
                    switch i
                        case {1 , 2 , 3 }
                            Title = strcat('Rotation Pelvis ',87+i);
                            subplot(5,3,i)
                            hold on;
                        case {4 , 5 , 6 , 8 , 9 , 10}
                            if i<8
                                Title = 'Rotation Hanche Droite ';
                                Title = strcat('Rotation Pelvis ',87+i-3);
                                subplot(5,3,i);
                                hold on;
                            else
                                Title = 'Rotation Hanche Gauche ';
                                Title = strcat('Rotation Pelvis ',87+i-7);
                                subplot(5,3,i-1);
                                hold on;
                            end
                        case {7 , 11}
                            if i==7
                                subplot(5,3,12);
                                hold on;
                                Title = ('Rotation Genou Droite Z');
                            else
                                Title = ('Rotation Gauche Z');
                                subplot(5,3,15);
                                hold on;
                            end
                    end
                    title(Title);
                    plot(0:1/(size(TACible,1)-1):1, TACible(:,i),'k--');
                    plot(0:1/(size(TAFin,1)-1):1, TAFin(:,i),'b');
                    plot(0:1/(size(TAIni,1)-1):1, TAIni(:,i),'r');
                end
                pause;
            end
            
            
        else
        end
        
        %     figure;
        %     hold on;
        %     subplot(3,1,1);
        %     plot(1:size(Conv,2),Conv(1,1:end),'rx');
        %     subplot(3,1,2);
        %     plot(1:size(Conv,2),Conv(2,1:end),'rx');
        %     subplot(3,1,3);
        %     plot(1:size(Conv,2),Conv(3,1:end),'rx');
        %
        %     pause;
        close all;
    end
    
end


%% Manipulations sur Resultats

% Cas 1 : Comparaison simulations Self / Simu visée
clc;

StatsCas1 = struct;

for i = 1:11:67
    StatsCas1(1+(i-1)/11).RMSAxis = 1/Resultats(i).Period * sum((Resultats(i).PoulaineOriginale - Resultats(i).PoulaineSimulee).^2);
    StatsCas1(1+(i-1)/11).RMSMean = mean(StatsCas1(1+(i-1)/11).RMSAxis);
%     StatsCas1(1+(i-1)/11).RMSSig = ;

end

% StatsCas1.Moy = 1/7 * sum()
% 
% Resultats()


printflag=0;

% Cas 2

StatsCas2 = struct;

for i = 1:77
    StatsCas2(i).RMSAxisP = 1/Resultats(i).Period * sum((Resultats(i).PoulaineOriginale - Resultats(i).PoulaineSimulee).^2);
%     StatsCas2(i).RMSAxisTA = 1/Resultats(i).Period * sum((Resultats(i).TACible - Resultats(i).TASimulee).^2);
    StatsCas2(i).RMSAxisTA = sqrt(1/Resultats(i).Period * sum((Resultats(i).TAIni - Resultats(i).TASimulee).^2));
%     1/Resultats(i).Period * sum((Resultats(i).TAIni - Resultats(i).TASimulee).^2)
    
     if printflag
                figure;
                hold on;
                for j =1:11
                    switch j
                        case {1 , 2 , 3 }
                            Title = strcat('Rotation Pelvis ',87+j);
                            subplot(5,3,j)
                            hold on;
                        case {4 , 5 , 6 , 8 , 9 , 10}
                            if j<8
                                Title = 'Rotation Hanche Droite ';
                                Title = strcat('Rotation Pelvis ',87+j-3);
                                subplot(5,3,j);
                                hold on;
                            else
                                Title = 'Rotation Hanche Gauche ';
                                Title = strcat('Rotation Pelvis ',87+j-7);
                                subplot(5,3,j-1);
                                hold on;
                            end
                        case {7 , 11}
                            if j==7
                                subplot(5,3,12);
                                hold on;
                                Title = ('Rotation Genou Droite Z');
                            else
                                Title = ('Rotation Gauche Z');
                                subplot(5,3,15);
                                hold on;
                            end
                    end
                    title(Title);
                    plot(0:1/(size(Resultats(i).TASimulee(:,j),1)-1):1, (Resultats(i).TAIni(:,j) - Resultats(i).TASimulee(:,j)).^2,'g');
                    plot(0:1/(size( Resultats(i).TASimulee(:,j),1)-1):1,  Resultats(i).TASimulee(:,j),'b');
                    plot(0:1/(size(Resultats(i).TAIni(:,j),1)-1):1, Resultats(i).TAIni(:,j),'r');
                end
                i;
     end
     
    StatsCas2(i).RMSMeanP = mean(StatsCas2(i).RMSAxisP);
    StatsCas2(i).RMSMeanTA = mean(StatsCas2(i).RMSAxisTA);
    StatsCas2(i).RMSSigmaPoul = std((Resultats(i).PoulaineOriginale - Resultats(i).PoulaineSimulee).^2);
    StatsCas2(i).RMSSigmaTA = std((Resultats(i).TACible - Resultats(i).TASimulee).^2);    
    StatsCas2(i).RMSMaxP = max(StatsCas2(i).RMSAxisP);
    StatsCas2(i).RMSMinP = min(StatsCas2(i).RMSAxisP);
    StatsCas2(i).RMSMaxTA = max(StatsCas2(i).RMSAxisTA);
    StatsCas2(i).RMSMinTA = min(StatsCas2(i).RMSAxisTA);
    StatsCas2(i).CorrCoeff = [];
    for j=1:11
        a= corrcoef(Resultats(i).TASimulee(:,j), Resultats(i).TACible(:,j));
        StatsCas2(i).CorrCoeff = [StatsCas2(i).CorrCoeff  , a(1,2)];
    end
    StatsCas2(i).CorrCoeffP = [];
    for j=1:6
        a= corrcoef(Resultats(1+11*fix((i-1)/11)).PoulaineSimulee(:,j), Resultats(i).PoulaineSimulee(:,j));
        StatsCas2(i).CorrCoeffP = [StatsCas2(i).CorrCoeffP  , a(1,2)];
    end
end

% Corr moyenne par degré de lib 

MeanT = zeros(1,11);
MeanSubT = zeros(7,11);
MeanP = zeros(1,6);
MeanSubP = zeros(7,6);
c=0;
for i =1:7
    for j = 1:11
        c=c+1;
        MeanT = MeanT + StatsCas2(c).CorrCoeff;
        MeanSubT(i,:) = MeanSubT(i,:) + StatsCas2(c).CorrCoeff;
        if j~=1
            MeanP = MeanP + StatsCas2(c).CorrCoeffP;
            MeanSubP(i,:) = MeanSubP(i,:) + StatsCas2(c).CorrCoeffP;
        end
    end
    MeanSubT(i,:) = MeanSubT(i,:)/11;
    MeanSubP(i,:) = MeanSubP(i,:)/10;
end
MeanT = MeanT /77;
MeanP = MeanP/70;



FinalData = struct;
FinalData.MeanT = MeanT;
FinalData.MinMeanT = min(MeanT);
FinalData.SigmaMeanT = std(MeanT);
FinalData.MeanSubT = MeanSubT;
FinalData.MoyMeanT = mean(MeanT);
FinalData.MeanSubT=[];
FinalData.SigmaMeanSubT=[];
FinalData.MinMeanSubT =[];
for i = 1:7
    FinalData.MeanSubT = [FinalData.MeanSubT ; mean(MeanSubT(i,:))];
    FinalData.SigmaMeanSubT=[FinalData.SigmaMeanSubT ; std(MeanSubT(i,:))];
    FinalData.MinMeanSubT = [FinalData.MinMeanSubT ; min(MeanSubT(i,:))];
end

FinalData.MeanRMS1 = 0;
FinalData.MeanRMS2 = 0;
a=[];
b=[];
for i = 1:77
    if find(i==(1:11:67))
        FinalData.MeanRMS1 = FinalData.MeanRMS1 + StatsCas2(i).RMSMeanTA;
        a=[a , StatsCas2(i).RMSMeanTA];
    else
        FinalData.MeanRMS2 = FinalData.MeanRMS2+ StatsCas2(i).RMSMeanTA;
        b=[b , StatsCas2(i).RMSMeanTA];
    end
end
FinalData.MeanRMS1 = FinalData.MeanRMS1 /7;
FinalData.MeanRMS2 = FinalData.MeanRMS2 /70;

FinalData.MeanSigmaRMS1 = std(a);
FinalData.MeanSigmaRMS2 = std(b);




FinalData.Rcarre = FinalData.MeanT.^2;
FinalData.stdRcarre = std(FinalData.Rcarre);

