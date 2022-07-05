function [C3DKinModel] = Loadc3dKinModel(BDDPath,FileName,XLSXName)
% Fonctionnement :
% 
% 

% Entr�e :
% 
% 

% Sortie :
% 
% 

[BornesMarche, Names] = xlsread(strcat(BDDPath,XLSXName),'A2:D78');

ii = find(strcmp(Names,FileName));
p = BDDPath;
Bornes=[BornesMarche(ii,1)-BornesMarche(ii,3) BornesMarche(ii,2)-BornesMarche(ii,3)];

% Taille de l'�chantillon de frames � s�lectionner
Period = Bornes(2)-Bornes(1)+1;

% Structure contenant les positions de marqueurs
markers=struct;

% Acquisition des marqueurs � partir des .c3d en 2�tapes
% 1 - Acquisition
TN{ii}=strcat(Names{ii},'.c3d');
NewFile = strcat(p,TN{ii});
a = btkReadAcquisition(NewFile);
premarkers = btkGetMarkers(a);
Tmp = struct2cell(premarkers);
b = fieldnames(premarkers);
for j = 3:size(b,1)
    tempName = b{j};
    if size(tempName,2) > 4
        tempName = tempName(end-3:end);
    end
    
    switch tempName
        case 'RFWT'
            markers.RFWT = Tmp{j};
        case 'LFWT'
            markers.LFWT = Tmp{j};
        case 'RBWT'
            markers.RBWT = Tmp{j};
        case 'LBWT'
            markers.LBWT = Tmp{j};
        case 'LKNE'
            markers.LKNE = Tmp{j};
        case 'RKNE'
            markers.RKNE = Tmp{j};
        case 'LKNI'
            markers.LKNI = Tmp{j};
        case 'RKNI'
            markers.RKNI = Tmp{j};
        case 'LANE'
            markers.LANE = Tmp{j};
        case 'RANE'
            markers.RANE = Tmp{j};
        case 'LANI'
            markers.LANI = Tmp{j};
        case 'RANI'
            markers.RANI = Tmp{j};
    end
    
    
    
end