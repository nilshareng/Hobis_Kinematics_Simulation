function [res,Save]=fcine_numerique_H2(P,Fem1g,Fem6g,Tal1g,Fem1d,Fem6d,Tal1d, R_monde_local, R_Pelvis_monde, R_LFem_ref_local, R_LTib_ref_local, R_RFem_ref_local, R_RTib_ref_local)
% Fonction cinématique du modèle
% Entrée : Angles P et paramètres physiologiques Fem...
% Param en ligne
% Sortie : Les positions des chevilles simulées
% Franck : intégration des rotations anatomiques initiales

% Parseur
rxb=P(1);
ryb=P(2);
rzb=P(3);
rhxg=P(4);
rhyg=P(5);
rhzg=P(6); 
rzgg=P(7);
rhxd=P(8);
rhyd=P(9);
rhzd=P(10); 
rzgd=P(11);

flag=0;
if size(P,2) == 12
    flag =1;
end

matrbasX=[1 0 0 0;  0 cos(rxb) -sin(rxb) 0; 0 sin(rxb) cos(rxb) 0 ; 0 0 0 1];
matrbasY=[cos(ryb) 0 sin(ryb) 0;  0 1 0 0; -sin(ryb) 0 cos(ryb) 0 ; 0 0 0 1];
matrbasZ=[cos(rzb) -sin(rzb) 0 0;  sin(rzb) cos(rzb) 0 0; 0 0 1 0; 0 0 0 1];
matrbas=matrbasX*matrbasY*matrbasZ;

% multiplication par R_pelvis_monde pour passer du repère du monde (rappel
% : Y_up (0;1;0) parfait, X vers l'avant, Z latéral) vers le repère du
% bassin légèrement incliné par rapport aux axes du monde
temp=eye(4,4); temp(1:3,1:3)=R_Pelvis_monde;
Mpass= temp*matrbas; 

temp(1:3,1:3)=R_monde_local; % ramener au repère du monde avec Z en haut
Mpass= temp*Mpass; 

%actualisation de matrbas qui va être réutilisé pour le coté droit
matrbas=Mpass;

%exprimer Fem1g dans le repère du bassin, alors qu'il est initialement
%exprimé dans le repère du monde positionné sur le bassin : R_Pelvis_monde
%(pelvis vers repère local monde et repere local_monde vers monde avec Z-up)
Fem1glocal=(R_monde_local*R_Pelvis_monde)'*Fem1g'; 


mattbth=[1 0 0 Fem1glocal(1) ; 0 1 0 Fem1glocal(2) ;0 0 1 Fem1glocal(3) ; 0 0 0 1];
Mpass= Mpass*mattbth;
Save = [];
Save = [Save , 1;Mpass(1:3,4)];


%Franck : insertion de la matrice pour aligner sur posture de
%ref/description
mathancheg=eye(4,4);
mathancheg(1:3,1:3)=R_LFem_ref_local; 

%matrice de rotation liée au mouvement hanche gauche
mathancheXg=[1 0 0 0;  0 cos(rhxg) -sin(rhxg) 0; 0 sin(rhxg) cos(rhxg) 0 ; 0 0 0 1];
mathancheYg=[cos(rhyg) 0 sin(rhyg) 0;  0 1 0 0; -sin(rhyg) 0 cos(rhyg) 0 ; 0 0 0 1];
mathancheZg=[cos(rhzg) -sin(rhzg) 0 0;  sin(rhzg) cos(rhzg) 0 0; 0 0 1 0; 0 0 0 1];

if flag
    mathancheg=mathancheg*mathancheZg*mathancheYg*mathancheXg;
else
    mathancheg=mathancheg*mathancheZg*mathancheYg*mathancheXg;
    %mathancheg=mathancheg*mathancheXg*mathancheYg*mathancheZg;
end

Mpass=Mpass*mathancheg; 

Zp=Fem6g-Fem1g; 
%matF1F6g=[1 0 0 Zp(1) ; 0 1 0 Zp(2) ;0 0 1 Zp(3) ; 0 0 0 1];
matF1F6g=[1 0 0 0 ; 0 1 0 -norm(Zp) ;0 0 1 0 ; 0 0 0 1];

Mpass=Mpass*matF1F6g;

Save = [Save , [2;Mpass(1:3,4)]];

%Franck : alignement du tibia avec la posture de ref/description

%matzgg=[1 0 0 0;  0 cos(rzgg) -sin(rzgg) 0; 0 sin(rzgg) cos(rzgg) 0 ; 0 0 0 1];
matzgg=[cos(rzgg) -sin(rzgg) 0 0; sin(rzgg) cos(rzgg) 0 0 ; 0 0 1 0; 0 0 0 1];

if flag
    matzgg=[cos(rzgg) -sin(rzgg) 0 0;  sin(rzgg) cos(rzgg) 0 0; 0 0 1 0; 0 0 0 1];
end
temp=eye(4,4); temp(1:3,1:3)=R_LTib_ref_local;
Mpass=Mpass*temp*matzgg;

ttz=Tal1g-Fem6g;
%matF6T1g=[1 0 0 ttz(1) ; 0 1 0 ttz(2) ;0 0 1 ttz(3) ; 0 0 0 1];
matF6T1g=[1 0 0 0 ; 0 1 0 -norm(ttz) ;0 0 1 0 ; 0 0 0 1];
Mpass=Mpass*matF6T1g;

Save = [Save , [3;Mpass(1:3,4)]];


% Bilan : Fonction de cinematique directe : 
matg=Mpass*[0;0;0;1];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%% DROITE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Mpass= matrbas;

%exprimer Fem1d dans le repère du bassin, alors qu'il est initialement
%exprimé dans le repère du monde positionné sur le bassin : R_Pelvis_monde
%(pelvis vers repère local monde) puis passage au repère du monde Z-UP
%Fem1dlocal=R_Pelvis_monde'*Fem1d'; 
Fem1dlocal=(R_monde_local*R_Pelvis_monde)'*Fem1d'; 



mattbth=[1 0 0 Fem1dlocal(1) ; 0 1 0 Fem1dlocal(2) ;0 0 1 Fem1dlocal(3) ; 0 0 0 1];
Mpass= Mpass*mattbth;

Save = [Save , [4;Mpass(1:3,4)]];

%Franck : insertion de la matrice pour aligner sur posture de
%ref/description
mathanched=eye(4,4);
mathanched(1:3,1:3)=R_RFem_ref_local; 

mathancheXd=[1 0 0 0;  0 cos(rhxd) -sin(rhxd) 0; 0 sin(rhxd) cos(rhxd) 0 ; 0 0 0 1];
mathancheYd=[cos(rhyd) 0 sin(rhyd) 0;  0 1 0 0; -sin(rhyd) 0 cos(rhyd) 0 ; 0 0 0 1];
mathancheZd=[cos(rhzd) -sin(rhzd) 0 0;  sin(rhzd) cos(rhzd) 0 0; 0 0 1 0; 0 0 0 1];

if flag
    mathanched=mathanched*mathancheZd*mathancheYd*mathancheXd;
else
    %mathanched=mathanched*mathancheXd*mathancheYd*mathancheZd;
    mathanched=mathanched*mathancheZd*mathancheYd*mathancheXd;
end

Mpass=Mpass*mathanched; 

Zp=Fem6d-Fem1d; 
%matF1F6d=[1 0 0 Zp(1) ; 0 1 0 Zp(2) ;0 0 1 Zp(3) ; 0 0 0 1];
matF1F6d=[1 0 0 0 ; 0 1 0 -norm(Zp) ;0 0 1 0 ; 0 0 0 1];

Mpass=Mpass*matF1F6d;

Save = [Save , [5;Mpass(1:3,4)]];


%rzfemg=0;
%mattorsfemg=[cos(rzfemg) -sin(rzfemg) 0 0;  sin(rzfemg) cos(rzfemg) 0 0; 0 0 1 0; 0 0 0 1];

%Mpass=Mpass*mattorsfemg;

% Matrice de passage pour rendre l'axe du genou (fem9-fem10) parrallele à l'axe du tibia (tib5-tib6)
%rygeng=0;
%Mpass_genoug=[cos(rygeng) 0 sin(rygeng) 0;  0 1 0 0; -sin(rygeng) 0 cos(rygeng) 0 ; 0 0 0 1];

%Mpass=Mpass*Mpass_genoug;
%matzgd=[1 0 0 0;  0 cos(rzgd) -sin(rzgd) 0; 0 sin(rzgd) cos(rzgd) 0 ; 0 0 0 1];
matzgd=[cos(rzgd) -sin(rzgd) 0 0; sin(rzgd) cos(rzgd) 0 0; 0 0 1 0; 0 0 0 1];

if flag
    matzgd=[cos(rzgd) -sin(rzgd) 0 0;  sin(rzgd) cos(rzgd) 0 0; 0 0 1 0; 0 0 0 1];
end

temp=eye(4,4); temp(1:3,1:3)=R_RTib_ref_local;
Mpass=Mpass*temp*matzgd;

ttz=Tal1d-Fem6d;
%matF6T1d=[1 0 0 ttz(1) ; 0 1 0 ttz(2) ;0 0 1 ttz(3) ; 0 0 0 1];
matF6T1d=[1 0 0 0 ; 0 1 0 -norm(ttz) ;0 0 1 0 ; 0 0 0 1];
Mpass=Mpass*matF6T1d;

Save = [Save , [6;Mpass(1:3,4)]];

% Bilan : Fonction de cinematique directe : 
matd=Mpass*[0;0;0;1];
% Réorganisation en fonction du sens de la marche, repéré par la coordonnée latérale de la Hanche 
if (Fem1g(1)>0)
    res = [matd(1:2) ; matg(3) ; matg(1:2) ; matd(3)];
else
    res= [matg(1:3);matd(1:3)];
end
