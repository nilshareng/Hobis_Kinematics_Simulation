<<<<<<< Updated upstream:Functions/Data Acquisition - Processing/GenPresetFromc3d.m
function [] = GenPresetFromc3d(SavePath, c3dPath, XlsxFilePath)
% Fonctionnement :
%Unused 
%

% Entr�e :
%
%

% Sortie :
%
%




% From c3d files to :
% - Gait trajectory
% - Articular Trajectories
% - Markers positions
% - Reperes (Coordinate systems)
% - Footprints 


cd(c3dPath);
[BornesMarche, Names] = xlsread(XlsxFilePath,'A2:D78');

for ii=1:11:length(Names)
    
    % Cr�ation d'un dossier pour cette marche - l� o� vont �tre stock�es toutes les donn�es calcul�es
%     dirname= strcat(SavePath,Names{ii});
%     mkdir(dirname);
    
    % Bornes = Frames D�but/Fin cycle de marche. Diff�rence avec la frame initiale pour l'initialisation  
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
    b= fieldnames(premarkers);
    for j = 3:size(b,1)
        tempName = b{j};
        tempName = tempName(end-3:end);
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

Period = 100;
%         [Dmarkers, DParam ]= HobisDataParser(DataDes);
% [Rmarkers, RParam ] = HobisDataParser(DataRef);
%         [DReperes DSeq NDmarkers NDParam] = ReperesFromMarkers(Dmarkers);
[RReperes, ~, ~, ~] = ReperesFromMarkersCorrected(Rmarkers);
A = zeros(1,11);

Sequence.Pelvis = 'xyz';
Sequence.LHip = 'zyx';
Sequence.LKnee = 'z';
Sequence.RHip = 'zyx';
Sequence.RKnee = 'z';

[PosC,Markers,Reperes] = fcinematique([0 0 0 0 0 0 0 0 0 0 0], Sequence, Rmarkers, RReperes);

end

=======
function [] = GenPresetFromc3d(SavePath, c3dPath, XlsxFilePath)
% Fonctionnement :
%Unused 
%

% Entr�e :
%
%

% Sortie :
%
%




% From c3d files to :
% - Gait trajectory
% - Articular Trajectories
% - Markers positions
% - Reperes (Coordinate systems)
% - Footprints 


cd(c3dPath);
[BornesMarche, Names] = xlsread(XlsxFilePath,'A2:D78');

for ii=1:11:length(Names)
    
    % Cr�ation d'un dossier pour cette marche - l� o� vont �tre stock�es toutes les donn�es calcul�es
%     dirname= strcat(SavePath,Names{ii});
%     mkdir(dirname);
    
    % Bornes = Frames D�but/Fin cycle de marche. Diff�rence avec la frame initiale pour l'initialisation  
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
    b= fieldnames(premarkers);
    for j = 3:size(b,1)
        tempName = b{j};
        tempName = tempName(end-3:end);
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

Period = 100;
%         [Dmarkers, DParam ]= HobisDataParser(DataDes);
% [Rmarkers, RParam ] = HobisDataParser(DataRef);
%         [DReperes DSeq NDmarkers NDParam] = ReperesFromMarkers(Dmarkers);
[RReperes, ~, ~, ~] = ReperesFromMarkersCorrected(Rmarkers);
A = zeros(1,11);

Sequence.Pelvis = 'xyz';
Sequence.LHip = 'zyx';
Sequence.LKnee = 'z';
Sequence.RHip = 'zyx';
Sequence.RKnee = 'z';

[PosC,Markers,Reperes] = fcinematique([0 0 0 0 0 0 0 0 0 0 0], Sequence, Rmarkers, RReperes);

end

>>>>>>> Stashed changes:Functions/GenPresetFromc3d.m
