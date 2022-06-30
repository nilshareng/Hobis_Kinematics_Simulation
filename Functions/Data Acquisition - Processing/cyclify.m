function res=cyclify(traj,delta)
% fonction qui cyclifie la trajectoire mise en paramètres, en supposant que
% traje contient un signal à peu près périodique théoriquement, et au moins
% 5 frames plus long que le cycle
% hypothèse le signal composé de N colonnes de n lignes (le temps)
% delta est le nombre de frames max de décalage

% si le signal n'est pas en colonnes, prendre la transposée 
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

% maintenant rendre le mouvement parfaitement cyclique en éliminant la
% dérive : ajout d'une rampe qui part du début et qui va jusqu'à la fin
% pour compenser l'erreur finale entre première et dernière image
diff=-(res(end,:)-res(1,:)); 
for i=1:size(res,2)
    temp=diff(i)*(0:size(res,1)-1)/size(res,1);
    rampe(:,i)=temp';     
end;
res=res+rampe; 

