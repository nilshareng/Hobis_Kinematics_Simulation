function res=cyclify(traj,delta)
% fonction qui cyclifie la trajectoire mise en param�tres, en supposant que
% traje contient un signal � peu pr�s p�riodique th�oriquement, et au moins
% 5 frames plus long que le cycle
% hypoth�se le signal compos� de N colonnes de n lignes (le temps)
% delta est le nombre de frames max de d�calage

% si le signal n'est pas en colonnes, prendre la transpos�e 
if (size(traj,1)<size(traj,2)) 
    traj=traj';
end;
n=size(traj,1); 

c=[];
for i=5:delta
    c=[c corr(traj(1:i,1),traj(end-i+1:end,1))];
end;
indice=find(c==max(c))+4;
res=traj(1:end-indice+1,:);

% maintenant rendre le mouvement parfaitement cyclique en �liminant la
% d�rive : ajout d'une rampe qui part du d�but et qui va jusqu'� la fin
% pour compenser l'erreur finale entre premi�re et derni�re image
diff=-(res(end,:)-res(1,:)); 
for i=1:size(res,2)
    temp=diff(i)*(0:size(res,1)-1)/size(res,1);
    rampe(:,i)=temp';     
end;
res=res+rampe; 

