function [C3DKinModel] = Loadc3dKinModel(BDDPath,FileName,XLSXName)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

[BornesMarche, Names] = xlsread(strcat(BDDPath,XLSXName),'A2:D78');

ii = find(strcmp(Names,FileName));
p = BDDPath;
Bornes=[BornesMarche(ii,1)-BornesMarche(ii,3) BornesMarche(ii,2)-BornesMarche(ii,3)];

% Taille de l'échantillon de frames à sélectionner
Period = Bornes(2)-Bornes(1)+1;

% Structure contenant les positions de marqueurs
markers=struct;

% Acquisition des marqueurs à partir des .c3d en 2étapes
% 1 - Acquisition
TN{ii}=strcat(Names{ii},'.c3d');
NewFile = strcat(p,TN{ii});
a = btkReadAcquisition(NewFile);
premarkers = btkGetMarkers(a);
Tmp = struct2cell(premarkers);
b = fieldnames(premarkers);
for j = 3:size(b,1)
    tempName = b{j};
    if size(tempName,2) > 4
        tempName = tempName(end-3:end);
    end
    
    switch tempName
        case 'RFWT'
            markers.RFWT = Tmp{j};
        case 'LFWT'
            markers.LFWT = Tmp{j};
        case 'RBWT'
            markers.RBWT = Tmp{j};
        case 'LBWT'
            markers.LBWT = Tmp{j};
        case 'LKNE'
            markers.LKNE = Tmp{j};
        case 'RKNE'
            markers.RKNE = Tmp{j};
        case 'LKNI'
            markers.LKNI = Tmp{j};
        case 'RKNI'
            markers.RKNI = Tmp{j};
        case 'LANE'
            markers.LANE = Tmp{j};
        case 'RANE'
            markers.RANE = Tmp{j};
        case 'LANI'
            markers.LANI = Tmp{j};
        case 'RANI'
            markers.RANI = Tmp{j};
    end
    
    
    
end
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
flag.txt = 0;

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

if rem(str2double(FileName(:,end-1:end)),2)%Condition Nom Pair/Impair
    B = RotationZ(-pi/2);
    R_monde = R_monde * B(1:3,1:3);
else
    B = RotationZ(+pi/2);
    R_monde = R_monde * B(1:3,1:3);
end

centre=(markers.LBWT + markers.RBWT)/2; % centre du repère

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
Articular_Centre.Pelvis =  (markers.LBWT + markers.RBWT)/2;

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
    Param = [Fem1g' , Fem6g' , Tal1g' , Fem1d' , Fem6d' , Tal1d'];
else
    Fem1g = Param(:,1)';
    Fem6g = Param(:,2)';
    Tal1g = Param(:,3)';
    Fem1d = Param(:,4)';
    Fem6d = Param(:,5)';
    Tal1d = Param(:,6)';
end

%% Lancement des scripts de calcul suivants

%%% Creation Reperes Articulaires

CreationRepere;

fcine_numerique_H2(zeros(1,11),Param(:,1)',Param(:,2)',Param(:,3)',Param(:,4)',Param(:,5)',Param(:,6)',...
    R_monde_local,R_Pelvis_monde_local, R_LFem_ref_local, R_LTib_ref_local, R_RFem_ref_local, R_RTib_ref_local);

Reperes.R_monde_local = R_monde_local;
Reperes.R_Pelvis_monde_local = R_Pelvis_monde_local;
Reperes.R_LFem_ref_local = R_LFem_ref_local;
Reperes.R_LTib_ref_local = R_LTib_ref_local;
Reperes.R_RFem_ref_local = R_RFem_ref_local;
Reperes.R_RTib_ref_local = R_RTib_ref_local;

Cmarkers = struct2cell(markers);
f = fieldnames(markers);
tmpX = {};
for i=1:size(Cmarkers,1) 
    tmpX{i} = Cmarkers{i}(Bornes(1):Bornes(2),:);
end
tmpX = tmpX';
Markers = cell2struct(tmpX,f);

CAngle = struct2cell(Angle);
f = fieldnames(Angle);
tmpA = {};
for i=1:size(CAngle,1) 
    tmpA{i} = CAngle{i}(:,Bornes(1):Bornes(2));
end
tmpA = tmpA';
Angles = cell2struct(tmpA,f);

C3DKinModel.AC = Articular_Centre;
C3DKinModel.Markers = Markers;
C3DKinModel.Reperes = Reperes;
C3DKinModel.ParamPhy = Param;
C3DKinModel.Angles = Angles;

TA =[];
TX = [];

for i = 1 : max(size(tmpX))
    if i <= max(size(tmpA))
        TA = [TA , tmpA{i}'];
    end
    TX = [TX , tmpX{i}];
end
TA = [TA(:,1:6), TA(:,9:12), TA(:,15)];

rate = size(TA,1);
freq=5;
[b,a] = butter(2 , freq/(0.5*rate) , 'low');
TX=filtfilt(b,a,TX);
TA = filtfilt(b,a,TA);

C3DKinModel.TA = TA;
C3DKinModel.TX = TX;

Poul  = [Articular_Centre.RAnkle(Bornes(1):Bornes(2),:) , Articular_Centre.LAnkle(Bornes(1):Bornes(2),:)];
C3DKinModel.Poulaine = Poul;

C3DKinModel.Param = Param;

end