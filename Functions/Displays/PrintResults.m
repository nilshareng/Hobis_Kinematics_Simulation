%%% Renseigner les Paths et lancer
% path -> classeur xlsx des c3d
% PathPreSet -> idem BatchSelect
% SavePath -> Données à charger issues du calcul de BatchSelect

clear all;
close all;
clc;

% Chemin à l'excel contenant la liste des .c3d
path = 'C:\Users\nhareng\Desktop\CodeCommente\hobis\Ressources\BDD\Classement_Pas.xlsx';
[~, Names] = xlsread(path,'A2:D79');

% Chemin des Presets
PathPreSet = 'C:\Users\nhareng\Desktop\CodeCommente\hobis\Ressources\NewPresets\';
% Chemin des Résultats calculés dans MainBatch
SavePath = 'C:\Users\nhareng\Desktop\CodeCommente\hobis\Ressources\SameName\';
% SavePath2 = 'C:\Users\nhareng\Desktop\CodeCommente\hobis\Resultats\Batch\7 - Self\';
% SavePath2 = 'C:\Users\nhareng\Desktop\CodeCommente\hobis\Resultats\Batch\Old\SameName\';

% Chemin de la BDD de .c3d
p = 'C:\Users\nhareng\Desktop\CodeCommente\hobis\Ressources\BDD\';
d = dir(strcat(p,'*012.c3d'));

cind =0;

M1 = [];

% Affichage des données pour les cas de convergence
for ii=1:length(d)
    v = Names{1+11*(ii-1)};
    load(strcat(PathPreSet,v,'.mat'));
    POrig = PN;
    clear Pol;
   
    d2 = dir(strcat(SavePath,v,'\','*.mat'));
    for jj = 1:length(d2)
        if jj==1
            load(strcat(SavePath,Names{1+11*(ii-1)},'\',d2(jj).name));
            [~,Ind]= min(Conv(1,5:end));
            Ind = Ind+4;
        else
            load(strcat(SavePath,Names{1+11*(ii-1)},'\',d2(jj).name));
            [~,Ind]= min(Conv(1,:));
        end
%         GT = PN;
%         m=min(Conv(1,2:end));
%         if m<0.1
            if size(Conv,2)>1 % Selection du nombre de cycles effectués min pour afficher une courbe
            cind=cind+1;
            Names{1+11*(ii-1)} , Names{1+11*(ii-1)+jj-1}
            %         [~, Ind] = min(Conv(1,:));
            
%             [~,Ind]= min(Conv(1,:));
            
            Ind
            
            Period = size(GT,1)-1;
            
            PCA = Storing(Storing(:,1)==Ind-1,2:end);
            
            Pol = [];
            for i =1:PCA(end,1)
                Pol = [Pol ; PC_to_spline(PCA(PCA(:,1)==i,2:3),1)];
            end
            Pol(:,1) = PCA(:,1);
            
            TAFin = [];
            for i =1:Pol(end,1)
                TAFin = [TAFin , spline_to_curve_int(Pol(Pol(:,1)==i,:),Period)'];
            end
            
            PFin=[];
            
            for i =1:size(GT,1)
                PFin = [PFin; fcine_numerique_H2(TAFin(i,:),Param(:,1)',Param(:,2)',Param(:,3)',Param(:,4)',Param(:,5)',Param(:,6)', R_monde_local,R_Pelvis_monde_local, R_LFem_ref_local, R_LTib_ref_local, R_RFem_ref_local, R_RTib_ref_local)'];
            end
            
            
            TAFin = TAFin *180/pi;
            % Affichage
            
            figure(1);
            hold on;
%             for i =1:6
            for i =1:3
                subplot(1,3,i);
                hold on;
                Title='';
                switch i
                    case {1 , 4}
                        Title = 'Ankle X axis';
                        %             legend('X - Sens de la marche');
                    case {2 , 5}
                        Title = 'Ankle Y axis';
                        %             legend('Y - Up');
                    case {3 , 6}
                        Title = 'Ankle Z axis';
                        %             legend('Z - Latéral');
                end
                if i<4
                    Title = strcat(Title,' Right');
                else
                    Title = strcat(Title,' Left');
                end
                title(Title);
                plot(0:1/(size(PFin,1)-1):1, GT(:,i),'r');
                plot(0:1/(size(PFin,1)-1):1, PFin(:,i));
                plot(0:1/(size(POrig,1)-1):1, POrig(:,i),'b--');
                xlabel('Walk cycle, %');
                ylabel('Ankle position, m');
                
                
                if i <4
                    plot(X(1:3,2), X(1:3,i+2),'kx','MarkerSize',10);
                else
                    plot(X(4:6,2), X(4:6,i-1),'kx','MarkerSize',10);
                end
                if i==3
                    legend('Footprints original curve' , 'Simulation result', 'Simulation initial curve', 'Target Points')
                end
            end
            
            
            figure(2);
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
                            Title = strcat(Title,87+i-3);
                            subplot(5,3,i);
                            hold on;
                        else
                            Title = 'Rotation Hanche Gauche ';
                            Title = strcat(Title,87+i-7);
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
                p=plot(0:1/(size(TAFin,1)-1):1, TAFin(:,i));
                p(1).LineWidth=2;
                xlabel('Cycle de marche, %');
                ylabel('Angle, deg');
            end
            
            M1 = [M1,TAFin];
            
            figure(3);
            hold on;
            subplot(2,1,1);
            
            plot(1:size(Conv(:,1:Ind),2),Conv(1,1:Ind),'rx');
            title('Convergence : Summed Error, m per optimization step');
            xlabel('Step Counter');
            ylabel('Summed Error on target points, m');
            subplot(2,1,2);
            
            plot(1:size(Conv(:,1:Ind),2),Conv(2,1:Ind),'rx');
            title('Convergence : Angular Momentum, kg*m²/s per optimization step');
            xlabel('Step Counter');
            ylabel('Angular Momentum, kg*m²/s');
%             subplot(3,1,3);
%             plot(1:size(Conv,2),Conv(3,1:end),'rx');
            
            pause;
            clear 'Conv';
            
        else
        end
        
%             figure;
%             hold on;
%             subplot(3,1,1);
%             plot(1:size(Conv,2),Conv(1,1:end),'rx');
%             subplot(3,1,2);
%             plot(1:size(Conv,2),Conv(2,1:end),'rx');
%             subplot(3,1,3);
%             plot(1:size(Conv,2),Conv(3,1:end),'rx');
%         
%             pause;
        close all;
    end
    
    
end
cind

 


 