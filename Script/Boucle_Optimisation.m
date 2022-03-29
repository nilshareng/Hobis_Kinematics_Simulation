%%% Le gros morceau...
%%% Fonctionnement :
%%% Entrée : - Trajectoires articulaires splinées sous forme d'un Polynôme et des bornes d'intervalles.
%%%          - Empreintes 'X'
%%% Sortie : L'intégralité des données traitées est retourné dans la structure 'Results'


% Déclaration de variables / flags
VarDeclaration;

dp = [0.001, 0.001];

% Ajout nécessaire, c'était pour ne pas modifier la fonction de calcul de
% la Jacobienne...
dp=[dp,Period];

% Affichages si désirés...
printflag=0;

% Ajout de l'option gradient 0, non updaté pour les c3d actuels car pas de convergence de base.
derflag = 0;
MaxLoop = 100;
SaveV = [];
SaveM = [];
SC = 0;
PasDelta = 0.1; % Norm of the vector from curr pos to target pos
PasModifs = 1; % 
close all;
% fConv = figure(12);
% hold on;

Mem = struct;

Log = struct;
Log.ModifsNorm = zeros(MaxLoop+1,1);

X = FindFootprints(KinModelPrints.Poulaine*10^-3);
X = [X(2,:) ; X(2,:); X(2,:) ;X(5,:) ; X(5,:) ; X(5,:)];

NewDetails = Details;

DisplayCurves(KinModelC3D.Poulaine/1000,10);
DisplayCurves(KinModelPrints.Poulaine/1000,10);
close(figure(11));

while c<MaxLoop % Nombre de cycle arbitraire, 20-25 suffisant pour discerner les convergences sans crash
        
    c

    % Sécurité en cas de dysfonctionnement - Déprécié
    if(size(Modifs,1) == 36)
        Modifs= [Modifs; zeros(20,1)];
    end
    
    % Début de la boucle : Ajout des 'Modifs' aux Points de contrôles
    % angulaires
    % Recalcul, classement et symétrisation des PCA dans NPCA
    [NPCA,NPolA,Iflag,NewDetails] = ModifPCA(Modifs, NPCA, Period, Sequence, Markers, Reperes, InvE, mid,...
        Threshold, PCA, c, Cflag, rate, Iflag, Details);

    [tmpP2, tmpTA2] = Sampling_txt(NPolA,Period,Sequence,Markers,Reperes);
    
    Mem(c+1).PC = NPCA;
    Mem(c+1).Pol = NPolA;
    
    DisplayCurves(tmpP2,10);
    DisplayCurves(tmpTA2,11);
%     DisplayCurves(InitialGait,10);
    DisplayX(X,size(tmpP2,1)-2,10)
%     
    % Calcul de la fonction de coût pour les NPCA
    NRef = [];
    
    % Cibles intermédiaires :
    [a,NewMarkers,NewReperes] = ErrorFun3(NPolA,X,Sequence,Rmarkers,RReperes); % ErrorFun2 sinon
    % Mesure et mémorisation de la norme de la somme des erreurs
    
    for i =1:size(X,1)
        NRef = [NRef; X(i,3:end)-a(i,:)];
    end
            
    % Echantillonage pour calcul coûts secondaires
    [P, TA] = Sampling_txt(NPolA,Period,Sequence,Markers,Reperes);
    
    Mem(c+1).P = P;
    Mem(c+1).TA = TA;
    
    % Sécurité
    if(isempty(P)||isempty(TA))
        return;
    end
    
    % Affichages si printflag
    if (printflag)
        figure(1); % TA - Original, puis successifs
        hold on;
        for i = 1:11
            subplot(3,4,i);
            hold on;
            xlabel('cycle de marche, %');
            ylabel('trajectoire articulaire, rad');
            plot(0:1/(Period-1):1,TA(1:end-1,i),'b');
            plot(0:1/(Period-1):1,TrajAng(:,i),'r--');
        end
        sgtitle('Traj. angulaires sur cycle de marche. G à D : bX, bY,bZ, hgX, hgY, hgZ, ggX, hdX, hdY, hdZ, gdX');
        hold off;
        
        figure(2); % Poulaines - Originale en rouge, puis successifs, et X
        for i = 1:6
            subplot(2,3,i);
            hold on;
            xlabel('cycle de marche, %');
            ylabel('position cheville, m');
%             plot(0:1/(Period-1):1,Spline(:,i),'g--');
            plot(0:1/(Period-1):1,GT(:,i),'r');
%             plot(0:1/(Period-1):1,PN(:,i),'b');
            
            if i<4
                plot(X(1:size(X,1)/2,2),X(1:size(X,1)/2,i+2),'rx','MarkerSize',10);
                
            else
                plot(X(size(X,1)/2+1:end,2),X(size(X,1)/2+1:end,i-1),'rx','MarkerSize',10);
            end
            if c==0 && size(dp,2)==3
%                 plot(0:1/Period:1,PN(:,i));
                plot(0:1/(Period-1):1,P(1:end-1,i));
            else
                plot(0:1/(Period-1):1,P(1:end-1,i));
            end
            
        end
        sgtitle('Poulaines respectivement Gauche/Droite, X, Y, Z');
%         legend(leg)
    end
    
    % Coût énergétique
    Cost = ECShort(P,TA,M,Markers,Inertie);
    
    Mem(c+1).EC = Cost;
    
    % Jerk
    JerkRef = 0;
%     Jerk(NPolA);

    % ArticularCost 
    
    ACRef = ArticularCostPC(NPolA, Period, Sequence, Markers, Reperes, model.jointRangesMin, model.jointRangesMax);
    
    Mem(c+1).AC = ACRef;
    
    % Sauvegarde des valeurs de contrôle
    Conv = [Conv , [norm(NRef); Cost ; JerkRef ; norm(ACRef)]];
    % Affichage
    if printflag
        norm(NRef)
        Cost
        JerkRef
    end
       
    Mem(c+1).Conv = Conv;
    
    % Calcul de la Jacobienne

    [Jk, V, DJerk, DAC] = calc_jacobien_PC_4D(NPCA, NPolA,X,dp,M,Cost,JerkRef,ACRef,Rmarkers,RReperes, ...
        Sequence,Inertie, model.jointRangesMin, model.jointRangesMax);
    SaveV = [SaveV , V];
    SaveM = [SaveM ; NPolA];
    
    Mem(c+1).Jk = Jk;
    
    
    % Si problème de taille de tableau, complétion avec des 1
    if size(V,1)~=2*size(NPCA,1)
        V = [V ; ones(size(Modifs,1)-size(V,1),1)];
        DJerk = [DJerk ; ones(size(Modifs,1)-size(DJerk,1),1)];
    end
    
    % Si Erreur -> Exit
    if(isempty(Jk)||isempty(V)||isempty(DJerk))
    Log.FatalFunctionErrorCycle = c;
    error('Jacobian is fucked');
    end

    % Pseudo Inverse
    Jkp = pinv(Jk);
    
    
    % Protection contre singularités : 
    if norm(Jk) > 10^3 || norm(Jkp) > 10^3 
        [NPCA,NPolA,Jk, Jkp, V, DJerk, DAC, Log] = JacSingularitiesCheck( NPCA, NPolA, X,dp,M,Cost,JerkRef , ...
            ACRef, Period, Sequence, Markers, Reperes, InvE, mid, Threshold, PCA, c, Cflag, rate, ...
            model, tmpP2, tmpTA2,Log, SC, Jk, Jkp);
    end
    
    % Projection
    Proj = eye(max(size(Jk))) - Jkp*Jk;
    
    % Mémorisation
    N = [N , norm(NRef)];
    mV = [mV , Cost];
    mJ=[mJ, JerkRef];
    pModifs = [pModifs , Modifs];
    
    Mem(c+1).N = N;
    Mem(c+1).Modifs = Modifs;
    
    % Adaptation de la forme du vecteur de distance à X
    
    t=zeros(3*size(NRef,1),1);
    for a = 1:size(NRef,1)
        t(3*a-2)=NRef(a,1);
        t(3*a-1)=NRef(a,2);
        t(3*a)=NRef(a,3);
    end
    delta = t;

    delta = (delta/norm(delta))*min(norm(delta),PasDelta);
    
    % Pondération des couts secondaires - à passer en paramètres ?
    VSter = -0.5 * norm(Jkp*delta);
    PondAC = -0.5 * norm(Jkp*delta);
    
    TS1 = Proj * V / norm(Proj * V) * VSter;
    TS2 = Proj * DAC / norm(Proj * DAC) * PondAC;
    
    Modifs = Jkp*delta + TS1 ;%+ TS2;
    
    
    Log.ModifsNorm(c+1) = norm(Modifs);
    Modifs = (Modifs/norm(Modifs))*min(norm(Modifs),PasModifs);
    
    
    % Incrémentation du compteur de cycles
    c = c+1;
    
    % Affichage de la convergence
    
    fConv = [];
    fConv = figure(12);
    hold on;
    subplot(2,1,1);
    hold on;
    title('Convergence de la boucle d''optimisation - somme des distances aux empreintes - en m');
    plot(1:size(Conv,2),Conv(1,:));
    subplot(2,1,2);
    hold on;
    title('Convergence de la boucle d''optimisation - Travail des forces internes');
    plot(1:size(Conv,2),Conv(2,:));
    
    Log.OptiCycle.ClosureCycle = c;
    
    if Conv(1,end) < 0.01
       c=MaxLoop+1; 
    else
        
    end
end

%% Selection de la meilleure solution

[~,d] = min(Conv(1,:));
Mem = Mem(d);

%%

% Log.TimeEndOpti = toc(Log.TimeIniOpti);
[Gait, GaitMarkers, GaitReperes] = Angles2Gait(tmpTA2,Sequence,Markers,Reperes,model.gait*1000, ...
    P*1000,SplinedComputedPoulaine*1000,X(:,3:5)*1000);%[model.gait(4:6,:)*1000, model.gait(1:3,:)*1000]);

close all;
% fFGait = DisplayGait(GaitMarkers);

% DisplayCurves(P,2);       
% DisplayCurves([P(:,4:6), P(:,1:3)],2);
% DisplayCurves(tmpTA2,3);
% DisplayCurves([tmpTA2(:,1:3), tmpTA2(:,8:11) , tmpTA2(:,4:7)],3);

Results = struct;
Results.Inputs = answer;
Results.Mem = Mem;
Results.Sequence = Sequence;
Results.Markers = Markers;
Results.Reperes = Reperes;
if exist('InitialGait')
    Results.InitialPoulaine = InitialGait;
    Results.InitialPoulaineScaled = model.gait;
    Results.InitialPoulaineScaledIK = NewPoul;
    Results.OriginalX = InputX;
    Results.EmpreintesPoulaineInput = PX;
    Results.PoulaineEmpreintesInput = OOPN;
    Results.PoulaineEmpreintesInputScaled = OPN;
else
    Results.Details = Details;
    Results.NewDetails = NewDetails;
end
Results.GaitData = GData;
Results.InitialSplinedPoulaine = SplinedComputedPoulaine;
Results.FinalPoulaine = P;
Results.TAPostIK = NewAngles;
Results.TAFinal = TA;
Results.InitialReference = model.reference;
Results.InitialDescription = model.description;
Results.InitialSplinedAngles = SplinedAngles;

Results.EmpreintesScaled = X;
Results.InitialPolynom = PolA;
Results.FinalPolynom = NPolA;
Results.IncrementalPCModification = pModifs;
Results.Convergence = Conv;
Results.NCycles = c;
Results.Logs = Log;
if exist('PolX')
    Results.TargetPolynom = PolX;
%     Results.Target = ;
end

% Results.Figure.Conv = fConv;
% Results.Figure.FinalGait = fFGait;
Results.MemoryEC = mV;
Results.MemoryPoulaine = SaveM;
Results.GaitMarkers = GaitMarkers;

if exist('KinModelC3D')
    Results.Model(1) = KinModelC3D;
    Results.Model(2) = KinModelPrints;
end
% DisplayGait(GaitMarkers,20,'4');

Spline = [];
I = 60;
for i = 1:11
    tmpPol = Pol(Pol(:,1)==i,:);
    TS2 = [];
    for tc= 0:1/I:1
        % Echantillonnage pour chaque Angle
        a= EvalSpline(tmpPol, tc);
        if(a==-10)
            P2=[];
            TA2=[];
           return; 
        end
        TS2 = [TS2;a];
    end
    Spline = [Spline, TS2];
end

