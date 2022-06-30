%%% Sumum de l'horreur
%%% Sélection des résultats les mieux.
%%% Cette partie est quasi entièrement skippable, je la garde par peur de casser
%%% l'algo...

%%% Le but était de sélectionner les meilleurs résultats, mais c'est un
%%% bordel sans nom..

% A setter à 0, sinon ça lance des images...
animflag =0;
saveflag = 0;
printflag=0;

% Mémorisation des données intéressantes
mem = [N;mV*0.001;mJ;mSter.'];

% Si y'en a pas, Exit
if (isempty(mem))
    Saved =[];
    SNPCA = [];
    return;
end

% On trie pour avoir le min en erreur
mem = [N;mV*0.001;mJ;mSter.'];
[~,f]=sort(mem(1,:));
Saved = mem(:,f(1));
% On sélectionne l'indice
A = find(mem(3,:)==Saved(3,1));
if(A(1)==1)
    % On récupère les PCA correspondants
    SNPCA = Storing(Storing(:,1)==A(1)-1,2:end);
else
    SNPCA = Storing(Storing(:,1)==A(1)-2,2:end);
end
NPCA = SNPCA;
if find(NPCA(:,2)==0)
    NPCA(find(NPCA(:,2)==0),2) = 1/Period;
end
% On calcule le pol
NPolA = [];
for i = 1:11
    temp = PC_to_spline(NPCA(NPCA(:,1)==i,2:3),1);
    NPolA = [NPolA ; i*ones(size(temp,1),1), temp(:,2:end)];
end
% on calcule les courbes pour la sauvegarde ou l'affichage 
[PFin, TAFin] = Sampling(NPolA,Period,Fem1g, Fem1d, Fem6g, Fem6d, Tal1g, Tal1d, R_monde_local,R_Pelvis_monde_local, R_LFem_ref_local, R_LTib_ref_local, R_RFem_ref_local, R_RTib_ref_local);

% Exit
return;
% 
% [~,f]=sort(mem(2,:));
% 
% if size(f,2)>4
%     Saved = mem(:,f(1:5));
% else 
%     Saved = mem(:,f(1:end));
% end
% 
% mem = [N;mV*0.001;mJ;mSter.'];
% 
% A = find(mem(3,:)==Saved(3,1));
% if(A(1)==1)
%         SNPCA = Storing(Storing(:,1)==A(1)-1,2:end);
%     else
%         SNPCA = Storing(Storing(:,1)==A(1)-2,2:end);
% end

 % Recalcul de tout un bordel pour de l'animation   
if printflag
NPCA = SNPCA;

test =find(NPCA(:,2)==0);
NPCA(test,2)=eps;
NPolA = [];
for i = 1:11
    temp = PC_to_spline(NPCA(NPCA(:,1)==i,2:3),1);
    NPolA = [NPolA ; i*ones(size(temp,1),1), temp(:,2:end)];
end

[PFin, TAFin] = Sampling(NPolA,Period,Fem1g, Fem1d, Fem6g, Fem6d, Tal1g, Tal1d);

printflag=0;
% Calcul & Affichages si printflag
if (printflag)
    
    NPolA = [];
    for i = 1:11
        temp = PC_to_spline(NPCA(NPCA(:,1)==i,2:3),1);
        NPolA = [NPolA ; i*ones(size(temp,1),1), temp(:,2:end)];
    end
    
    
%     Calcul de la fonction F pour les NPCA
    NRef = [];
    a = ErrorFun(NPolA,X);
    
%     Mesure et mémorisation de la norme de la somme des erreurs
    for i =1:size(X,1)
        NRef = [NRef; X(i,3:end)-a(i,:)];
    end



% Echantillonage pour calcul coûts secondaires
[P, TA] = Sampling(NPolA,Fem1g, Fem1d, Fem6g, Fem6d, Tal1g, Tal1d);

    
    
    figure(1);
    hold on;
    for i = 1:11
        subplot(3,4,i);
        hold on;
        xlabel('cycle de marche, %');
        ylabel('trajectoire articulaire, rad');
        plot(0:1/60:1,TA(:,i),'b');
        plot(0:1/60:1,TrajAng(:,i),'b--');
    end
    sgtitle('Traj. angulaires sur cycle de marche. G à D : bX, bY,bZ, hgX, hgY, hgZ, ggX, hdX, hdY, hdZ, gdX');
    hold off;
    
    figure(2);
    for i = 1:6
        subplot(2,3,i);
        hold on;
        xlabel('cycle de marche, %');
        ylabel('position cheville, m');
        plot(0:1/60:1,Spline(:,i),'r');
        if i<4
            plot(X(1:size(X,1)/2,2),X(1:size(X,1)/2,i+2),'rx','MarkerSize',10);
        else
            plot(X(size(X,1)/2+1:end,2),X(size(X,1)/2+1:end,i-1),'rx','MarkerSize',10);
        end
        plot(0:1/60:1,P(:,i),'b');
    end
    sgtitle('Poulaines respectivement Gauche/Droite, X, Y, Z');
end

% Affichages valeurs de contrôle
norm(NRef);

Cost = CE(P,TA,M,Fem1g, Fem1d, Fem6g, Fem6d, Tal1g, Tal1d);

JerkRef = Jerk(NPolA);


% Si on veut de l'animation avec animflag==1
% mvt=TA;
mvt = TrajAng;
animflag=1;
if animflag==1
    figure(10);
    for j=0:3
        for i=1:size(mvt,1)
            tracer_posture(mvt(i,:),j,Fem1g,Fem6g,Tal1g,Fem1d,Fem6d,Tal1d); pause(1/207);
        end
        
    end
end
saveflag=0;
if saveflag
    file = 'C:\Users\nhareng\Documents\Prog\Matlab\Branch Reu 25-10\Resultats\3 pts\NPCA.txt';
    dlmwrite(file,NPCA,'-append');
    clear NPCA;
    NPCA = load(file);
end

end