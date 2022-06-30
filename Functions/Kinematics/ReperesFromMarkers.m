function [Reperes, Seq, markers, Param] = ReperesFromMarkers(markers)
% From posture markers, computes the segment and segment CS, positions and orientations 
% Also provides the corresponding joints angles for said posture
% For Description - gives the "zero angles" and body parameters
% For Reference - no need, just IK from description


Reperes = struct;
SPix = 10^-3;

% Calcul de l'angle, méthode Olfa ou Matlab, Matlab ne marche que pour XYZ, ZYX et ZXZ
Olfa = 1;

% Définition des ordres de rotations des angles d'Euler pour les calculs
% d'angles
if Olfa
    OrdrePelv = 'xyz';
    OrdreLHip = 'zyx';
    OrdreLKnee = 'zyx';
    OrdreRHip = 'zyx';
    OrdreRKnee = 'zyx';
else
    OrdrePelv = 'XYZ';
    OrdreLHip = 'ZYX';
    OrdreLKnee = 'ZYX';
    OrdreRHip = 'ZYX';
    OrdreRKnee = 'ZYX';
end

Seq.Pelvis = OrdrePelv;
Seq.LHip = OrdreLHip;
Seq.LKnee = OrdreLKnee;
Seq.RHip = OrdreRHip;
Seq.RKnee = OrdreRKnee;

% printflag =1 pour activer les affichages de figures
printflag = 0;

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

if isempty(A)
   error('No complete frames for the kinematic chain creation'); 
end

Y_monde_local=[0 0 1]; 
Z_monde_local=[(markers.RFWT(A(1),1:2) - markers.LFWT(A(1),1:2)) 0];
Z_monde_local=Z_monde_local/norm(Z_monde_local); 
X_monde_local=cross(Y_monde_local,Z_monde_local);
X_monde_local=X_monde_local/norm(X_monde_local); 
R_monde_local=[X_monde_local' Y_monde_local' Z_monde_local']; 

centre=(markers.LFWT + markers.RFWT)/2; % centre du repère pelvis - nouvelle origine monde 

Reperes.MondeLocal = eye(4);
Reperes.MondeLocal(1:3,1:3) = R_monde_local;

% repère du monde avec Z-up ; utile pour l'affichage des résultats
Z_monde=[0 0 1];
X_monde=X_monde_local; 
Y_monde=cross(Z_monde,X_monde); 
R_monde=[X_monde' Y_monde' Z_monde'];

Reperes.Monde = eye(4);
Reperes.Monde(1:3,1:3) = R_monde;


originalmarkers = markers;

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
markers.LHRC=rotateAndCenter(markers.LHRC,centre,R_monde');
markers.RHRC=rotateAndCenter(markers.RHRC,centre,R_monde');
markers.RFem9=rotateAndCenter(markers.RFem9,centre,R_monde');
markers.LFem9=rotateAndCenter(markers.LFem9,centre,R_monde');
markers.RFem6=rotateAndCenter(markers.RFem6,centre,R_monde');
markers.LFem6=rotateAndCenter(markers.LFem6,centre,R_monde');
markers.RTib6=rotateAndCenter(markers.RTib6,centre,R_monde');
markers.LTib6=rotateAndCenter(markers.LTib6,centre,R_monde');
markers.RTib1=rotateAndCenter(markers.RTib1,centre,R_monde');
markers.LTib1=rotateAndCenter(markers.LTib1,centre,R_monde');
markers.RTal1=rotateAndCenter(markers.RTal1,centre,R_monde');
markers.LTal1=rotateAndCenter(markers.LTal1,centre,R_monde');


%% Récupération Pos Centres Articulaires et Paramètre physiologiques

% Pelvis - Centre 
Articular_Centre.Pelvis =  (markers.LFWT + markers.RFWT)/2;

% Genoux et Chevilles

Articular_Centre.LKnee = (markers.LKNE + markers.LFem9)*0.5 + (markers.LKNI + markers.LTib6)*0.5 ;
Articular_Centre.RKnee = (markers.RKNE + markers.RFem9)*0.5 + (markers.RKNI + markers.RTib6)*0.5 ;
Articular_Centre.LAnkle = markers.LTal1 ;
Articular_Centre.RAnkle = markers.RTal1 ;
Articular_Centre.RHip = markers.RHRC ;
Articular_Centre.LHip = markers.LHRC ;

% Posture de description

% Points to consider per joint
% Les 'Cond' font le tri dans les positions de marqueurs pour éliminer
% les occultations
% Cond = ones(N_frame,1) - ( (markers.LANI(:,1)==0)&(markers.LANI(:,2)==0)&(markers.LANI(:,3)==0)  |   (markers.LKNE(:,1)==0)&(markers.LKNE(:,2)==0)&(markers.LKNE(:,3)==0) |  (markers.RFWT(:,1)==0)&(markers.RFWT(:,2)==0)&(markers.RFWT(:,3)==0) | (markers.LFWT(:,1)==0)&(markers.LFWT(:,2)==0)&(markers.LFWT(:,3)==0)   );
Fem1g = markers.LHRC * SPix; %mean(Articular_Centre.LHip(find(Cond),:))*SPix;

% Cond = ones(N_frame,1) - ( (markers.RANI(:,1)==0)&(markers.RANI(:,2)==0)&(markers.RANI(:,3)==0)  |   (markers.RKNE(:,1)==0)&(markers.RKNE(:,2)==0)&(markers.RKNE(:,3)==0) |  (markers.RFWT(:,1)==0)&(markers.RFWT(:,2)==0)&(markers.RFWT(:,3)==0) | (markers.LFWT(:,1)==0)&(markers.LFWT(:,2)==0)&(markers.LFWT(:,3)==0)   );
Fem1d = markers.RHRC * SPix;

% Cond = ones(N_frame,1) - ( (markers.LKNI(:,1)==0)&(markers.LKNI(:,2)==0)&(markers.LKNI(:,3)==0)  |   (markers.LKNE(:,1)==0)&(markers.LKNE(:,2)==0)&(markers.LKNE(:,3)==0) |  (markers.RFWT(:,1)==0)&(markers.RFWT(:,2)==0)&(markers.RFWT(:,3)==0) | (markers.LFWT(:,1)==0)&(markers.LFWT(:,2)==0)&(markers.LFWT(:,3)==0)   );
Fem6g = markers.LFem6 * SPix;%[Fem1g(1) Fem1g(2) (mean((markers.LKNE(find(Cond),3)) + markers.LKNI(find(Cond),3))*0.5 - mean(Articular_Centre.Pelvis(find(Cond),3)))*SPix];

% Cond = ones(N_frame,1) - ( (markers.RKNI(:,1)==0)&(markers.RKNI(:,2)==0)&(markers.RKNI(:,3)==0)  |   (markers.RKNE(:,1)==0)&(markers.RKNE(:,2)==0)&(markers.RKNE(:,3)==0) |  (markers.RFWT(:,1)==0)&(markers.RFWT(:,2)==0)&(markers.RFWT(:,3)==0) | (markers.LFWT(:,1)==0)&(markers.LFWT(:,2)==0)&(markers.LFWT(:,3)==0)   );
Fem6d = markers.RFem6 * SPix;%[Fem1d(1) Fem1d(2) (mean((markers.RKNE(find(Cond),3)) + markers.RKNI(find(Cond),3))*0.5 -  mean(Articular_Centre.Pelvis(find(Cond),3)))*SPix];

% Cond = ones(N_frame,1) - ( (markers.RANE(:,1)==0)&(markers.RANE(:,2)==0)&(markers.RANE(:,3)==0)  |   (markers.LANI(:,1)==0)&(markers.LANI(:,2)==0)&(markers.LANI(:,3)==0) |  (markers.RFWT(:,1)==0)&(markers.RFWT(:,2)==0)&(markers.RFWT(:,3)==0) | (markers.LFWT(:,1)==0)&(markers.LFWT(:,2)==0)&(markers.LFWT(:,3)==0)   );
Tal1g = markers.LTal1 * SPix;%[Fem1g(1) Fem1g(2) (mean((markers.LANE(find(Cond),3)) + markers.LANI(find(Cond),3))*0.5 -  mean(Articular_Centre.Pelvis(find(Cond),3)))*SPix];

% Cond = ones(N_frame,1) - ( (markers.RANE(:,1)==0)&(markers.RANE(:,2)==0)&(markers.RANE(:,3)==0)  |   (markers.RANI(:,1)==0)&(markers.RANI(:,2)==0)&(markers.RANI(:,3)==0) |  (markers.RFWT(:,1)==0)&(markers.RFWT(:,2)==0)&(markers.RFWT(:,3)==0) | (markers.LFWT(:,1)==0)&(markers.LFWT(:,2)==0)&(markers.LFWT(:,3)==0)   );
Tal1d = markers.RTal1 * SPix;%[Fem1d(1) Fem1d(2) (mean((markers.RANE(find(Cond),3)) + markers.RANI(find(Cond),3))*0.5 -  mean(Articular_Centre.Pelvis(find(Cond),3)))*SPix];

%Franck : symétrisation du squelette; inverser la composante latérale; dans
%le repère monde, ça correspond à Y, comme Z est vers le haut et X vers
% %l'avant
% Fem1d=Fem1g; Fem1d(2)=-Fem1d(2);
% Fem6d=Fem6g; Fem6d(1)=-Fem6d(1);
% Tal1d=Tal1g; Tal1d(2)=-Tal1d(2);

Param = [Fem1g ; Fem6g ; Tal1g ; Fem1d ; Fem6d ; Tal1d];








%% Bassin Description
% Selon l'ISB pour le repère HJC solidaire du bassin

% Z latéral vers la droite du sujet
% u vecteur entre les milieux de FWT et BWT, vers FWT.
% Y pdt vectoriel Zu
% X pdt vectoriel YZ
% On ne voudrait pas définir les axes sur une frame avec occultation,
% donc vérification, puis sélection de la première frame

% repère du monde avec Z-up ; utile pour l'affichage des résultats
%Z_monde=[0 0 1];
%X_monde=X_monde_local;
%Y_monde=cross(Z_monde,X_monde);
%R_monde=[X_monde' Y_monde' Z_monde'];

% repère du bassin en posture donnée
Z_ref = markers.RFWT(A(1),:) - markers.LFWT(A(1),:);
u = (markers.LFWT(A(1),:) + markers.RFWT(A(1),:))/2 - (markers.LBWT(A(1),:) + markers.RBWT(A(1),:))/2;
Y_ref = cross(Z_ref,u);
X_ref = cross(Y_ref,Z_ref);

X_ref = X_ref ./ norm(X_ref);
Y_ref = Y_ref ./ norm(Y_ref);
Z_ref = Z_ref ./ norm(Z_ref);

% Matrice de passage Pelvis naturel vers monde d'origine
R_Pelvis_ref = [X_ref' Y_ref' Z_ref'];

Reperes.Pelvis = eye(4);
Reperes.Pelvis(1:3,1:3) = R_Pelvis_ref;
Reperes.Pelvis(1:3,4) =  centre';
% rotation naturelle du bassin par rapport au repère du monde
%repère du monde virtuel construit à partir de Xref et Zref (sans les
% composantes verticales) et on force le Y vers le haut 0;0;1

R_Pelvis_monde_local=R_monde_local'*R_Pelvis_ref;

Reperes.PelvisLocal = eye(4);
Reperes.PelvisLocal(1:3,1:3) = R_Pelvis_monde_local;
% Reperes.PelvisLocal(1:3,4) =  centre';

%% Bassin Mouvement : Référence = Description

% Bassin référence


for i =1:size(markers.RFWT, 1)
    Z_Pel(i,:) = markers.RFWT(i,:)-markers.LFWT(i,:);
    u = (markers.LFWT(i,:) + markers.RFWT(i,:))/2 - (markers.LBWT(i,:) + markers.RBWT(i,:))/2;
    Y_Pel(i,:) = cross(Z_Pel(i,:),u);
    X_Pel(i,:) = cross(Y_Pel(i,:),Z_Pel(i,:));
    
    X_Pel(i,:) = X_Pel(i,:) ./ norm(X_Pel(i,:));
    Y_Pel(i,:) = Y_Pel(i,:) ./ norm(Y_Pel(i,:));
    Z_Pel(i,:) = Z_Pel(i,:) ./ norm(Z_Pel(i,:));
    
    % Repère en mouvement
    R_Pelvis_mvt(:,:,i)=[X_Pel(i,:)' Y_Pel(i,:)' Z_Pel(i,:)'];
    
    % Repère du Pelvis au cours du temps dans le repère de référence =>
    % mouvement relatif
    R_Pelvis(:,:,i)=R_Pelvis_ref(:,:,1)'*R_Pelvis_mvt(:,:,i);
    
    % Calcul de l'angle, méthode Olfa ou Matlab
    if Olfa
        Angle_Pelvis(:,i)=axemobile_V2(R_Pelvis(:,:,i),OrdrePelv);
    else
        Angle_Pelvis(:,i)=rotm2eul(R_Pelvis(:,:,i),OrdrePelv);
    end
end

% Affichage des axes du repère au cours du temps pour contrôle
if printflag
    figure;
    hold on;
    a=[];
    for i=1:Bornes(2)
        a=[a;R_Pelvis(1,1,i) , R_Pelvis(2,1,i), R_Pelvis(3,1,i)];
    end
    plot(a(:,1),'r')
    plot(a(:,2),'g')
    plot(a(:,3),'b')
end
Angle.Angle_Pelvis=Angle_Pelvis;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% FEMUR GAUCHE
%% Création repère Fémur Gauche
% Selon l'ISB pour le repère Fémur en référence

% Y du CA Genou vers CA Hip
% u vecteur entre KNE et KNI, pointant vers la droite générale du sujet
% X pdt vectoriel Yu
% Z pdt vectoriel XY

% En description :
% Y Vers le haut (Z monde)
% X identique au bassin
% Z pdt vectoriel XY

if reference
    %  -> Posture de référence
    for i = 1:FrameRef(2)-FrameRef(1)
        Y_ref(i,:) = Articular_Centre.LHip(i + FrameRef(1)-1,:) - Articular_Centre.LKnee(i + FrameRef(1)-1,:);
        u = markers.LKNI(i + FrameRef(1)-1,:) - markers.LKNE(i + FrameRef(1)-1,:) ;
        X_ref(i,:) = cross(Y_ref(i,:) , u);
        Z_ref(i,:) = cross(X_ref(i,:) , Y_ref(i,:));
        
        X_ref(i,:) = X_ref(i,:) ./ norm(X_ref(i,:));
        Y_ref(i,:) = Y_ref(i,:) ./ norm(Y_ref(i,:));
        Z_ref(i,:) = Z_ref(i,:) ./ norm(Z_ref(i,:));
    end
    
    % Matrice de passage
    for i = 1:FrameRef(2)-FrameRef(1)
        R_LFem_ref(:,:,i) = [X_ref(i,:)' Y_ref(i,:)' Z_ref(i,:)'];
    end
    
else
    % -> Posture de description
    Y_ref = Fem1g - Fem6g;
    Z_ref = Z_monde_local;
    X_ref = cross(Y_ref,Z_ref);
    %X_ref = R_Pelvis_ref(:,1)';
    %Z_ref = cross(X_ref , Y_ref);
    
    X_ref = X_ref ./ norm(X_ref);
    Y_ref = Y_ref ./ norm(Y_ref);
    Z_ref = Z_ref ./ norm(Z_ref);
    
    % Matrice de passage
    R_LFem_ref_monde = [X_ref' Y_ref' Z_ref'];
    R_LFem_ref_local = R_Pelvis_ref^-1 *  R_LFem_ref_monde;
end

Reperes.LFemur = eye(4);
Reperes.LFemur(1:3,1:3) = R_LFem_ref_monde;
% Reperes.LFemur(1:3,4) = Fem1g';
Reperes.LFemurLocal = eye(4);
Reperes.LFemurLocal(1:3,1:3) = R_LFem_ref_local;
% Reperes.LFemurLocal(1:3,4) = R_Pelvis_ref^-1 * Fem1g';



%% Création repère Fémur Gauche Mvt

% Matrice de passage pour le calcul d'angle
for i=1:size(markers.RFWT,1)
    Y_LFem(i,:) = Articular_Centre.LHip(i,:) - Articular_Centre.LKnee(i,:);
    u = markers.LKNI(i,:) - markers.LKNE(i,:) ;
    X_LFem(i,:) = cross(Y_LFem(i,:) , u);
    Z_LFem(i,:) = cross(X_LFem(i,:) , Y_LFem(i,:));
    
    X_LFem(i,:) = X_LFem(i,:) ./ norm(X_LFem(i,:));
    Y_LFem(i,:) = Y_LFem(i,:) ./ norm(Y_LFem(i,:));
    Z_LFem(i,:) = Z_LFem(i,:) ./ norm(Z_LFem(i,:));
    
    % calcul du repère en mouvement par rapport au monde
    R_LFem_mvt(:,:,i)=[X_LFem(i,:)' Y_LFem(i,:)' Z_LFem(i,:)'];
    
    %mouvement exprimé dans le repère du pelvis
    R_LFem_mvt_pelvis(:,:,i)= R_Pelvis_mvt(:,:,i)'*R_LFem_mvt(:,:,i); %R_Pelvis(:,:,i)'
    
    R_LHip(:,:,i)=R_LFem_ref_local'*R_LFem_mvt_pelvis(:,:,i);
    
    % calcul des angles d'Euler
    if Olfa
        Angle_LHip(:,i)=axemobile_V2(R_LHip(:,:,i),OrdreLHip);
    else
        Angle_LHip(:,i)=rotm2eul(R_LHip(:,:,i),OrdreLHip);
    end
end
Angle.Angle_LHip=Angle_LHip;



% Affichage des axes du repère au cours du temps pour contrôle
if printflag
    figure;
    hold on;
    a=[];
    for i=1:Bornes(2)
        a=[a;R_LHip(1,1,i) , R_LHip(2,1,i), R_LHip(3,1,i)];
    end
    plot(a(:,1),'r')
    plot(a(:,2),'g')
    plot(a(:,3),'b')
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TIBIA GAUCHE
%% Création repère Tibia Gauche Ref
% Selon l'ISB pour le repère Tibia en référence

% Y entre CA cheville et Genou
% u vecteur entre les milieux de ANI et ANE, vers la droite du sujet
% X pdt vectoriel Yu
% Z pdt vectoriel XY


% En description :
% Y Vers le haut (Z monde)
% X identique au bassin
% Z pdt vectoriel XY

if reference
    % Selon l'absence d'ISB, même approche que pour la hanche
    for i = 1:FrameRef(2)-FrameRef(1)
        Y_ref(i,:) = Articular_Centre.LKnee(i + FrameRef(1)-1,:) - Articular_Centre.LAnkle(i + FrameRef(1)-1,:);
        u = markers.LANI(i + FrameRef(1)-1,:) - markers.LANE(i + FrameRef(1)-1,:);
        X_ref(i,:) = cross(Y_ref(i,:) , u);
        Z_ref(i,:) = cross(X_ref(i,:) , Y_ref(i,:));
        
        X_ref(i,:) = X_ref(i,:) ./ norm(X_ref(i,:));
        Y_ref(i,:) = Y_ref(i,:) ./ norm(Y_ref(i,:));
        Z_ref(i,:) = Z_ref(i,:) ./ norm(Z_ref(i,:));
        R_LTib_ref(:,:,i) = [X_ref(i,:)' Y_ref(i,:)' Z_ref(i,:)'];
    end
    % Matrice de passage
    for i = 1:FrameRef(2)-FrameRef(1)
        R_LTib_ref(:,:,i) = [X_ref(i,:)' Y_ref(i,:)' Z_ref(i,:)'];
    end
    
else
    
    % % Création repère Tibia Gauche Description
    
    Y_ref = Fem6g - Tal1g;
    Z_ref = Z_monde_local;%R_Pelvis_ref(:,1)';
    X_ref = cross(Y_ref , Z_ref);
    
    X_ref = X_ref ./ norm(X_ref);
    Y_ref = Y_ref ./ norm(Y_ref);
    Z_ref = Z_ref ./ norm(Z_ref);
    
    % Matrice de passage
    R_LTib_ref_monde = [X_ref' Y_ref' Z_ref'];
    
    %Franck exprimer le tibia ref dans le repère du femur ref
    R_LTib_ref_local = R_LFem_ref_monde^-1 *  R_LTib_ref_monde;
    
end

Reperes.LTibia = eye(4);
Reperes.LTibia(1:3,1:3) = R_LTib_ref_monde;
Reperes.LTibia(1:3,4) = Fem6g';

Reperes.LTibiaLocal = eye(4);
Reperes.LTibiaLocal(1:3,1:3) = R_LTib_ref_local;
Reperes.LTibiaLocal(1:3,4) = R_LFem_ref_monde^-1 * (Fem6g - Fem1g)';

Reperes.LAnkleLocal = Reperes.LTibia;
Reperes.LAnkleLocal = R_LTib_ref_monde^-1 * (Tal1g - Fem6g)';

%% Création repère Tibia Gauche Mvt

for i = 1 : size(markers.RFWT,1)
    Y_LTib(i,:) = Articular_Centre.LKnee(i,:) - Articular_Centre.LAnkle(i,:);
    u = markers.LANI(i,:) - markers.LANE(i,:);
    X_LTib(i,:) = cross(Y_LTib(i,:) , u);
    Z_LTib(i,:) = cross(X_LTib(i,:) , Y_LTib(i,:));
    
    
    X_LTib(i,:) = X_LTib(i,:) ./ norm(X_LTib(i,:));
    Y_LTib(i,:) = Y_LTib(i,:) ./ norm(Y_LTib(i,:));
    Z_LTib(i,:) = Z_LTib(i,:) ./ norm(Z_LTib(i,:));
    
    R_LTib_mvt(:,:,i)=[X_LTib(i,:)' Y_LTib(i,:)' Z_LTib(i,:)'];
    
    %mouvement exprimé dans le repère du Femur
    R_LTib_mvt_Femur(:,:,i)= R_LFem_mvt(:,:,i)'*R_LTib_mvt(:,:,i);
    
    R_LKnee(:,:,i)=R_LTib_ref_local'*R_LTib_mvt_Femur(:,:,i);
    
    % calcul des angles d'Euler
    if Olfa
        Angle_LKnee(:,i)=axemobile_V2(R_LKnee(:,:,i),OrdreLKnee);
    else
        Angle_LKnee(:,i)=rotm2eul(R_LKnee(:,:,i),OrdreLKnee);
    end
    
end
Angle.Angle_LKnee=Angle_LKnee;

% Affichage des axes du repère au cours du temps pour contrôle
if printflag
    
    figure;
    hold on;
    a=[];
    for i=1:Bornes(2)
        a=[a;R_LKnee(1,1,i) , R_LKnee(2,1,i), R_LKnee(3,1,i)];
    end
    plot(a(:,1),'r')
    plot(a(:,2),'g')
    plot(a(:,3),'b')
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% FEMUR DROIT
%% Création repère Fémur Droit Ref
% Selon l'ISB pour le repère Fémur en référence

% Y du CA Genou vers CA Hip
% u vecteur entre KNE et KNI, pointant globalement vers la droite générale du sujet
% X pdt vectoriel Yu
% Z pdt vectoriel XY

% En description :
% Y Vers le haut (Z monde)
% X identique au bassin
% Z pdt vectoriel XY

if reference
    % En pos de référence
    for i = 1:FrameRef(2)-FrameRef(1)
        Y_ref(i,:) = Articular_Centre.RHip(i + FrameRef(1)-1,:) - Articular_Centre.RKnee(i + FrameRef(1)-1,:);
        u = markers.RKNE(i + FrameRef(1)-1,:) - markers.RKNI(i + FrameRef(1)-1,:) ;
        X_ref(i,:) = cross(Y_ref(i,:) , u);
        Z_ref(i,:) = cross(X_ref(i,:) , Y_ref(i,:));
        
        X_ref(i,:) = X_ref(i,:) ./ norm(X_ref(i,:));
        Y_ref(i,:) = Y_ref(i,:) ./ norm(Y_ref(i,:));
        Z_ref(i,:) = Z_ref(i,:) ./ norm(Z_ref(i,:));
    end
    
    for i = 1:FrameRef(2)-FrameRef(1)
        R_RFem_ref(:,:,i) = [X_ref(i,:)' Y_ref(i,:)' Z_ref(i,:)'];
    end
    
else
    
    % % Création repère Femur droit Description
    Y_ref = Fem1d - Fem6d;
    Z_ref = Z_monde_local;
    X_ref = cross(Y_ref,Z_ref);
    
    %     Y_ref = Fem1d - Fem6d;
    %     X_ref = R_Pelvis_ref(:,1)';
    %     Z_ref = cross(X_ref , Y_ref);
    
    X_ref = X_ref ./ norm(X_ref);
    Y_ref = Y_ref ./ norm(Y_ref);
    Z_ref = Z_ref ./ norm(Z_ref);
    
    %R_RFem_ref = [X_ref' Y_ref' Z_ref'];
    R_RFem_ref_monde = [X_ref' Y_ref' Z_ref'];
    R_RFem_ref_local = R_Pelvis_ref^-1 *  R_RFem_ref_monde;
    
end


Reperes.RFemur = eye(4);
Reperes.RFemur(1:3,1:3) = R_RFem_ref_monde;
% Reperes.RFemur(1:3,4) = Fem1d';

Reperes.RFemurLocal = eye(4);
Reperes.RFemurLocal(1:3,1:3) = R_RFem_ref_local;
% Reperes.RFemurLocal(1:3,4) = R_Pelvis_ref^-1 * Fem1d';

%% Création repère Fémur Droit Mvt

for i = 1 : size(markers.RFWT,1)
    %%Franck : idem correction gauche
    Y_RFem(i,:) = Articular_Centre.RHip(i,:) - Articular_Centre.RKnee(i,:);
    u = markers.RKNE(i,:) - markers.RKNI(i,:) ;
    X_RFem(i,:) = cross(Y_RFem(i,:) , u);
    Z_RFem(i,:) = cross(X_RFem(i,:) , Y_RFem(i,:));
    
    X_RFem(i,:) = X_RFem(i,:) ./ norm(X_RFem(i,:));
    Y_RFem(i,:) = Y_RFem(i,:) ./ norm(Y_RFem(i,:));
    Z_RFem(i,:) = Z_RFem(i,:) ./ norm(Z_RFem(i,:));
    
    % calcul du repère en mouvement
    R_RFem_mvt(:,:,i)=[X_RFem(i,:)' Y_RFem(i,:)' Z_RFem(i,:)'];
    
    %mouvement exprimé dans le repère du pelvis
    R_RFem_mvt_pelvis(:,:,i)= R_Pelvis_mvt(:,:,i)'*R_RFem_mvt(:,:,i);
    
    R_RHip(:,:,i)=R_RFem_ref_local'*R_RFem_mvt_pelvis(:,:,i);
    
    % calcul des angles d'Euler
    if Olfa
        Angle_RHip(:,i)=axemobile_V2(R_RHip(:,:,i),OrdreLHip);
    else
        Angle_RHip(:,i)=rotm2eul(R_RHip(:,:,i),OrdreLHip);
    end
end
Angle.Angle_RHip=Angle_RHip;

% Contrôle
if printflag
    
    figure;
    hold on;
    a=[];
    for i=1:Bornes(2)
        a=[a;R_RHip(1,1,i) , R_RHip(2,1,i), R_RHip(3,1,i)];
    end
    plot(a(:,1),'r')
    plot(a(:,2),'g')
    plot(a(:,3),'b')
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TIBIA DROIT
%% Création repère Tibia Droit Ref
% Selon l'ISB pour le repère Tibia en référence

% Y entre CA cheville et Genou
% u vecteur entre les milieux de ANI et ANE, vers la droite du sujet
% X pdt vectoriel Yu
% Z pdt vectoriel XY


% En description :
% Y Vers le haut (Z monde)
% X identique au bassin
% Z pdt vectoriel XY

if reference
    for i = 1:FrameRef(2)-FrameRef(1)
        Y_ref(i,:) = Articular_Centre.RKnee(i + FrameRef(1)-1,:) - Articular_Centre.RAnkle(i + FrameRef(1)-1,:);
        u = markers.RANE(i + FrameRef(1)-1,:) - markers.RANI(i + FrameRef(1)-1,:);
        X_ref(i,:) = cross(Y_ref(i,:) , u);
        Z_ref(i,:) = cross(X_ref(i,:) , Y_ref(i,:));
        
        X_ref(i,:) = X_ref(i,:) ./ norm(X_ref(i,:));
        Y_ref(i,:) = Y_ref(i,:) ./ norm(Y_ref(i,:));
        Z_ref(i,:) = Z_ref(i,:) ./ norm(Z_ref(i,:));
    end
    
    % Matrice de passage
    for i = 1:FrameRef(2)-FrameRef(1)
        R_RTib_ref(:,:,i) = [X_ref(i,:)' Y_ref(i,:)' Z_ref(i,:)'];
    end
    
else
    Y_ref = Fem6d - Tal1d;
    Z_ref = Z_monde_local;
    X_ref = cross(Y_ref , Z_ref);
    
    
    X_ref = X_ref ./ norm(X_ref);
    Y_ref = Y_ref ./ norm(Y_ref);
    Z_ref = Z_ref ./ norm(Z_ref);
    
    % Matrice de passage
    R_RTib_ref_monde = [X_ref' Y_ref' Z_ref'];
    
    %Franck exprimer le tibia ref dans le repère du femur ref
    R_RTib_ref_local = R_RFem_ref_monde^-1 *  R_RTib_ref_monde;
    
end


Reperes.RTibia = eye(4);
Reperes.RTibia(1:3,1:3) = R_RTib_ref_monde;
% Reperes.RTibia(1:3,4) = Fem6d';

Reperes.RTibiaLocal = eye(4);
Reperes.RTibiaLocal(1:3,1:3) = R_RTib_ref_local;
% Reperes.RTibiaLocal(1:3,4) = R_RFem_ref_monde^-1 * (Fem6d - Fem1d)';

%% Création repère Tibia Droit Mvt

for i = 1 : size(markers.RFWT,1)
    Y_RTib(i,:) = Articular_Centre.RKnee(i,:) - Articular_Centre.RAnkle(i,:);
    u = markers.RANE(i,:) - markers.RANI(i,:);
    X_RTib(i,:) = cross(Y_RTib(i,:) , u);
    Z_RTib(i,:) = cross(X_RTib(i,:) , Y_RTib(i,:));
    
    X_RTib(i,:) = X_RTib(i,:) ./ norm(X_RTib(i,:));
    Y_RTib(i,:) = Y_RTib(i,:) ./ norm(Y_RTib(i,:));
    Z_RTib(i,:) = Z_RTib(i,:) ./ norm(Z_RTib(i,:));
    
    R_RTib_mvt(:,:,i)=[X_RTib(i,:)' Y_RTib(i,:)' Z_RTib(i,:)'];
    
    %mouvement exprimé dans le repère du Femur
    R_RTib_mvt_Femur(:,:,i)= R_RFem_mvt(:,:,i)'*R_RTib_mvt(:,:,i);
    
    R_RKnee(:,:,i)=R_RTib_ref_local'*R_RTib_mvt_Femur(:,:,i);
    
    % calcul des angles d'Euler
    if Olfa
        Angle_RKnee(:,i)=axemobile_V2(R_RKnee(:,:,i),OrdreRKnee);
    else
        Angle_RKnee(:,i)=rotm2eul(R_RKnee(:,:,i),OrdreRKnee);
    end
    
end
Angle.Angle_RKnee=Angle_RKnee;
%% Contrôle -> Affichage des Angles et des Repères au cours du temps pour Vérification
if printflag
    
    % Hanche Droite
    a=[];
    b=[];
    c=[];
    for i=Bornes(1):Bornes(2)
        a=[a;R_RHip(1,1,i) , R_RHip(2,1,i), R_RHip(3,1,i)];
        b=[b;R_RHip(1,2,i) , R_RHip(2,2,i), R_RHip(3,2,i)];
        c=[c;R_RHip(1,3,i) , R_RHip(2,3,i), R_RHip(3,3,i)];
    end
    figure;
    hold on;
    subplot(1,3,1);
    title('RHip X');
    hold on;
    plot(a(:,1),'r')
    plot(a(:,2),'g')
    plot(a(:,3),'b')
    subplot(1,3,2);
    title('RHip Y');
    hold on;
    plot(b(:,1),'r')
    plot(b(:,2),'g')
    plot(b(:,3),'b')
    subplot(1,3,3);
    title('RHip Z');
    hold on;
    plot(c(:,1),'r')
    plot(c(:,2),'g')
    plot(c(:,3),'b')
    legend('X - Sens de la marche', 'Y - Up' ,'Z - Lateral -> FWT');
    
    figure;
    hold on;
    plot(1:size(Angle.Angle_RHip(:,Bornes(1):Bornes(2)),2),Angle.Angle_RHip(:,Bornes(1):Bornes(2)));
    title('Hanche Droite')
    legend('X - Sens de la marche', 'Y - Knee/Hip' ,'Z - Lateral -> FWT');
    
    
    % Confirme grosso modo que X RHip = YRFem.ZPelv // Y RH = ZRFem.XPelv // et Z RH = XRFem.YPelv
    
    % Hanche Gauche
    a=[];
    b=[];
    c=[];
    for i=Bornes(1):Bornes(2)
        a=[a;R_LHip(1,1,i) , R_LHip(2,1,i), R_LHip(3,1,i)];
        b=[b;R_LHip(1,2,i) , R_LHip(2,2,i), R_LHip(3,2,i)];
        c=[c;R_LHip(1,3,i) , R_LHip(2,3,i), R_LHip(3,3,i)];
    end
    figure;
    hold on;
    subplot(1,3,1);
    title('LHip X');
    hold on;
    plot(a(:,1),'r')
    plot(a(:,2),'g')
    plot(a(:,3),'b')
    subplot(1,3,2);
    title('LHip Y');
    hold on;
    plot(b(:,1),'r')
    plot(b(:,2),'g')
    plot(b(:,3),'b')
    subplot(1,3,3);
    title('LHip Z');
    hold on;
    plot(c(:,1),'r')
    plot(c(:,2),'g')
    plot(c(:,3),'b')
    legend('X - Sens de la marche', 'Y - Up' ,'Z - Lateral -> FWT');
    
    
    figure;
    hold on;
    plot(1:size(a,1),a(:,2)+b(:,1));
    
    
    figure;
    hold on;
    plot(1:size(Angle.Angle_LHip(:,Bornes(1):Bornes(2)),2),Angle.Angle_LHip(:,Bornes(1):Bornes(2)));
    title('Hanche Gauche')
    legend('X - Sens de la marche', 'Y - Knee/Hip' ,'Z - Lateral -> FWT');
    
    
    % Confirme grosso modo que X LHip = YRFem.ZPelv // Y RH = ZRFem.XPelv // et Z RH = XRFem.YPelv
    
    % Genou Droit
    a=[];
    b=[];
    c=[];
    
    for i=Bornes(1):Bornes(2)
        a=[a;R_RKnee(1,1,i) , R_RKnee(2,1,i), R_RKnee(3,1,i)];
        b=[b;R_RKnee(1,2,i) , R_RKnee(2,2,i), R_RKnee(3,2,i)];
        c=[c;R_RKnee(1,3,i) , R_RKnee(2,3,i), R_RKnee(3,3,i)];
    end
    figure;
    hold on;
    subplot(1,3,1);
    title('RKnee X');
    hold on;
    plot(a(:,1),'r')
    plot(a(:,2),'g')
    plot(a(:,3),'b')
    subplot(1,3,2);
    title('RKnee Y');
    hold on;
    plot(b(:,1),'r')
    plot(b(:,2),'g')
    plot(b(:,3),'b')
    subplot(1,3,3);
    title('RKnee Z');
    hold on;
    plot(c(:,1),'r')
    plot(c(:,2),'g')
    plot(c(:,3),'b')
    legend('X - Sens de la marche', 'Y - Up' ,'Z - Lateral -> FWT');
    
    figure;
    hold on;
    plot(1:size(Angle.Angle_RKnee(:,Bornes(1):Bornes(2)),2),Angle.Angle_RKnee(:,Bornes(1):Bornes(2)));
    title('Genou Droit')
    legend('X - Sens de la marche', 'Y - Ankle/Knee' ,'Z - Lateral -> KNE/I');
    
    % Genou Gauche
    a=[];
    b=[];
    c=[];
    for i=Bornes(1):Bornes(2)
        a=[a;R_LKnee(1,1,i) , R_LKnee(2,1,i), R_LKnee(3,1,i)];
        b=[b;R_LKnee(1,2,i) , R_LKnee(2,2,i), R_LKnee(3,2,i)];
        c=[c;R_LKnee(1,3,i) , R_LKnee(2,3,i), R_LKnee(3,3,i)];
    end
    figure;
    hold on;
    subplot(1,3,1);
    title('LKnee X');
    hold on;
    plot(a(:,1),'r')
    plot(a(:,2),'g')
    plot(a(:,3),'b')
    subplot(1,3,2);
    title('LKnee Y');
    hold on;
    plot(b(:,1),'r')
    plot(b(:,2),'g')
    plot(b(:,3),'b')
    subplot(1,3,3);
    title('LKnee Z');
    hold on;
    plot(c(:,1),'r')
    plot(c(:,2),'g')
    plot(c(:,3),'b')
    legend('X - Sens de la marche', 'Y - Up' ,'Z - Lateral -> FWT');
    
    figure;
    hold on;
    plot(1:size(Angle.Angle_LKnee(:,Bornes(1):Bornes(2)),2),Angle.Angle_LKnee(:,Bornes(1):Bornes(2)));
    title('Genou Gauche')
    legend('X - Sens de la marche', 'Y - Ankle/Knee' ,'Z - Lateral -> KNE/I');
end
%% Tests : Debuggage

ConditionO = all(Reperes.Monde(1:3,1:3) * markers.LKNE' == originalmarkers.LKNE');
ConditionRF = all(all(Reperes.RFemur == Reperes.Pelvis * Reperes.RFemurLocal));
ConditionRT = all(all(round(Reperes.RTibia,3) == round(Reperes.RFemur * Reperes.RTibiaLocal,3)));
ConditionLF = all(all(Reperes.LFemur == Reperes.Pelvis * Reperes.LFemurLocal));
ConditionLT = all(all(round(Reperes.LTibia,3) == round(Reperes.LFemur * Reperes.LTibiaLocal,3)));

Condition = ConditionO || ConditionRF || ConditionRT || ConditionLF || ConditionLT;

if ~Condition
   error('Computation error, frames do not add up, please correct this shit (might also be a slight rounding error above 10^-3 tho)') 
end

end

