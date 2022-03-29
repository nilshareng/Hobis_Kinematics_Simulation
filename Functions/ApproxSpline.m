% Phase d'approximation par Spline
% Entrées : TA calculées à partir de la capture : FAngles
% Sortie : PCA / Pol -> Splines des TA originales, symétrisées, périodiques

% Pour léaffichage des graphes de contrôle
printflag=1;

OldPeriod=Period;
Period = size(FAngles,1);

% Périodisation FAngles
FAngles = [FAngles ; FAngles(1,:)];

% Détermination Points de Contrôles sous la forme [n°DDL t Theta]
PCA = ForgePCA(FAngles,0:1/Period:1,1);

% Obtention des Polynômes des Splines
Pol = [];
% Pour chaque DDL
for i =1:PCA(end,1)
    Pol = [Pol ; PC_to_spline(PCA(PCA(:,1)==i,2:3),1)];
end
Pol(:,1) = PCA(:,1);

% Echantillonnage pour la courbe des TA
NewCurve = [];
% for i =1:Pol(end,1)
%     NewCurve = [NewCurve , spline_to_curve_int(Pol(Pol(:,1)==i,:),Period)'];
% end
for i =1:Period+1
    tmp=zeros(1,11);
    for j=1:11
        tmp(j) = EvalSpline(Pol(Pol(:,1)==j,:),((i-1))/Period);
    end
    NewCurve = [NewCurve ; tmp];
end



if printflag
figure;
hold on;

for i =1:11
    subplot(3,4,i);
    hold on;
    plot(1:size(NewCurve,1),NewCurve(1:end,i),'b')
    plot(1:size(FAngles,1),FAngles(:,i),'r')
    t=PCA(PCA(:,1)==i,2:3);
    plot(t(:,1)*Period,t(:,2),'rx');
end

figure;
hold on;
for i =1:11
    subplot(3,4,i);
    hold on;
    plot(1:size(FAngles,1),FAngles(:,i))
    t=PCA(PCA(:,1)==i,2:3);
    plot(t(:,1)*Period,t(:,2),'rx');
end
end

% Calcul des Poulaines
P=[];
PN=[];
for i =1:Period+1
    P = [P; fcine_numerique_H2(FAngles(i,:),Param(:,1)',Param(:,2)',Param(:,3)',Param(:,4)',Param(:,5)',Param(:,6)', R_monde_local,R_Pelvis_monde_local, R_LFem_ref_local, R_LTib_ref_local, R_RFem_ref_local, R_RTib_ref_local)'];
    PN = [PN; fcine_numerique_H2(NewCurve(i,:),Param(:,1)',Param(:,2)',Param(:,3)',Param(:,4)',Param(:,5)',Param(:,6)', R_monde_local,R_Pelvis_monde_local, R_LFem_ref_local, R_LTib_ref_local, R_RFem_ref_local, R_RTib_ref_local)'];
   
%     PN = [PN; fcine_numerique_H2(NewCurve(i,:),Param(:,1),Param(:,2),Param(:,3),Param(:,4),Param(:,5),Param(:,6)', R_monde_local,R_Pelvis_monde_local, R_LFem_ref_local, R_LTib_ref_local, R_RFem_ref_local, R_RTib_ref_local)'];

end

% Restriction de la poulaine à l'intervalle d'intérêt
% Period1= Period-23;
% GT = GT(Bornes(1):(Bornes(1)+Period1-1),:);
GT = GT(Bornes(1):Bornes(2),:);

% mid = fix(Period1/2);

% % Symétrisation de la poulaine ciblée
% GT = GT(Bornes(1):(Bornes(1)+Period1-1),:);
% GT = GT(Bornes(1):(Bornes(1)+Period-1),:);


% GT(:,4:6) = [GT(mid:end,1) , -GT(mid:end,2) , GT(mid:end,3) ; GT(1:mid-1,1) , -GT(1:mid-1,2) ,GT(1:mid-1,3) ];


    if printflag
    figure;
    hold on;
    for i =1:6
        subplot(2,3,i);
        hold on;
        plot(1:size(P,1),P(:,i),'b');
        plot(1:size(PN,1),PN(:,i),'g');
        plot(1:size(GT,1), GT(:,i),'r');
    end
    % figure ;
    % hold on;
    % G = [Articular_Centre.LAnkle(800:1300,:) , Articular_Centre.RAnkle(800:1300,:)]*SPix;
    % for i=1:6
    %     subplot(2,3,i);
    %     hold on;
    %     plot(1:size(G,1),G(:,i),'b');
    % end
    end




% Mesure de l'écart % courbe acquisition Angles - Sélection meilleure
% version G/D à prendre ; Symétrisation membres opposés

% Ecart par courbe
S = Period;%size(FAngles,1)-1;
mid = fix(S/2);

OFAngles = FAngles;
OCurve = NewCurve;
OPol = Pol;
OPN = PN;

E = [];
for i = 1 :11
    E = [E , abs(FAngles(:,i) - NewCurve(:,i))];
end

% Hanche1 -> Déphasage demi cycle + Oppo

if sum(E(:,4)   )>sum(E(:,8))
    FAngles(:,4) = [-FAngles(mid:end-1,8); -FAngles(1:mid,8)];
    t=PCA(PCA(:,1)==8,:);
    % Ajustement des PCA
    for i = 1:size(t,1)
        if t(i,2)*S+1>mid
           t(i,2:3)=[t(i,2)-(mid/Period) , -t(i,3)];
        else
            t(i,2:3)=[t(i,2)+((S - mid+2)/Period) , -t(i,3)];
        end
        PCA(PCA(:,1)==4,2:3)=t(:,2:3);
    end
else
    FAngles(:,8) = [-FAngles(mid:end-1,4); -FAngles(1:mid,4)];
    t=PCA(PCA(:,1)==4,:);
    % Ajustement des PCA
    for i = 1:size(t,1)
        if t(i,2)*S+1>mid
           t(i,2:3)=[t(i,2)-(mid/Period) , -t(i,3)];
        else
            t(i,2:3)=[t(i,2)+((S - mid+2)/Period) , -t(i,3)];
        end
        PCA(PCA(:,1)==8,2:3)=t(:,2:3);
    end
end

% HancheY -> Déphasage demi cycle + Opposées

if sum(E(:,5))>sum(E(:,9))
    FAngles(:,5) = [-FAngles(mid:end-1,9); -FAngles(1:mid,9)];
    t=PCA(PCA(:,1)==9,:);
    % Ajustement des PCA
    for i = 1:size(t,1)
        if t(i,2)*S+1>mid
           t(i,2:3)=[t(i,2)-((mid+2)/Period) , -t(i,3)];
        else
            t(i,2:3)=[t(i,2)+((S - mid+4)/Period) , -t(i,3)];
        end
        PCA(PCA(:,1)==5,2:3)=t(:,2:3);
    end
else
    FAngles(:,9) = [-FAngles(mid:end-1,5); -FAngles(1:mid,5)];
    t=PCA(PCA(:,1)==5,:);
    % Ajustement des PCA
    for i = 1:size(t,1)
        if t(i,2)*S+1>mid
           t(i,2:3)=[t(i,2)-(mid/Period) , -t(i,3)];
        else
            t(i,2:3)=[t(i,2)+((S - mid+2)/Period) , -t(i,3)];
        end
        PCA(PCA(:,1)==9,2:3)=t(:,2:3);
    end
end

% HancheZ -> Déphasage demi cycle 

if sum(E(:,6))>sum(E(:,10))
    FAngles(:,6) = [FAngles(mid:end-1,10); FAngles(1:mid,10)];
    t=PCA(PCA(:,1)==10,:);
    % Ajustement des PCA
    for i = 1:size(t,1)
        if t(i,2)*S+1>mid
           t(i,2:3)=[t(i,2)-(mid/Period) , t(i,3)];
        else
            t(i,2:3)=[t(i,2)+((S - mid+2)/Period) , t(i,3)];
        end
        PCA(PCA(:,1)==6,2:3)=t(:,2:3);
    end
else
    FAngles(:,10) = [FAngles(mid:end-1,6); FAngles(1:mid,6)];
    t=PCA(PCA(:,1)==6,:);
    % Ajustement des PCA
    for i = 1:size(t,1)
        if t(i,2)*S+1>mid
           t(i,2:3)=[t(i,2)-(mid/Period) , t(i,3)];
        else
            t(i,2:3)=[t(i,2)+((S - mid+2)/Period) , t(i,3)];
        end
        PCA(PCA(:,1)==10,2:3)=t(:,2:3);
    end
end

% Genoux -> Déphasage demi cycle

if sum(E(:,7))>sum(E(:,11)) 
    FAngles(:,7) = [FAngles(mid:end-1,11); FAngles(1:mid,11)];
    t=PCA(PCA(:,1)==11,:);
    % Ajustement des PCA
    for i = 1:size(t,1)
        if t(i,2)*S+1>mid
           t(i,2:3)=[t(i,2)-(mid/Period) , t(i,3)];
        else
            t(i,2:3)=[t(i,2)+((S - mid+2)/Period) , t(i,3)];
        end
        PCA(PCA(:,1)==7,2:3)=t(:,2:3);
    end
else
    FAngles(:,11) = [FAngles(mid:end-1,7); FAngles(1:mid,7)];
    t=PCA(PCA(:,1)==7,:);
    % Ajustement des PCA
    for i = 1:size(t,1)
        if t(i,2)*S+1>mid
           t(i,2:3)=[t(i,2)-(mid/Period) , t(i,3)];
        else
            t(i,2:3)=[t(i,2)+((S - mid+2)/Period) , t(i,3)];
        end
        PCA(PCA(:,1)==11,2:3)=t(:,2:3);
    end
end


% Symétrisation bassin

% Bassin Y

Delta =mean(FAngles(:,2));
FAngles(:,2) = FAngles(:,2) - Delta;
PCA(PCA(:,1)==2,3)=PCA(PCA(:,1)==2,3)-Delta;

% Bassin X

Delta  =mean(FAngles(:,3));
FAngles(:,3) = FAngles(:,3) - Delta;
PCA(PCA(:,1)==3,3)=PCA(PCA(:,1)==3,3)-Delta;


for i=8:11
    % On symétrise en déphasant
    PCA(PCA(:,1)==i,2:3)=[PCA(PCA(:,1)==i-4,2)+mid/Period, PCA(PCA(:,1)==i-4,3)];
    if i==9 || i==8
        % Et en inversant pour HY et HX
        PCA(PCA(:,1)==i,3)= -PCA(PCA(:,1)==i,3);
    end
    % Rangement des PCA dans l'ordre croissant de t
    PCA(PCA(:,1)==i,2) = PCA(PCA(:,1)==i,2)- fix(PCA(PCA(:,1)==i,2));
    tmp = PCA(PCA(:,1)==i,2:3);
    [~,I]=sort(tmp(:,2));
    PCA(PCA(:,1)==i,2:3) = tmp(I,:);
end




% To prevent crashes... (Un PCA à 0 en t mes fonctions n'aiment pas...)
for i =1:size(PCA,1)
    if PCA(i,2)==0
        PCA(i,2)=eps;
    end
end


% Rangement PCA + Recalcul Polynomes

for i=8:11
%     PCA(PCA(:,1)==i,2:3)=[PCA(PCA(:,1)==i-4,2)+0.5 , PCA(PCA(:,1)==i-4,3)];
%     if i==9 || i==10
%         PCA(PCA(:,1)==i,3)= -PCA(PCA(:,1)==i,3);
%     end
%     PCA(PCA(:,1)==i,2) = PCA(PCA(:,1)==i,2)- fix(PCA(PCA(:,1)==i,2));
    tmp = PCA(PCA(:,1)==i,2:3);
    [~,I]=sort(tmp(:,2));
    PCA(PCA(:,1)==i,2:3) = tmp(I,:);
end
%%%
Pol = [];
for i =1:PCA(end,1)
    tmp = PCA(PCA(:,1)==i,2:3);
    [~,I]=sort(tmp(:,1));
    PCA(PCA(:,1)==i,2:3) = tmp(I,:);
    Pol = [Pol ; PC_to_spline(PCA(PCA(:,1)==i,2:3),1)];
end
Pol(:,1) = PCA(:,1);

NewCurve = [];
% for i =1:Pol(end,1)
%     NewCurve = [NewCurve , spline_to_curve_int(Pol(Pol(:,1)==i,:),Period)'];
% end

for i =1:Period+1
    tmp=zeros(1,11);
    for j=1:11
        tmp(j) = EvalSpline(Pol(Pol(:,1)==j,:),((i-1))/Period);
    end
    NewCurve = [NewCurve ; tmp];
end

% save()

% NewCurve = OCurve;
% Pol = OPol;
% PN = OPN;


% Comparaison des courbes de TA : Originales OFAngles, post symétrisation PCA Newcurve, post sym FAngles 
if printflag
figure;
hold on;


for i =1:11
    subplot(3,4,i);
    hold on;
    plot(1:size(NewCurve,1),NewCurve(1:end,i),'b')
    plot(1:size(FAngles,1),FAngles(:,i),'k')
    plot(1:size(OFAngles,1),OFAngles(1:end,i),'r--')
    t=PCA(PCA(:,1)==i,2:3);
    plot(t(:,1)*Period,t(:,2),'rx');
end
end
P=[];
PN=[];
for i =1:Period+1
    P = [P; fcine_numerique_H2(FAngles(i,:),Param(:,1)',Param(:,2)',Param(:,3)',Param(:,4)',Param(:,5)',Param(:,6)', R_monde_local,R_Pelvis_monde_local, R_LFem_ref_local, R_LTib_ref_local, R_RFem_ref_local, R_RTib_ref_local)'];
    PN = [PN; fcine_numerique_H2(NewCurve(i,:),Param(:,1)',Param(:,2)',Param(:,3)',Param(:,4)',Param(:,5)',Param(:,6)', R_monde_local,R_Pelvis_monde_local, R_LFem_ref_local, R_LTib_ref_local, R_RFem_ref_local, R_RTib_ref_local)'];
end

if PN(end,:) ~= PN(1,:)
    PN(end,:) = PN(1,:);
end
% GT = [GT ; Articular_Centre.LAnkle(Bornes(1),:)*SPix , Articular_Centre.RAnkle(Bornes(1),:)*SPix];

% NewCurve = OCurve;
% Pol = OPol;
% PN = OPN;
% Contrôle des trajectoires de poulaines reconstruites par les TA Originales P - et approchées PN
if printflag
figure;
hold on;
for i =1:6
    subplot(2,3,i);
    hold on;
    plot(1:size(P,1),P(:,i),'b');
    plot(1:size(PN,1),PN(:,i),'g');
    plot(1:size(GT), GT(:,i),'r');
end
end






