%%% Ici c'est la partie d�gueu ou je fais le lien entre les batch et mon ancien algo.
%%% Donc je d�clare les variables dont j'vais avoir besoin, et j'associe les valeurs qui vont... 
%%% La plupart sont juste des d�clarations, des fois des flags... 

%%% La raison pour laquelle j'ai pas benn� tout �a �tait pour assurer l'absence de r�gression, mais c'est plus 
%%% d'actualit� en fait...

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

% % Co�ts initiaux ie de r�f�rence en Jerk et EC. 
% if flag.txt
%     CostRef = ECShort(Poul,TrajAng,M,Markers,Inertie);
% else
%     CostRef = ECShort(Poul,TrajAng,M,Markers,Inertie);
% end

JerkRef = Jerk(PolA);

% Variable pour m�moriser la somme des normes des erreurs commises sur X
N=[];
N = [N, norm(Ref)];

% Variable pour m�moriser l'energie cin�tique
mV=[];
% mV= [mV, CostRef];

% Variable pour m�moriser le Jerk
mJ=[];
mJ=[mJ;JerkRef];

% Variable pour m�moriser la pond�ration des t�ches secondaires (On peut les faire varier dans l'algo
% option off de base) 
mSter=[];
mSter=[0,0];

% Initialisation d'un tableau qui r�f�rence les erreurs commises en refusant de rapprocher 2 trop pr�s PCA 
InvE=zeros(size(PCA,1),500);

% Flag de d�tection d'inversion de PCA
Cflag= [];

% Variable utile pour la conservation de l'erreur commise lors de l'approx en spline. 
Emem = [];

% Compteur du nombre de cycles effectu�s
c=0; 

% PCA modifi�s dans la boucle
NPCA =PCA; 

% Variable de m�morisation des vecteurs de modification des PCAs
pModifs =[];

% Initialisation des vecteurs de modification des PCAs 
Modifs = zeros(2*size(PCA,1),1);

% Variable qui m�morise les donn�es de convergence : erreur commise, Jerk et Energie cin�tique � chaque cycle 
Conv=[];

% Variable pour stocker les cycles et PC qui se rapprochent trop et ont �t� �cart�s pour �viter un crash 
Iflag=[];

% Seuil de pr�cision - arbitraire
Threshold = 0.10;

% Seuil de Jerk - arbitraire
ThreshJerk = 30;

% Seuil de rapprochement de points de contr�le, trouv� empiriquement 
ThreshX = 0.01;

% Seuil d'�nergie cin�tique - arbitrairement mis � 1/2 de la valeur ini
% threshCE = CostRef/2;
threshCE = 10e5/2;

% Variable qui stocke les PCA � chaque cycle
Storing =[];

% Variable qui d�termine les dt et dtheta respectivement dans les gradients et Jacobiennes
dp = [0.00001, 0.00001];

% Pond�ration des t�ches secondaires : JSter Jerk, VSter CE. Effet notable � partir de 10^5 - 10^6 
VSter=-0.005;
JSter=-0.000;

% Nombre de PCA r�ellement pris en compte, le reste est sym�tris�
s=7;

% Reperes = struct;
Reperes.R_monde_local = eye(3);
Reperes.R_Pelvis_monde_local = Reperes.Pelvis(1:3,1:3);
Reperes.R_LFem_ref_local = Reperes.LFemur1(1:3,1:3);
Reperes.R_LTib_ref_local = Reperes.LTibia(1:3,1:3);
Reperes.R_RFem_ref_local = Reperes.RFemur1(1:3,1:3);
Reperes.R_RTib_ref_local = Reperes.RTibia(1:3,1:3);
