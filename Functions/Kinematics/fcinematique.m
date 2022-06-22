function [PosAnkle,NewMarkers,NewReperes]=fcinematique(Angles,Sequence,Markers,Reperes)
% Fonction cinématique du modèle
% Entrée : Angles P et paramètres physiologiques Fem...
% Param en ligne
% Sortie : Les positions des chevilles simulées
% Franck : intégration des rotations anatomiques initiales
% Corrections. New chain order :
% Monde Local = OND Pelvis with Y forced Up, O in center FWT = OPelv
% Pelvis - According to ISB : Z between FWT, pointing right ; Y cross(vector between midFWT & midBWT, pointing forward, Z) ; X cross(Y,Z)  
% Rota Pelv
% Transla to HRC = HRC-OPelv
% Fem1 - According to ISB : Y HRC - Fem6 ; Xtemp cross(Y,Z_ML) ; Z cross(Xtemp,Y) ; X = cross(Y,Z)  
% Rota Hip
% Transla to Fem6 = midFE
% Fem 2 - Z FEE - FEI pointing right ; X cross(Y_F1,Z) ; Y cross(Z,X)
% Rota Knee
% Transla mid Tibial Plat
% Tibia : 
% Transla Ankle & other markers
if nargin == 3 || isempty(Sequence) % Default Sequence
    Sequence.Pelvis = 'xyz';
    Sequence.LHip = 'zyx';
    Sequence.LKnee = 'z';
    Sequence.RHip = 'zyx';
    Sequence.RKnee = 'z';
end


NewMarkers = Markers;
% Parseur

% a = [1,0,0,1]';
% b = [0,1,0,1]';
% c = [0,0,1,1]';
if ~isstruct(Angles)
    tmp = Angles;
    clear Angles;
    Angles.Pelvis = tmp(1:3);
    Angles.RHip = tmp(4:6);
    Angles.RKnee = [zeros(1,2),tmp(7)];
    Angles.LHip = tmp(8:10);
    Angles.LKnee = [zeros(1,2),tmp(11)];
    
    % Modifs 21/03 -- R/L
end




Mpass = eye(3);

% Mlocal = Reperes.MondeLocal;

% Mlocal = Reperes.PelvisLocal^-1;
% Mpass = Mpass * Reperes.Monde^-1; % Monde 
% Mpass = Mpass * Reperes.MondeLocal(1:3,1:3);
Mpass =  Reperes.Pelvis(1:3,1:3); %  orientation pelvis de reference   
Transla = Reperes.Pelvis(1:3,4); % On se pose en Opelvis - Position Origine actuelle dans Omega

% Mlocal = Reperes.Pelvis^-1 * Mlocal;

%%% Rotation angles pelvis
SP = SequentialRotation(Angles.Pelvis, Sequence.Pelvis);
Mpass = Mpass * SP(1:3,1:3);

% Reperes Pour affichage
NewReperes.Pelvis = eye(4);
NewReperes.Pelvis(1:3,1:3) = Mpass;
NewReperes.Pelvis(1:3,4) = Mpass * Transla;


MPelv = Mpass;

% Calcul des positions des markers liés au segment :

Cheat = Reperes.Pelvis(1:3,1:3)^-1;

NewMarkers.RFWT = Mpass * Cheat * (Markers.RFWT' - Transla);
NewMarkers.RFWT = NewMarkers.RFWT(1:3)';

NewMarkers.LFWT = Mpass * Cheat * (Markers.LFWT' - Transla);
NewMarkers.LFWT = NewMarkers.LFWT(1:3)';

NewMarkers.RBWT = Mpass * Cheat * (Markers.RBWT' - Transla);
NewMarkers.RBWT = NewMarkers.RBWT(1:3)';

NewMarkers.LBWT = Mpass * Cheat  * (Markers.LBWT' - Transla);
NewMarkers.LBWT = NewMarkers.LBWT(1:3)';

NewMarkers.LHRC = Mpass * Cheat * (Markers.LHRC' - Transla);
NewMarkers.LHRC = NewMarkers.LHRC(1:3)';

NewMarkers.RHRC = Mpass * Cheat * (Markers.RHRC' - Transla);
NewMarkers.RHRC = NewMarkers.RHRC(1:3)';

% % Translation jusqu'à OHanche G 
Transla = NewMarkers.LHRC' - Transla;

% % Passage au repère Fem 1 G (O = LHRC ) 
Mpass = Mpass * (Reperes.Pelvis(1:3,1:3)^-1 * Reperes.LFemur1(1:3,1:3)); % Passage en repère Fem1 - Hanche Ref

% Rotation Angles Hanche G 
SLH = SequentialRotation(Angles.LHip, Sequence.LHip);
Mpass = Mpass * SLH(1:3,1:3);

NewReperes.LFemur1 = eye(4);
NewReperes.LFemur1(1:3,1:3) = Mpass;
NewReperes.LFemur1(1:3,4) = Transla;

% Recalcul position markers segment Femur G

Cheat =  Reperes.LFemur1(1:3,1:3)^-1;

NewMarkers.LFem9 = Mpass  * Cheat * (Markers.LFem9' - Markers.LHRC');
NewMarkers.LFem9 = NewMarkers.LHRC + NewMarkers.LFem9(1:3)';

NewMarkers.LKNE = Mpass * Cheat  * (Markers.LKNE' - Markers.LHRC');
NewMarkers.LKNE = NewMarkers.LHRC + NewMarkers.LKNE(1:3)';

NewMarkers.LFem6 = Mpass * Cheat  * (Markers.LFem6' - Markers.LHRC');
NewMarkers.LFem6 = NewMarkers.LHRC + NewMarkers.LFem6(1:3)';


%%%TOTEST


% Translation jusqu'à OKnee G & Repere Fem 2 G
Transla = NewMarkers.LFem6';
Mpass = Mpass * (Reperes.LFemur1(1:3,1:3)^-1 * Reperes.LFemur2(1:3,1:3));

NewReperes.LFemur2 = eye(4);
NewReperes.LFemur2(1:3,1:3) = Mpass;
NewReperes.LFemur2(1:3,4) = NewMarkers.LFem6';

% Rotation Angles Genou G 
SLK = SequentialRotation(Angles.LKnee, Sequence.LKnee);
Mpass = Mpass * SLK(1:3,1:3);

NewMarkers.LTib1 = NewMarkers.LFem6' + Mpass * Cheat * (Markers.LTib1' - Markers.LFem6');
NewMarkers.LTib1 = NewMarkers.LTib1';


% Translation jusqu'à OTib G & Repere Tib Local G
Transla = NewMarkers.LTib1;
Mpass = Mpass * (Reperes.LFemur2(1:3,1:3)^-1 * Reperes.LTibia(1:3,1:3));

NewReperes.LTibia = eye(4);
NewReperes.LTibia(1:3,1:3) = Mpass;
NewReperes.LTibia(1:3,4) = NewMarkers.LTib1';

% Recalcul position markers segment Tibia G

Cheat = Reperes.LTibia(1:3,1:3)^-1;

NewMarkers.LKNI = Mpass * Cheat * (Markers.LKNI' - Markers.LTib1');
NewMarkers.LKNI = NewMarkers.LTib1 + NewMarkers.LKNI(1:3)';

NewMarkers.LANE = Mpass * Cheat * (Markers.LANE' - Markers.LTib1');
NewMarkers.LANE = NewMarkers.LTib1 + NewMarkers.LANE(1:3)';

NewMarkers.LANI = Mpass * Cheat * (Markers.LANI' - Markers.LTib1');
NewMarkers.LANI = NewMarkers.LTib1 + NewMarkers.LANI(1:3)';

NewMarkers.LTib6 = Mpass * Cheat * (Markers.LTib6' - Markers.LTib1');
NewMarkers.LTib6 = NewMarkers.LTib1 + NewMarkers.LTib6(1:3)';

NewMarkers.LTal1 = Mpass * Cheat * (Markers.LTal1' - Markers.LTib1');
NewMarkers.LTal1 = NewMarkers.LTib1 + NewMarkers.LTal1(1:3)';

%%%%%%%%%%%%%%%%%%%%%%%%% Droite
Mpass = MPelv;
Transla = Reperes.Pelvis(1:3,4);

% % Translation jusqu'à OHanche D 
Transla = NewMarkers.RHRC' - Transla;

% % Passage au repère Fem 1 G (O = RHRC ) 
Mpass = Mpass * (Reperes.Pelvis(1:3,1:3)^-1 * Reperes.RFemur1(1:3,1:3)); % Passage en repère Fem1 - Hanche Ref

% Rotation Angles Hanche G 
SRH = SequentialRotation(Angles.RHip, Sequence.RHip);
Mpass = Mpass * SRH(1:3,1:3);


NewReperes.RFemur1 = eye(4);
NewReperes.RFemur1(1:3,1:3) = Mpass;
NewReperes.RFemur1(1:3,4) = Transla;

% Recalcul position markers segment Femur G

Cheat =  Reperes.RFemur1(1:3,1:3)^-1;

NewMarkers.RFem9 = Mpass  * Cheat * (Markers.RFem9' - Markers.RHRC');
NewMarkers.RFem9 = NewMarkers.RHRC + NewMarkers.RFem9(1:3)';

NewMarkers.RKNE = Mpass * Cheat  * (Markers.RKNE' - Markers.RHRC');
NewMarkers.RKNE = NewMarkers.RHRC + NewMarkers.RKNE(1:3)';

NewMarkers.RFem6 = Mpass * Cheat  * (Markers.RFem6' - Markers.RHRC');
NewMarkers.RFem6 = NewMarkers.RHRC + NewMarkers.RFem6(1:3)';


%%%TOTEST


% Translation jusqu'à OKnee G & Repere Fem 2 G
Transla = NewMarkers.RFem6';
Mpass = Mpass * (Reperes.RFemur1(1:3,1:3)^-1 * Reperes.RFemur2(1:3,1:3));

NewReperes.RFemur2 = eye(4);
NewReperes.RFemur2(1:3,1:3) = Mpass;
NewReperes.RFemur2(1:3,4) = NewMarkers.RFem6';

% Rotation Angles Genou G 
SRK = SequentialRotation(Angles.RKnee, Sequence.RKnee);
Mpass = Mpass * SRK(1:3,1:3);

NewMarkers.RTib1 = NewMarkers.RFem6' + Mpass * Cheat * (Markers.RTib1' - Markers.RFem6');
NewMarkers.RTib1 = NewMarkers.RTib1';


% Translation jusqu'à OTib G & Repere Tib Rocal G
Transla = NewMarkers.RTib1;
Mpass = Mpass * (Reperes.RFemur2(1:3,1:3)^-1 * Reperes.RTibia(1:3,1:3));

NewReperes.RTibia = eye(4);
NewReperes.RTibia(1:3,1:3) = Mpass;
NewReperes.RTibia(1:3,4) = NewMarkers.RTib1';

% Recalcul position markers segment Tibia G

Cheat = Reperes.RTibia(1:3,1:3)^-1;

NewMarkers.RKNI = Mpass * Cheat * (Markers.RKNI' - Markers.RTib1');
NewMarkers.RKNI = NewMarkers.RTib1 + NewMarkers.RKNI(1:3)';

NewMarkers.RANE = Mpass * Cheat * (Markers.RANE' - Markers.RTib1');
NewMarkers.RANE = NewMarkers.RTib1 + NewMarkers.RANE(1:3)';

NewMarkers.RANI = Mpass * Cheat * (Markers.RANI' - Markers.RTib1');
NewMarkers.RANI = NewMarkers.RTib1 + NewMarkers.RANI(1:3)';

NewMarkers.RTib6 = Mpass * Cheat * (Markers.RTib6' - Markers.RTib1');
NewMarkers.RTib6 = NewMarkers.RTib1 + NewMarkers.RTib6(1:3)';

NewMarkers.RTal1 = Mpass * Cheat * (Markers.RTal1' - Markers.RTib1');
NewMarkers.RTal1 = NewMarkers.RTib1 + NewMarkers.RTal1(1:3)';



PosAnkle = [NewMarkers.RTal1' ; NewMarkers.LTal1']/1000;

%%%%%%%%
end