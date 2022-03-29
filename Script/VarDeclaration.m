%%% Ici c'est la partie dégueu ou je fais le lien entre les batch et mon ancien algo.
%%% Donc je déclare les variables dont j'vais avoir besoin, et j'associe les valeurs qui vont... 
%%% La plupart sont juste des déclarations, des fois des flags... 

%%% La raison pour laquelle j'ai pas benné tout ça était pour assurer l'absence de régression, mais c'est plus 
%%% d'actualité en fait...

% Variables pour conserver la courbe cible originale et les TA originales
Spline = GT;
TrajAng = NewCurve;

PolA = Pol;
Poul = GT;
P = PN;

% Masse du sujet
M = 70;

% Calcul de l'erreur initiale commise sur la cible
Ref = [];
% a = ErrorFun3(PolA,X,Sequence,Markers,Reperes);
% for i =1:size(X,1)
%     Ref = [Ref; X(i,3:end)-a(i,:)];
% end

% % Coûts initiaux ie de référence en Jerk et EC. 
% if flag.txt
%     CostRef = ECShort(Poul,TrajAng,M,Markers,Inertie);
% else
%     CostRef = ECShort(Poul,TrajAng,M,Markers,Inertie);
% end

JerkRef = Jerk(PolA);

% Variable pour mémoriser la somme des normes des erreurs commises sur X
N=[];
N = [N, norm(Ref)];

% Variable pour mémoriser l'energie cinétique
mV=[];
% mV= [mV, CostRef];

% Variable pour mémoriser le Jerk
mJ=[];
mJ=[mJ;JerkRef];

% Variable pour mémoriser la pondération des tâches secondaires (On peut les faire varier dans l'algo
% option off de base) 
mSter=[];
mSter=[0,0];

% Initialisation d'un tableau qui référence les erreurs commises en refusant de rapprocher 2 trop près PCA 
InvE=zeros(size(PCA,1),500);

% Flag de détection d'inversion de PCA
Cflag= [];

% Variable utile pour la conservation de l'erreur commise lors de l'approx en spline. 
Emem = [];

% Compteur du nombre de cycles effectués
c=0; 

% PCA modifiés dans la boucle
NPCA =PCA; 

% Variable de mémorisation des vecteurs de modification des PCAs
pModifs =[];

% Initialisation des vecteurs de modification des PCAs 
Modifs = zeros(2*size(PCA,1),1);

% Variable qui mémorise les données de convergence : erreur commise, Jerk et Energie cinétique à chaque cycle 
Conv=[];

% Variable pour stocker les cycles et PC qui se rapprochent trop et ont été écartés pour éviter un crash 
Iflag=[];

% Seuil de précision - arbitraire
Threshold = 0.10;

% Seuil de Jerk - arbitraire
ThreshJerk = 30;

% Seuil de rapprochement de points de contrôle, trouvé empiriquement 
ThreshX = 0.01;

% Seuil d'énergie cinétique - arbitrairement mis à 1/2 de la valeur ini
% threshCE = CostRef/2;
threshCE = 10e5/2;

% Variable qui stocke les PCA à chaque cycle
Storing =[];

% Variable qui détermine les dt et dtheta respectivement dans les gradients et Jacobiennes
dp = [0.00001, 0.00001];

% Pondération des tâches secondaires : JSter Jerk, VSter CE. Effet notable à partir de 10^5 - 10^6 
VSter=-0.005;
JSter=-0.000;

% Nombre de PCA réellement pris en compte, le reste est symétrisé
s=7;

% Reperes = struct;
Reperes.R_monde_local = eye(3);
Reperes.R_Pelvis_monde_local = Reperes.Pelvis(1:3,1:3);
Reperes.R_LFem_ref_local = Reperes.LFemur1(1:3,1:3);
Reperes.R_LTib_ref_local = Reperes.LTibia(1:3,1:3);
Reperes.R_RFem_ref_local = Reperes.RFemur1(1:3,1:3);
Reperes.R_RTib_ref_local = Reperes.RTibia(1:3,1:3);
