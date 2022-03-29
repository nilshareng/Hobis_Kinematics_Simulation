%Création des différents repères articulaires et calcul des angles



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

% printflag =1 pour activer les affichages de figures
printflag = 0;


%% Bassin Référence / Description
% Selon l'ISB pour le repère HJC solidaire du bassin

% Z latéral vers la droite du sujet
% u vecteur entre les milieux de FWT et BWT, vers FWT.
% Y pdt vectoriel Zu
% X pdt vectoriel YZ
% On ne voudrait pas définir les axes sur une frame avec occultation,
% donc vérification, puis sélection de la première frame
Cond = ones(N_frame,1) - ( (markers.LBWT(:,1)==0)&(markers.LBWT(:,2)==0)&(markers.LBWT(:,3)==0)  |   (markers.RBWT(:,1)==0)&(markers.RBWT(:,2)==0)&(markers.RBWT(:,3)==0) |  (markers.RFWT(:,1)==0)&(markers.RFWT(:,2)==0)&(markers.RFWT(:,3)==0) | (markers.LFWT(:,1)==0)&(markers.LFWT(:,2)==0)&(markers.LFWT(:,3)==0)   );
A = find(Cond);
if isempty(A)
   error('No complete frames for the kinematic chain creation'); 
end

%construction du repère du monde ramené au bassin : Y parfaitement
%verical, et X et Z parfaitement horizontaux
% remarque : Fem1g, Fem6g... sont exprimés dans ce repère parfaitement
% vertical

Y_monde_local=[0 0 1];
Z_monde_local=[(markers.RFWT(A(1),1:2) - markers.LFWT(A(1),1:2)) 0];
Z_monde_local=Z_monde_local/norm(Z_monde_local);
X_monde_local=cross(Y_monde_local,Z_monde_local);
X_monde_local=X_monde_local/norm(X_monde_local);
R_monde_local=[X_monde_local' Y_monde_local' Z_monde_local'];

% repère du monde avec Z-up ; utile pour l'affichage des résultats
%Z_monde=[0 0 1];
%X_monde=X_monde_local;
%Y_monde=cross(Z_monde,X_monde);
%R_monde=[X_monde' Y_monde' Z_monde'];

% repère du bassin en position naturelle
Z_ref = markers.RFWT(A(1),:) - markers.LFWT(A(1),:);
u = (markers.LFWT(A(1),:) + markers.RFWT(A(1),:))/2 - (markers.LBWT(A(1),:) + markers.RBWT(A(1),:))/2;
Y_ref = cross(Z_ref,u);
X_ref = cross(Y_ref,Z_ref);

X_ref = X_ref ./ norm(X_ref);
Y_ref = Y_ref ./ norm(Y_ref);
Z_ref = Z_ref ./ norm(Z_ref);

% Matrice de passage Pelvis naturel vers monde d'origine
R_Pelvis_ref = [X_ref' Y_ref' Z_ref'];

% rotation naturelle du bassin par rapport au repère du monde
%repère du monde virtuel construit à partir de Xref et Zref (sans les
% composantes verticales) et on force le Y vers le haut 0;0;1

R_Pelvis_monde_local=R_monde_local'*R_Pelvis_ref;



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
    R_LFem_ref_local = R_Pelvis_ref' *  R_LFem_ref_monde;
end


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
    R_LTib_ref_local = R_LFem_ref_monde' *  R_LTib_ref_monde;
    
end


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
    R_RFem_ref_local = R_Pelvis_ref' *  R_RFem_ref_monde;
    
end



% Création repère Fémur Droit Mvt

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
    R_RTib_ref_local = R_RFem_ref_monde' *  R_RTib_ref_monde;
    
end
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
