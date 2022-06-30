% Etape de filtrage passe-bas des angles obtenus précédemment
% Entrée : Angles contenus dans NAngles


printflag =0;

% On prend les angles du Pelvis, des Hanches, et Z ISB Genou est confondu avec Xmonde donc Knee(1,:)  
NAngles =  [Angle.Angle_Pelvis' , Angle.Angle_LHip' , Angle.Angle_LKnee(3,:)',  Angle.Angle_RHip' , Angle.Angle_RKnee(3,:)'];

% On ne prend que le cycle de marche repéré dans les données initiales
Angles2 = NAngles(Bornes(1):Bornes(2),:);

% Contrôle
if printflag
    % Affichage des Angles sélectionnés
    gcf=figure;
    hold on;
    for i =1:11
        subplot(3,4,i);
        plot(1:size(NAngles,1),NAngles(:,i))
    end
    figure;
    hold on;
    for i =1:11
        subplot(3,4,i);
        plot(1:size(Angles2,1),Angles2(:,i))
    end

end

%% Filtrage et périodisation Angles


% Butterworth filter
freq = 3; % au lieu de 5, ça filtre plus fort
rate = 60;

% Franck : erreur ici, c'est la demi-fréquence d'échantillonnage pas le
% double
[b,a] = butter(2 , freq/(0.5*rate) , 'low');
%[b,a] = butter(2 , freq/(2*rate) , 'low');

% Filtrage et Périodicité
Param = [Fem1g',Fem6g',Tal1g', Fem1d', Fem6d', Tal1d'];

% Filtrage sur 3 périodes sélection du milieu
%FAngles = [Angles2 ;Angles2 ;Angles2];
%FAngles = filtfilt(b,a,FAngles);
%FAngles = FAngles(Period+1:2*Period+1,:);
% Franck : pour le filtrage sur un seul cycle, car l'intervalle ici est
% plus long qu'un cycle et ça créée un problème
FAngles = filtfilt(b,a,Angles2);
FAngles = cyclify(FAngles,15); % cyclifier avec un décalage max de 15 images

NAngles= NAngles(1:Bornes(2),:);

% Récupération de la Poulaine capturée
GT = [Articular_Centre.LAnkle , Articular_Centre.RAnkle]*SPix;
TrajArt =struct;


%% Affichages pour Contrôle

% Trajectoires capturée des centres articulaires vs trajectoires calculées

Res = zeros(6,size(NAngles,1));
Save = zeros(4,6*size(NAngles,1));

tlhip=[]; trhip=[]; tlknee=[]; trknee=[]; tlank=[]; trank=[]; 
if printflag
for i =1:size(NAngles,1)
    [tres,tSave]= fcine_numerique_H2(NAngles(i,:),Fem1g,Fem6g,Tal1g,Fem1d,Fem6d,Tal1d, R_monde_local,R_Pelvis_monde_local, R_LFem_ref_local, R_LTib_ref_local, R_RFem_ref_local, R_RTib_ref_local);
    tlhip=[tlhip; tSave(2:4,1)']; 
    trhip=[trhip; tSave(2:4,4)']; 
    tlknee=[tlknee; tSave(2:4,2)']; 
    trknee=[trknee; tSave(2:4,5)']; 
    tlank=[tlank; tSave(2:4,3)']; 
    trank=[trank; tSave(2:4,6)']; 

    [Res(:,i) , Save(:,(6*i-5):6*i)] = fcine_numerique_H2(NAngles(i,:),Fem1g,Fem6g,Tal1g,Fem1d,Fem6d,Tal1d, R_monde_local,R_Pelvis_monde_local, R_LFem_ref_local, R_LTib_ref_local, R_RFem_ref_local, R_RTib_ref_local);
%     TrajArt.RHip(i,:) = R_Pelvis(:,:,i)*SPix*Articular_Centre.RHip(i,:)';
%     TrajArt.LHip(i,:) = R_Pelvis(:,:,i)*SPix*Articular_Centre.LHip(i,:)';
%     TrajArt.RKnee(i,:) = R_Pelvis(:,:,i)*SPix*Articular_Centre.RKnee(i,:)';
%     TrajArt.LKnee(i,:) = R_Pelvis(:,:,i)*SPix*Articular_Centre.LKnee(i,:)'; 
%     TrajArt.RAnkle(i,:) = R_Pelvis(:,:,i)*SPix*Articular_Centre.RAnkle(i,:)';
%     TrajArt.LAnkle(i,:) = R_Pelvis(:,:,i)*SPix*Articular_Centre.LAnkle(i,:)';

    TrajArt.RHip(i,:) = SPix*Articular_Centre.RHip(i,:)';
    TrajArt.LHip(i,:) = SPix*Articular_Centre.LHip(i,:)';
    TrajArt.RKnee(i,:) = SPix*Articular_Centre.RKnee(i,:)';
    TrajArt.LKnee(i,:) = SPix*Articular_Centre.LKnee(i,:)'; 
    TrajArt.RAnkle(i,:) = SPix*Articular_Centre.RAnkle(i,:)';
    TrajArt.LAnkle(i,:) = SPix*Articular_Centre.LAnkle(i,:)';

end

close all;

figure;
hold on;
plot(1:size(NAngles,1), TrajArt.RHip);
title('RHip');
legend('X','Y','Z');
figure;
hold on;

plot(1:size(NAngles,1), Save(2:4,Save(1,:)==4)');
title('RHip Calc');
legend('X','Y','Z');

figure;
hold on;
plot(1:size(NAngles,1), TrajArt.LHip);
title('LHip');
legend('X','Y','Z');
figure;
hold on;
plot(1:size(NAngles,1), Save(2:4,Save(1,:)==1)');
title('LHip Calc');
legend('X','Y','Z');

figure;
hold on;
plot(1:size(NAngles,1), TrajArt.RKnee);
title('RKnee');
legend('X','Y','Z');
figure;
hold on;
plot(1:size(NAngles,1), Save(2:4,Save(1,:)==5)');
title('RKnee Calc');
legend('X','Y','Z');

figure;
hold on;
plot(1:size(NAngles,1), TrajArt.LKnee);
title('LKnee');
legend('X','Y','Z');
figure;
hold on;
plot(1:size(NAngles,1), Save(2:4,Save(1,:)==2)');
title('LKnee Calc');
legend('X','Y','Z');

figure;
hold on;
plot(1:size(NAngles,1), TrajArt.RAnkle);
title('RAnkle');
legend('X','Y','Z');
figure;
hold on;
plot(1:size(NAngles,1), Save(2:4,Save(1,:)==6)');
title('RAnkle Calc');
legend('X','Y','Z');

figure;
hold on;
plot(1:size(NAngles,1), TrajArt.LAnkle);
title('LAnkle');
legend('X','Y','Z');
figure;
hold on;
plot(1:size(NAngles,1), Save(2:4,Save(1,:)==3)');
title('LAnkle Calc');
legend('X','Y','Z');



figure;
hold on;

for i=1:6
    subplot(2,3,i);
    hold on;
    plot(1:size(GT(1:Bornes(2),:),1), GT(1:Bornes(2),i));
    plot(1:size(GT(1:Bornes(2),:),1), Res(i,:));
end

end
