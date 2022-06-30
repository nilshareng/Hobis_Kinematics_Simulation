% Deuxième phase de l'algo :
% Créations des repères articulaires, Filtrage, Cinématique Inverse et
% Approximation par Splines
% Entrées de ce bloc : Position des marqueurs
% Sorties : Points de contrôles angulaires, (PCA)


% Posture de reference quand ref =1, sinon posture de description -> Ici uniquement description 
reference = 0;

% acq=btkReadAcquisition('C:\Users\nhareng\Downloads\Prog\bvh\manip3.c3d');
% % hypothèse : Position de Réf sur les 10 premières frames
% markers=btkGetMarkers(acq);
N_frame=size(markers.RFWT,1);
Angle= struct;
Articular_Centre = struct;

% Marqueurs utilisés : FWT BWT KNE KNI ANE ANI 


%% définition du repère du monde attaché au pelvis sur la première image 
%construction du repère du monde ramené au bassin : Y parfaitement
%verical, et X et Z parfaitement horizontaux
% remarque : Fem1g, Fem6g... sont exprimés dans ce repère parfaitement
% vertical

Cond = ones(N_frame,1) - ( (markers.RFWT(:,1)==0)&(markers.RFWT(:,2)==0)&(markers.RFWT(:,3)==0)  |   (markers.LFWT(:,1)==0)&(markers.LFWT(:,2)==0)&(markers.LFWT(:,3)==0) );
A = find(Cond);

Y_monde_local=[0 0 1]; 
Z_monde_local=[(markers.RFWT(A(1),1:2) - markers.LFWT(A(1),1:2)) 0];
Z_monde_local=Z_monde_local/norm(Z_monde_local); 
X_monde_local=cross(Y_monde_local,Z_monde_local);
X_monde_local=X_monde_local/norm(X_monde_local); 
R_monde_local=[X_monde_local' Y_monde_local' Z_monde_local']; 

% repère du monde avec Z-up ; utile pour l'affichage des résultats
Z_monde=[0 0 1];
X_monde=X_monde_local; 
Y_monde=cross(Z_monde,X_monde); 
R_monde=[X_monde' Y_monde' Z_monde'];

centre=(markers.LFWT + markers.RFWT)/2; % centre du repère

markers.LKNE=rotateAndCenter(markers.LKNE,centre,R_monde');
markers.LKNI=rotateAndCenter(markers.LKNI,centre,R_monde');
markers.RKNE=rotateAndCenter(markers.RKNE,centre,R_monde');
markers.RKNI=rotateAndCenter(markers.RKNI,centre,R_monde');
markers.LANE=rotateAndCenter(markers.LANE,centre,R_monde');
markers.LANI=rotateAndCenter(markers.LANI,centre,R_monde');
markers.RANE=rotateAndCenter(markers.RANE,centre,R_monde');
markers.RANI=rotateAndCenter(markers.RANI,centre,R_monde');
markers.LFWT=rotateAndCenter(markers.LFWT,centre,R_monde');
markers.RFWT=rotateAndCenter(markers.RFWT,centre,R_monde');
markers.LBWT=rotateAndCenter(markers.LBWT,centre,R_monde');
markers.RBWT=rotateAndCenter(markers.RBWT,centre,R_monde');


%% Récupération Pos Centres Articulaires et Paramètre physiologiques

% Pelvis - Centre 
Articular_Centre.Pelvis =  (markers.LFWT + markers.RFWT)/2;

% Genoux et Chevilles

SPix = 10^-3;

Articular_Centre.LKnee = (markers.LKNE + markers.LKNI)*0.5 - Articular_Centre.Pelvis;
Articular_Centre.RKnee = (markers.RKNE + markers.RKNI)*0.5 - Articular_Centre.Pelvis;
Articular_Centre.LAnkle = (markers.LANE + markers.LANI)*0.5 - Articular_Centre.Pelvis;
Articular_Centre.RAnkle = (markers.RANE + markers.RANI)*0.5 - Articular_Centre.Pelvis;

%maintenant que les marqueurs sont tous exprimés dans le repère monde avec
%X devant et Z up, plus besoin de la distinction suivante
% Selon le positionnement initial du sujet par rapport au monde
% for i = 1:size(markers.RFWT,1)
%     %if (mean(Articular_Centre.RKnee(1:10,1))<0)
%     if (mean(Articular_Centre.RKnee(1:10,1))<0)
%         Articular_Centre.RHip(i,:) = (markers.LFWT(i,:) + markers.RFWT(i,:))/2 + [ -0.38*norm(markers.RFWT(i,:) - markers.LFWT(i,:)) , -0.31*norm((markers.LFWT(i,:)+markers.RFWT(i,:))*0.5-(markers.LBWT(i,:)+markers.RBWT(i,:))*0.5) , -0.096*(norm(markers.RANI(i,:)-markers.RKNE(i,:))+norm(markers.RKNE(i,:)-markers.RFWT(i,:))) ] - Articular_Centre.Pelvis(i,:);
%         Articular_Centre.LHip(i,:) = (markers.LFWT(i,:) + markers.RFWT(i,:))/2 + [  0.38*norm(markers.RFWT(i,:) - markers.LFWT(i,:)) , -0.31*norm((markers.LFWT(i,:)+markers.RFWT(i,:))*0.5-(markers.LBWT(i,:)+markers.RBWT(i,:))*0.5) , -0.096*(norm(markers.LANI(i,:)-markers.LKNE(i,:))+norm(markers.LKNE(i,:)-markers.LFWT(i,:))) ] - Articular_Centre.Pelvis(i,:);
%     else
%         Articular_Centre.RHip(i,:) = (markers.LFWT(i,:) + markers.RFWT(i,:))/2 + [  0.38*norm(markers.RFWT(i,:) - markers.LFWT(i,:)) , -0.31*norm((markers.LFWT(i,:)+markers.RFWT(i,:))*0.5-(markers.LBWT(i,:)+markers.RBWT(i,:))*0.5) , -0.096*(norm(markers.RANI(i,:)-markers.RKNE(i,:))+norm(markers.RKNE(i,:)-markers.RFWT(i,:))) ] - Articular_Centre.Pelvis(i,:);
%         Articular_Centre.LHip(i,:) = (markers.LFWT(i,:) + markers.RFWT(i,:))/2 + [ -0.38*norm(markers.RFWT(i,:) - markers.LFWT(i,:)) , -0.31*norm((markers.LFWT(i,:)+markers.RFWT(i,:))*0.5-(markers.LBWT(i,:)+markers.RBWT(i,:))*0.5) , -0.096*(norm(markers.LANI(i,:)-markers.LKNE(i,:))+norm(markers.LKNE(i,:)-markers.LFWT(i,:))) ] - Articular_Centre.Pelvis(i,:);
%  
%     end
% end

for i = 1:size(markers.RFWT,1)
    Articular_Centre.RHip(i,:) = (markers.LFWT(i,:) + markers.RFWT(i,:))/2; 
    Articular_Centre.LHip(i,:) = (markers.LFWT(i,:) + markers.RFWT(i,:))/2; 
    %par rapport à Leardini, Z est le même, Y chez Leardini est X chez nous
    % et X chez Leardini est -Y chez nous
    Articular_Centre.RHip(i,3) =  Articular_Centre.RHip(i,3) -0.096*(norm(markers.RANI(i,:)-markers.RKNE(i,:))+norm(markers.RKNE(i,:)-markers.RFWT(i,:)));
    Articular_Centre.RHip(i,1) =  Articular_Centre.RHip(i,1) -0.31*norm((markers.LFWT(i,:)+markers.RFWT(i,:))*0.5-(markers.LBWT(i,:)+markers.RBWT(i,:))*0.5) ;
    Articular_Centre.RHip(i,2) =  Articular_Centre.RHip(i,2) -0.38*norm(markers.RFWT(i,:) - markers.LFWT(i,:));
 
    Articular_Centre.LHip(i,3) =  Articular_Centre.LHip(i,3) -0.096*(norm(markers.RANI(i,:)-markers.RKNE(i,:))+norm(markers.RKNE(i,:)-markers.RFWT(i,:)));
    Articular_Centre.LHip(i,1) =  Articular_Centre.LHip(i,1) -0.31*norm((markers.LFWT(i,:)+markers.RFWT(i,:))*0.5-(markers.LBWT(i,:)+markers.RBWT(i,:))*0.5) ;
    Articular_Centre.LHip(i,2) =  Articular_Centre.LHip(i,2) +0.38*norm(markers.RFWT(i,:) - markers.LFWT(i,:));
end
% Hip according to Leardini 1999 où Z est le même que nous, X est égal à -Y
% pour nous, et Y est égal à X pour nous
% rightHipX = ((LFWTx + RFWTx) x 0,5  ) + 0,38 x norm(RFWT - LFWT)  
% rightHipY = ((LFWTy + RFWTy) x 0,5) - 0,31 x norm[((LFWT + RFWT) x 0,5) - ((LBWT + RBWT) x 0,5)] 
% rightHipZ = ((LFWTz + RFWTz) x 0,5  ) - 0,096 x [norm(RANI - RKNE) + norm(RKNE - RFWT)] 
% leftHipX = ((LFWTx + RFWTx) x 0,5  ) - 0,38 x norm(RFWT - LFWT)  
% leftHipY = ((LFWTy + RFWTy) x 0,5) - 0,31 x norm[((LFWT + RFWT) x 0,5) - ((LBWT + RBWT) x 0,5)] 
% leftHipZ = ((LFWTz + RFWTz) x 0,5  ) - 0,096 x [norm(LANI - LKNE) + norm(LKNE - LFWT) 
% 

% Posture de description

% Points to consider per joint
% Les 'Cond' font le tri dans les positions de marqueurs pour éliminer
% les occultations
if ~flag.txt
    Cond = ones(N_frame,1) - ( (markers.LANI(:,1)==0)&(markers.LANI(:,2)==0)&(markers.LANI(:,3)==0)  |   (markers.LKNE(:,1)==0)&(markers.LKNE(:,2)==0)&(markers.LKNE(:,3)==0) |  (markers.RFWT(:,1)==0)&(markers.RFWT(:,2)==0)&(markers.RFWT(:,3)==0) | (markers.LFWT(:,1)==0)&(markers.LFWT(:,2)==0)&(markers.LFWT(:,3)==0)   );
    Fem1g = mean(Articular_Centre.LHip(find(Cond),:))*SPix;
    
    Cond = ones(N_frame,1) - ( (markers.LKNI(:,1)==0)&(markers.LKNI(:,2)==0)&(markers.LKNI(:,3)==0)  |   (markers.LKNE(:,1)==0)&(markers.LKNE(:,2)==0)&(markers.LKNE(:,3)==0) |  (markers.RFWT(:,1)==0)&(markers.RFWT(:,2)==0)&(markers.RFWT(:,3)==0) | (markers.LFWT(:,1)==0)&(markers.LFWT(:,2)==0)&(markers.LFWT(:,3)==0)   );
    Fem6g = [Fem1g(1) Fem1g(2) (mean((markers.LKNE(find(Cond),3)) + markers.LKNI(find(Cond),3))*0.5 - mean(Articular_Centre.Pelvis(find(Cond),3)))*SPix];
    
    Cond = ones(N_frame,1) - ( (markers.RANE(:,1)==0)&(markers.RANE(:,2)==0)&(markers.RANE(:,3)==0)  |   (markers.LANI(:,1)==0)&(markers.LANI(:,2)==0)&(markers.LANI(:,3)==0) |  (markers.RFWT(:,1)==0)&(markers.RFWT(:,2)==0)&(markers.RFWT(:,3)==0) | (markers.LFWT(:,1)==0)&(markers.LFWT(:,2)==0)&(markers.LFWT(:,3)==0)   );
    Tal1g = [Fem1g(1) Fem1g(2) (mean((markers.LANE(find(Cond),3)) + markers.LANI(find(Cond),3))*0.5 -  mean(Articular_Centre.Pelvis(find(Cond),3)))*SPix];
    
    Cond = ones(N_frame,1) - ( (markers.RANI(:,1)==0)&(markers.RANI(:,2)==0)&(markers.RANI(:,3)==0)  |   (markers.RKNE(:,1)==0)&(markers.RKNE(:,2)==0)&(markers.RKNE(:,3)==0) |  (markers.RFWT(:,1)==0)&(markers.RFWT(:,2)==0)&(markers.RFWT(:,3)==0) | (markers.LFWT(:,1)==0)&(markers.LFWT(:,2)==0)&(markers.LFWT(:,3)==0)   );
    Fem1d = mean(Articular_Centre.RHip(find(Cond),:))*SPix;
    
    Cond = ones(N_frame,1) - ( (markers.RKNI(:,1)==0)&(markers.RKNI(:,2)==0)&(markers.RKNI(:,3)==0)  |   (markers.RKNE(:,1)==0)&(markers.RKNE(:,2)==0)&(markers.RKNE(:,3)==0) |  (markers.RFWT(:,1)==0)&(markers.RFWT(:,2)==0)&(markers.RFWT(:,3)==0) | (markers.LFWT(:,1)==0)&(markers.LFWT(:,2)==0)&(markers.LFWT(:,3)==0)   );
    Fem6d = [Fem1d(1) Fem1d(2) (mean((markers.RKNE(find(Cond),3)) + markers.RKNI(find(Cond),3))*0.5 -  mean(Articular_Centre.Pelvis(find(Cond),3)))*SPix];
    
    Cond = ones(N_frame,1) - ( (markers.RANE(:,1)==0)&(markers.RANE(:,2)==0)&(markers.RANE(:,3)==0)  |   (markers.RANI(:,1)==0)&(markers.RANI(:,2)==0)&(markers.RANI(:,3)==0) |  (markers.RFWT(:,1)==0)&(markers.RFWT(:,2)==0)&(markers.RFWT(:,3)==0) | (markers.LFWT(:,1)==0)&(markers.LFWT(:,2)==0)&(markers.LFWT(:,3)==0)   );
    Tal1d = [Fem1d(1) Fem1d(2) (mean((markers.RANE(find(Cond),3)) + markers.RANI(find(Cond),3))*0.5 -  mean(Articular_Centre.Pelvis(find(Cond),3)))*SPix];
    
    %Franck : symétrisation du squelette; inverser la composante latérale; dans
    %le repère monde, ça correspond à Y, comme Z est vers le haut et X vers
    %l'avant
    Fem1d=Fem1g; Fem1d(2)=-Fem1d(2);
    Fem6d=Fem6g; Fem6d(2)=-Fem6d(2);
    Tal1d=Tal1g; Tal1d(2)=-Tal1d(2);
else
    Fem1g = Param(:,1)';
    Fem6g = Param(:,2)';
    Tal1g = Param(:,3)';
    Fem1d = Param(:,4)';
    Fem6d = Param(:,5)';
    Tal1d = Param(:,6)';
end
%% Vérif
% 
% Rep = [Tal1d', Fem6d', Fem1d', zeros(3,1) , Fem1g' , Fem6g' , Tal1g'];
% 
% figure;
% 
% plot3(Rep(1,:), Rep(2,:), Rep(3,:));
% axis([-0.5 0.5 -0.5 0.5 -1 0.1]);
% 
% Fem1g = [0.1100    0.1080   -0.0524];
% Fem6g = [0.1030    0.0761   -0.4947];
% Tal1g = [0.0922    0.1029   -0.9585];
% Fem1d = [-0.1100    0.1080   -0.0528];
% Fem6d = [-0.1030    0.0761   -0.4947];
% Tal1d = [-0.0922    0.1029   -0.9585];
% Rep2 = [Tal1d', Fem6d', Fem1d', zeros(3,1) , Fem1g' , Fem6g' , Tal1g'];
% 
% figure;
% 
% plot3(Rep2(1,:), Rep2(2,:), Rep2(3,:));
% axis([-0.5 0.5 -0.5 0.5 -1 0.1]);

%% Lancement des scripts de calcul suivants

%%% Creation Reperes Articulaires

CreationRepere;

%%% Filtrage et périodisation Angles
if ~flag.txt
    FiltragePeriod;
else
    % Si initialisation par .txt, chargement marche ini, empreintes cibles, IK Desr - Ref, IK Ref - PI marche ini 
    Alterations;
end
%%% Approximation en Splines
if ~flag.txt
    ApproxSpline;
else
    % Mb nothing, depends on prev loop
end






%% Affichages
% figure;
% hold on;
% 
% for i =1:11
%     subplot(3,4,i);
%     hold on;
%     plot(1:size(NewCurve,1),NewCurve(1:end,i),'b')
%     plot(1:size(FAngles,1),FAngles(:,i),'r')
%     t=PCA(PCA(:,1)==i,2:3);
%     plot(t(:,1)*Period,t(:,2),'rx');
% end

% O = [1,2,3,6,5,4,7,10,9,8,11];
% 
% Marche= NewCurve(:,O);
% Marche(:,7) = -Marche(:,7);
% Marche(:,11) = -Marche(:,11);

% PCA(PCA(:,1)==7,3) = -PCA(PCA(:,1)==7,3);
% PCA(PCA(:,1)==11,3) = -PCA(PCA(:,1)==11,3);
% 
% t= PCA(PCA(:,1)==4,:);
% 
% PCA(PCA(:,1)==4,2:3) = PCA(PCA(:,1)==6,2:3); 

% figure;
% hold on;
% 
% for i =1:11
%     subplot(3,4,i);
%     hold on;
%     plot(1:size(NewCurve,1),NewCurve(1:end,i)*180/pi,'k')
% %     plot(1:size(Marche,1),Marche(1:end,i)*180/pi,'b')
%     plot(1:size(FAngles,1),FAngles(:,i)*180/pi,'r')
%     t=PCA(PCA(:,1)==i,2:3);
% %     plot(t(:,1)*Period,t(:,2),'rx');
% end
% legend('Spline','Angles')

% PA=[];
% PN=[];
% % PM=[];
% for i =1:size(FAngles,1)
%     PA = [PA; fcine_numerique_H([FAngles(i,:),0],Param(:,1),Param(:,2),Param(:,3),Param(:,4),Param(:,5),Param(:,6))'];
%     PN = [PN; fcine_numerique_H([NewCurve(i,:),0],Param(:,1),Param(:,2),Param(:,3),Param(:,4),Param(:,5),Param(:,6))'];
% %     PM = [PM; fcine_numerique_H(Marche(i,:),Param(:,1),Param(:,2),Param(:,3),Param(:,4),Param(:,5),Param(:,6))'];
% end


% 
% figure;
% hold on;
% GT = [Articular_Centre.LAnkle(1004:1207,:) , Articular_Centre.RAnkle(1004:1207,:)]*0.001;
% for i =1:6
%     subplot(2,3,i);
%     hold on;
%     plot(1:size(PA,1),PA(:,i),'b');
%     plot(1:size(PN,1),PN(:,i),'g');
% %     plot(1:size(PM,1),PM(:,i),'k');
%     plot(1:size(GT), GT(:,i),'r');
% end


%% Transformation de la poulaine cible en spline -> Utile dans le cas d'utilisation normal de l'algo... 


% Restriction de la poulaine à l'intervalle d'intérêt
Period1= Period-23;
% GT = GT(Bornes(1):(Bornes(1)+Period1-1),:);
if flag.txt
    GT = PN;
    NewPoul = GT;
else
    GT = GT(1:(Period+1),:);
    % GT = GT(Bornes(1):Bornes(2),:);
    
    % % Symétrisation de la poulaine ciblée
    % GT = GT(Bornes(1):(Bornes(1)+Period1-1),:);
    % GT = GT(Bornes(1):(Bornes(1)+Period1-1),:);
    %
    %
    mid = fix((Period)/2);
    
    GT(:,4:6) = [GT(mid:end,1) , -GT(mid:end,2) , GT(mid:end,3) ; GT(1:mid-1,1) , -GT(1:mid-1,2) ,GT(1:mid-1,3) ];
    %
    
    % % Symétrisation Poulaine Cible
    
    % GT(:,6) = [-GT(mid:end-1,3);-GT(1:mid,3)];
    % GT(:,4:5) = [GT(mid:end-1,2:3);GT(1:mid,2:3)];
    %
    % P(:,6) = [-P(mid:end-1,1);-P(1:mid,1)];
    % P(:,4:5) = [P(mid:end-1,2:3);P(1:mid,2:3)];
    
    % GT into spline
    % Filtrage
    freq=5;
    [b,a] = butter(2 , freq/(0.5*rate) , 'low');
    NewPoul=filtfilt(b,a,GT);
    PolP=[];
    NewP=[];
    
    for i = 1:6
        [temp, tempol] = Curve2Spline(NewPoul(:,i));
        PolP = [PolP ;  i*ones(size(tempol,1),1),tempol];
        NewP=[NewP, temp'];
    end
    
    NewP(:,4:6) = [NewP(mid:end,1) , -NewP(mid:end,2) , NewP(mid:end,3) ; NewP(1:mid-1,1) , -NewP(1:mid-1,2) , NewP(1:mid-1,3)];
    
    GT = NewP;

end

if printflag
figure;
hold on;
for i =1:6
    subplot(2,3,i);
    hold on;
    plot(1:size(P,1),P(:,i),'b');
    plot(1:size(PN,1),PN(:,i),'g');
    plot(1:size(GT), GT(:,i),'r--');
%     plot(1:size(NewP), NewP(:,i),'r');
end
end









