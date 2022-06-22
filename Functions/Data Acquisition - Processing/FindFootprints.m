<<<<<<< Updated upstream
function Footprints = FindFootprints(Poulaine)
% Détermination des "Empreintes" de pas à partir d'une poulaine
% (trajectoire de cheville). 
% Les empreintes sont 3 points correspondant respectivement aux minimum en 
% Z (vertical) et min/max en Y (longitudinal) de la poulaine d'entrée.
% Les empreintes à gauche sont générées par symétrie par rapport à celles
% de droite.

% Entrées : 
% 'Poulaine' array N*3 ou N*6 trajectoire de cheville sur un cycle de N
% frames, Poulaine(:,1:3) considéré comme coordonnées de la cheville droite

% Sorties : 
% 'Footprints' array 6*5 avec :
% - Col 1 scorie inutile, à ignorer
% - Col 2 Coordonnée temporelle de l'empreinte en %du cycle de marche
% - Col 3-5 Coordonnées spatiales de l'empreinte

Poul = Poulaine(:,1:3);
S = size(Poulaine,1);
Footprints = zeros(6,5);

% Empreintes déterminées comme minimum en Z (vertical) et min/max Y
% (longitudinal)
[~,b1] = min(Poul(:,3));
[~,b2] = min(Poul(:,2));
[~,b3] = max(Poul(:,2));

% Coordonnées des empreintes 
Footprints(1,3:5) = Poul(b1,1:3);
Footprints(2,3:5) = Poul(b2,1:3);
Footprints(3,3:5) = Poul(b3,1:3);

% Coordonnées temporelles des empreintes (en %du cycle de marche)
Footprints(1,2) = b1/(S-1);
Footprints(2,2) = b2/(S-1);
Footprints(3,2) = b3/(S-1);

% Création et symétrisation des empreintes gauches à partir des empreintes
% droites.
Footprints = [Footprints(1:3,2:5) ; Footprints(1:3,2:5)]; 
Footprints(Footprints(:,1)<=0,1) = 1+ Footprints(Footprints(:,1)<=0,1);
Footprints(4:6,:) = [Footprints(4:6,1) + 0.5 , Footprints(4:6,2)*-1 , Footprints(4:6,3:4)];
Footprints(Footprints(1:6,1)>1,1) = Footprints(Footprints(1:6,1)>1,1) -1;
Footprints = [[2;2;3;5;5;6] , Footprints];

end

=======
function Footprints = FindFootprints(Poulaine)
% Détermination des "Empreintes" de pas à partir d'une poulaine
% (trajectoire de cheville). 
% Les empreintes sont 3 points correspondant respectivement aux minimum en 
% Z (vertical) et min/max en Y (longitudinal) de la poulaine d'entrée.
% Les empreintes à gauche sont générées par symétrie par rapport à celles
% de droite.

% Entrées : 
% 'Poulaine' array N*3 ou N*6 trajectoire de cheville sur un cycle de N
% frames, Poulaine(:,1:3) considéré comme coordonnées de la cheville droite

% Sorties : 
% 'Footprints' array 6*5 avec :
% - Col 1 scorie inutile, à ignorer
% - Col 2 Coordonnée temporelle de l'empreinte en %du cycle de marche
% - Col 3-5 Coordonnées spatiales de l'empreinte

Poul = Poulaine(:,1:3);
S = size(Poulaine,1);
Footprints = zeros(6,5);

% Empreintes déterminées comme minimum en Z (vertical) et min/max Y
% (longitudinal)
[~,b1] = min(Poul(:,3));
[~,b2] = min(Poul(:,2));
[~,b3] = max(Poul(:,2));

% Coordonnées des empreintes 
Footprints(1,3:5) = Poul(b1,1:3);
Footprints(2,3:5) = Poul(b2,1:3);
Footprints(3,3:5) = Poul(b3,1:3);

% Coordonnées temporelles des empreintes (en %du cycle de marche)
Footprints(1,2) = b1/(S-1);
Footprints(2,2) = b2/(S-1);
Footprints(3,2) = b3/(S-1);

% Création et symétrisation des empreintes gauches à partir des empreintes
% droites.
Footprints = [Footprints(1:3,2:5) ; Footprints(1:3,2:5)]; 
Footprints(Footprints(:,1)<=0,1) = 1+ Footprints(Footprints(:,1)<=0,1);
Footprints(4:6,:) = [Footprints(4:6,1) + 0.5 , Footprints(4:6,2)*-1 , Footprints(4:6,3:4)];
Footprints(Footprints(1:6,1)>1,1) = Footprints(Footprints(1:6,1)>1,1) -1;
Footprints = [[2;2;3;5;5;6] , Footprints];

end

>>>>>>> Stashed changes
