function [res,Save,newmarkers]=fcine_numerique_H3_markers(P,markers,Fem1g,Fem6g,Tal1g,Fem1d,Fem6d,Tal1d, R_monde_local, R_Pelvis_monde, R_LFem_ref_local, R_LTib_ref_local, R_RFem_ref_local, R_RTib_ref_local)
% Fonction cinématique du modèle
% Entrée : Angles P et paramètres physiologiques Fem...
% Param en ligne
% Sortie : Les positions des chevilles simulées
% Franck : intégration des rotations anatomiques initiales

newmarkers = markers;

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

Mpass = eye(4); % Monde 

Mpass = Mpass * R_Pelvis_monde; % On se pose en Opelvis, orientation pelvis de reference   

% Rotation angles pelvis
matrbasX=[1 0 0 0;  0 cos(rxb) -sin(rxb) 0; 0 sin(rxb) cos(rxb) 0 ; 0 0 0 1];
matrbasY=[cos(ryb) 0 sin(ryb) 0;  0 1 0 0; -sin(ryb) 0 cos(ryb) 0 ; 0 0 0 1];
matrbasZ=[cos(rzb) -sin(rzb) 0 0;  sin(rzb) cos(rzb) 0 0; 0 0 1 0; 0 0 0 1];
matrbas=matrbasX*matrbasY*matrbasZ;

% multiplication par R_pelvis_monde pour passer du repère du monde (rappel
% : Y_up (0;1;0) parfait, X vers l'avant, Z latéral) vers le repère du
% bassin légèrement incliné par rapport aux axes du monde
 
% temp=eye(4,4); temp(1:3,1:3)=R_Pelvis_monde;
Mpass= Mpass * matrbas; 

% temp(1:3,1:3)=R_monde_local; % ramener au repère du monde avec Z en haut
% Mpass= temp*Mpass; 

%actualisation de matrbas qui va être réutilisé pour le coté droit
matrbas=Mpass;

%exprimer Fem1g dans le repère du bassin, alors qu'il est initialement
%exprimé dans le repère du monde positionné sur le bassin : R_Pelvis_monde
%(pelvis vers repère local monde et repere local_monde vers monde avec Z-up)
% Fem1glocal=(R_monde_local*R_Pelvis_monde)'*Fem1g'; 
% Fem1glocal = Mpass(1:3,1:3) * Fem1g;

% mattbth=[1 0 0 Fem1glocal(1) ; 0 1 0 Fem1glocal(2) ;0 0 1 Fem1glocal(3) ; 0 0 0 1];
newmarkers.RFWT = Mpass * R_Pelvis_monde^-1 * [markers.RFWT';1];
newmarkers.RFWT = newmarkers.RFWT(1:3)';
newmarkers.LFWT = Mpass * R_Pelvis_monde^-1 *  [markers.LFWT';1];
newmarkers.LFWT = newmarkers.LFWT(1:3)';
newmarkers.RBWT = Mpass * R_Pelvis_monde^-1 *  [markers.RBWT';1];
newmarkers.RBWT = newmarkers.RBWT(1:3)';
newmarkers.LBWT = Mpass * R_Pelvis_monde^-1 *  [markers.LBWT';1];
newmarkers.LBWT = newmarkers.LBWT(1:3)';
newmarkers.LHRC = Mpass * R_Pelvis_monde^-1 *  [markers.LHRC';1];
newmarkers.LHRC = newmarkers.LHRC(1:3)';
newmarkers.RHRC = Mpass * R_Pelvis_monde^-1 *  [markers.RHRC';1];
newmarkers.RHRC = newmarkers.RHRC(1:3)';

Mpass= Mpass*R_LFem_ref_local;
Save = [];
Save = [Save , 1;Mpass(1:3,4)];
% newmarkers.LHRC = R_Pelvis_monde(1:3,1:3)^-1 * Mpass(1:3,4);
% newmarkers.LHRC = Mpass(1:3,4)'*1000;


%Franck : insertion de la matrice pour aligner sur posture de
%ref/description
% mathancheg=eye(4,4);
% mathancheg(1:3,1:3)=R_LFem_ref_local; 

%matrice de rotation liée au mouvement hanche gauche
mathancheXg=[1 0 0 0;  0 cos(rhxg) -sin(rhxg) 0; 0 sin(rhxg) cos(rhxg) 0 ; 0 0 0 1];
mathancheYg=[cos(rhyg) 0 sin(rhyg) 0;  0 1 0 0; -sin(rhyg) 0 cos(rhyg) 0 ; 0 0 0 1];
mathancheZg=[cos(rhzg) -sin(rhzg) 0 0;  sin(rhzg) cos(rhzg) 0 0; 0 0 1 0; 0 0 0 1];

if flag
    mathancheg=mathancheZg*mathancheYg*mathancheXg;
else
    mathancheg=mathancheZg*mathancheYg*mathancheXg;
    %mathancheg=mathancheXg*mathancheYg*mathancheZg;
end

Mpass=Mpass*mathancheg; 

MtransiFem = (R_Pelvis_monde * R_LFem_ref_local)^-1;

% newmarkers.RFem9 = Mpass * R_RTib_ref_local(1:3,1:3) * markers.RFem9';
newmarkers.LFem9 = Mpass * MtransiFem * [markers.LFem9';1];
newmarkers.LFem9 = newmarkers.LFem9(1:3)';
% newmarkers.RKNE = Mpass * R_RTib_ref_local(1:3,1:3) * markers.RKNE';
% newmarkers.LKNE = Mpass(1:3,1:3) * MtransiFem(1:3,1:3) * markers.LKNE';
newmarkers.LKNE = Mpass * MtransiFem * [markers.LKNE';1];
newmarkers.LKNE = newmarkers.LKNE(1:3)';

newmarkers.LFem6 = Mpass * MtransiFem * [markers.LFem6';1];
newmarkers.LFem6 = newmarkers.LFem6(1:3)';

% Zp=Fem6g-Fem1g; 
% Zp=(R_monde_local*R_Pelvis_monde*R_LFem_ref_local)'*Zp'; 


% matF1F6g=[1 0 0 Zp(1) ; 0 1 0 Zp(2) ;0 0 1 Zp(3) ; 0 0 0 1];
% matF1F6g=[1 0 0 0 ; 0 1 0 -norm(Zp) ;0 0 1 0 ; 0 0 0 1];

Mpass=Mpass*R_LTib_ref_local;

Save = [Save , [2;Mpass(1:3,4)]];
% newmarkers.LFem6 = Mpass(1:3,4)'*1000;

%Franck : alignement du tibia avec la posture de ref/description

%matzgg=[1 0 0 0;  0 cos(rzgg) -sin(rzgg) 0; 0 sin(rzgg) cos(rzgg) 0 ; 0 0 0 1];
matzgg=[cos(rzgg) -sin(rzgg) 0 0; sin(rzgg) cos(rzgg) 0 0 ; 0 0 1 0; 0 0 0 1];

if flag
    matzgg=[cos(rzgg) -sin(rzgg) 0 0;  sin(rzgg) cos(rzgg) 0 0; 0 0 1 0; 0 0 0 1];
end
% temp=eye(4,4); temp(1:3,1:3)=R_LTib_ref_local;
Mpass=Mpass*matzgg;

ttz=Tal1g;
MtransiTib = (R_Pelvis_monde * R_LFem_ref_local * R_LTib_ref_local)^-1;
% newmarkers.RKNI = Mpass * MtransiTib * [newmarkers.RKNI';1];
newmarkers.LKNI = Mpass * MtransiTib * [newmarkers.LKNI';1];
newmarkers.LKNI = newmarkers.LKNI(1:3)';
% newmarkers.RANE = Mpass * MtransiTib * [newmarkers.RANE';1];
% newmarkers.RANI = Mpass * MtransiTib * [newmarkers.RANI';1];
newmarkers.LANE = Mpass * MtransiTib * [newmarkers.LANE';1];
newmarkers.LANE = newmarkers.LANE(1:3)';
newmarkers.LANI = Mpass * MtransiTib * [newmarkers.LANI';1];
newmarkers.LANI = newmarkers.LANI(1:3)';
% newmarkers.RTib6 = Mpass * MtransiTib * [newmarkers.RTib6';1];
newmarkers.LTib6 = Mpass * MtransiTib * [newmarkers.LTib6';1];
newmarkers.LTib6 = newmarkers.LTib6(1:3)';
% newmarkers.RTib1 = Mpass * MtransiTib * [newmarkers.RTib1';1];
newmarkers.LTib1 = Mpass * MtransiTib * [newmarkers.LTib1';1];
newmarkers.LTib1 = newmarkers.LTib1(1:3)';
newmarkers.LTal1 = Mpass * MtransiTib * [newmarkers.LTal1';1];
newmarkers.LTal1 = newmarkers.LTal1(1:3)';

ttz = MtransiTib * [ttz';1];
% ttz=(R_Pelvis_monde*R_LFem_ref_local^-1*R_LTib_ref_local)'*ttz'; % A modif car Fem & Tib non ortho dir 
% MPass = MPass(1:3,1:3) *  ttz';
% matF6T1g=[1 0 0 ttz(1) ; 0 1 0 ttz(2) ;0 0 1 ttz(3) ; 0 0 0 1];
% matF6T1g=[1 0 0 0 ; 0 1 0 -norm(ttz) ;0 0 1 0 ; 0 0 0 1];
% Mpass=Mpass*matF6T1g;
% Save = [Save , [3;Mpass(1:3,4)]];
ttz = Mpass *  ttz;
Save = [Save , [3;ttz(1:3)]];

% newmarkers.LTal1 = Mpass(1:3,4)'*1000;



% Bilan : Fonction de cinematique directe : 
matg=ttz(1:3);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%% DROITE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Mpass= matrbas;

%exprimer Fem1d dans le repère du bassin, alors qu'il est initialement
%exprimé dans le repère du monde positionné sur le bassin : R_Pelvis_monde
%(pelvis vers repère local monde) puis passage au repère du monde Z-UP
%Fem1dlocal=R_Pelvis_monde'*Fem1d'; 
% Fem1dlocal=(R_monde_local*R_Pelvis_monde)'*Fem1d'; 



% mattbth=[1 0 0 Fem1dlocal(1) ; 0 1 0 Fem1dlocal(2) ;0 0 1 Fem1dlocal(3) ; 0 0 0 1];
Mpass= Mpass*R_RFem_ref_local;


Save = [Save , [4;Mpass(1:3,4)]];
% newmarkers.RHRC = Mpass(1:3,4)'*1000;

%Franck : insertion de la matrice pour aligner sur posture de
%ref/description
% mathanched=eye(4,4);
% mathanched(1:3,1:3)=R_RFem_ref_local; 

mathancheXd=[1 0 0 0;  0 cos(rhxd) -sin(rhxd) 0; 0 sin(rhxd) cos(rhxd) 0 ; 0 0 0 1];
mathancheYd=[cos(rhyd) 0 sin(rhyd) 0;  0 1 0 0; -sin(rhyd) 0 cos(rhyd) 0 ; 0 0 0 1];
mathancheZd=[cos(rhzd) -sin(rhzd) 0 0;  sin(rhzd) cos(rhzd) 0 0; 0 0 1 0; 0 0 0 1];

if flag
    mathanched=mathancheZd*mathancheYd*mathancheXd;
else
    %mathanched=mathancheXd*mathancheYd*mathancheZd;
    mathanched=mathancheZd*mathancheYd*mathancheXd;
end

Mpass=Mpass*mathanched; 

MtransiFem = (R_Pelvis_monde * R_RFem_ref_local)^-1;

newmarkers.RFem9 = Mpass * MtransiFem * [markers.RFem9';1];
newmarkers.RFem9 = newmarkers.RFem9(1:3)';
% newmarkers.LFem9 = Mpass * R_RTib_ref_local(1:3,1:3) * markers.LFem9';
newmarkers.RKNE = Mpass * MtransiFem * [markers.RKNE';1];
newmarkers.RKNE = newmarkers.RKNE(1:3)';
% newmarkers.LKNE = Mpass * R_RTib_ref_local(1:3,1:3) * markers.LKNE';
newmarkers.RFem6 = Mpass * MtransiFem * [markers.RFem6';1];
newmarkers.RFem6 = newmarkers.RFem6(1:3)';


% Zp=Fem6d-Fem1d; 
% Zp=(R_monde_local*R_Pelvis_monde*R_RFem_ref_local)'*Zp'; 

% matF1F6d=[1 0 0 Zp(1) ; 0 1 0 Zp(2) ;0 0 1 Zp(3) ; 0 0 0 1];
% matF1F6d=[1 0 0 0 ; 0 1 0 -norm(Zp) ;0 0 1 0 ; 0 0 0 1];

% Mpass=Mpass*matF1F6d;

Mpass = Mpass * R_RTib_ref_local;

Save = [Save , [5;Mpass(1:3,4)]];
% newmarkers.RFem6 = Mpass(1:3,4)'*1000;

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

% temp=eye(4,4); temp(1:3,1:3)=R_RTib_ref_local;
% Mpass=Mpass*temp*matzgd;
Mpass=Mpass*matzgd;

ttz = Tal1d;

MtransiTib = (R_Pelvis_monde * R_RFem_ref_local * R_RTib_ref_local)^-1;
% newmarkers.RKNI = Mpass * MtransiTib * [newmarkers.RKNI';1];
newmarkers.RKNI = Mpass(1:3,1:3) * MtransiTib(1:3,1:3) * markers.RKNI';

newmarkers.RKNI = newmarkers.RKNI(1:3)';
% newmarkers.LKNI = Mpass * MtransiTib * [newmarkers.LKNI';1];
newmarkers.RANE = Mpass * MtransiTib * [newmarkers.RANE';1];
newmarkers.RANE = newmarkers.RANE(1:3)';
newmarkers.RANI = Mpass * MtransiTib * [newmarkers.RANI';1];
newmarkers.RANI = newmarkers.RANI(1:3)';
% newmarkers.LANE = Mpass * MtransiTib * [newmarkers.LANE';1];
% newmarkers.LANI = Mpass * MtransiTib * [newmarkers.LANI';1];
newmarkers.RTib6 = Mpass * MtransiTib * [newmarkers.RTib6';1];
newmarkers.RTib6 = newmarkers.RTib6(1:3)';
% newmarkers.LTib6 = Mpass * MtransiTib * [newmarkers.LTib6';1];
newmarkers.RTib1 = Mpass * MtransiTib * [newmarkers.RTib1';1];
newmarkers.RTib1 = newmarkers.RTib1(1:3)';
% newmarkers.LTib1 = Mpass * MtransiTib * [newmarkers.LTib1';1];
newmarkers.RTal1 = Mpass * MtransiTib * [newmarkers.RTal1';1];
newmarkers.RTal1 = newmarkers.RTal1(1:3)';

ttz = MtransiTib * [ttz';1];


ttz = Mpass *  ttz;

Save = [Save , [6;ttz(1:3)]];
% newmarkers.RTal1 = Mpass(1:3,4)'*1000;

% ttz=(R_monde_local*R_Pelvis_monde*R_RFem_ref_local*R_RTib_ref_local)'*ttz'; 

% matF6T1d=[1 0 0 ttz(1) ; 0 1 0 ttz(2) ;0 0 1 ttz(3) ; 0 0 0 1];
% matF6T1d=[1 0 0 0 ; 0 1 0 -norm(ttz) ;0 0 1 0 ; 0 0 0 1];
% Mpass=Mpass*matF6T1d;

% Save = [Save , [6;ttz(1:3)]];

% Bilan : Fonction de cinematique directe : 
% matd=Mpass*[0;0;0;1];
matd=ttz(1:3);
% Réorganisation en fonction du sens de la marche, repéré par la coordonnée latérale de la Hanche 
% if (Fem1g(1)>0)
%     res = [matd(1:2) ; matg(3) ; matg(1:2) ; matd(3)];
% else
    res= [matg(1:3);matd(1:3)];
% end

