function res=rotateAndCenter(traj,centre,matrice)
% fonction qui recentre le marqueur traj par rapport à centre et qui le
% multiplie par la matrice pour le ramener dans un repère donné
res=traj-centre; 
for i=1:size(res,1)
    temp=matrice*res(i,:)';
    res(i,:)=temp';
end;
