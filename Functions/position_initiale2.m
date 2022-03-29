function etat=position_initiale2(etat0,posg,posd,butemin,butemax,Fem1g,Fem6g,Tal1g,Fem1d,Fem6d,Tal1d,R_monde_local, R_Pelvis_monde, R_LFem_ref_local, R_LTib_ref_local, R_RFem_ref_local, R_RTib_ref_local)

etatc=etat0;
pas=0.05; % pas de 5mm sur la cinématique inverse
pos=fcine_numerique_H(etat0,Fem1g,Fem6g,Tal1g,Fem1d,Fem6d,Tal1d)

% calcul de la norme du vecteur déplacement
X=[posg posd]'

distanceT=norm(pos-X); 
distances=[pas:pas:distanceT distanceT]; % calcul des vecteurs déplacement successifs
unit=(X-pos)/norm(X-pos);
for i=1:length(distances)
  cible(i,:)=pos'+distances(i)*unit';
end;
nbdecompo=length(distances);
poids=0.1;
        options=[0 200*11 0.1 2 0.5 10e-4];
%    OPTIONS(1) : affichage des résultats intermédiaires (0 par défaut).
%    OPTIONS(2) : nombre maximum d'itérations (200*length(X0) par défaut).
%    OPTIONS(3) : taille du simplèxe de départ (1 par défaut).
%    OPTIONS(4) : facteur d'expansion (2 par défaut).
%    OPTIONS(5) : facteur de contraction (0.5 par défaut).
%    OPTIONS(6) : précision (10e-8 par défaut).
dp=0.001;
for i=1:nbdecompo
    d=cible(i,:)'-pos;
    for j=1:10
        J=calc_jacobian_numerique('fcine_numerique_H2',etatc',dp,6,Fem1g,Fem6g,Tal1g,Fem1d,Fem6d,Tal1d,R_monde_local, R_Pelvis_monde, R_LFem_ref_local, R_LTib_ref_local, R_RFem_ref_local, R_RTib_ref_local);
        Jp=pinv(J);
        % tache secondaire : minimisation des angles de rotation interne/externe et abduction/adduction
        proj=eye(11,11)-Jp*J;
        % calcul de la solution finale
        delta1=(Jp*d);
        delta2=ones(11,1)*0.1;
%  delta2=MDS('eval_secondaire',delta2,options,etatc,proj,butemin,butemax,delta1,etat0,60,1.70);
%  delta2=MDS('eval_secondaire',delta2,options,etatc,proj,butemin,butemax,delta1,etat0,60,1.70);
%  [cuissegc,tibiagc,cuissedc,tibiadc]=calcul_COG_locaux(etatc);
%  delta2=MDS('eval_secondaire',delta2,options,etatc,proj,butemin,butemax,delta1,etat0,60,1.70);%,cuissegc,tibiagc,cuissedc,tibiadc);
%  delta2=MDS('eval_secondaire2',delta2,options,etatc,proj,butemin,butemax,delta1,etat0,60);%,cuissegc,tibiagc,cuissedc,tibiadc);
        delta2=MDS('eval_secondaire3',delta2,options,etatc,proj,butemin,butemax,delta1,etat0,60,Fem1g,Fem6g,Fem1d,Fem6d);  %,cuissegc,tibiagc,cuissedc,tibiadc);

        etatc = etatc+delta1'+(proj*delta2)';
        d=zeros(6,1);
    end;
    pos=fcine_numerique_H(etatc,Fem1g,Fem6g,Tal1g,Fem1d,Fem6d,Tal1d);
end;
etat=etatc;

