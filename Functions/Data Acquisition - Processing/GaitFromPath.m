function [Data] = GaitFromPath(InitialGaitPath)
% Fonctionnement :
% 
%

% Entrée :
% Chemin d'un fichier de mocap (relatif ou absol
%

% Sortie :
%
%



Data = struct;

switch InitialGaitPath(:,end-2:end)
    case 'mat' 
        % A preset was chosen as the initial Gait. Ergo :
        % - There is a set of prints available
        
        Data = load(strcat(InitialGaitPath));
        
%         PolX = Pol;
        if exist('X')
            PresetPrints = X;
        else
            PresetPrints = 'No Presets';
        end
        
        a= [];
        b = RotationZ(pi/2);
        for i = 1:size(Data.OGait,1)
            a = [a; [Data.OGait(i,1:3)*b(1:3,1:3), Data.OGait(i,4:6)*b(1:3,1:3)]];
        end
        Data.ROGait = a;
        
    case 'txt'
%         InputX = X;
        InitialGait = load(strcat(InitialGaitPath));
        
        if size(InitialGait,2) == 7
            InitialGait = InitialGait(:,2:end);
        elseif size(InitialGait,2) == 3
            InitialGait = [InitialGait,  InitialGait];
            InitialGait(:,4:6) = [InitialGait];
        end
        
        OPN = InitialGait;
        X = FindFootprints(OPN);
        
        Data.Gait = OPN;
        Data.X = X;
        
        % Spline Approx of Initial Gait
        Period = max(size(InitialGait));
        midPeriod = fix((Period)/2);
        
        Data.SampleFreq = Period;
        
        SplinedPoulaine = [];
        for i = 1:3
            SplinedPoulaine(:,i) = Curve2Spline(InitialGait(:,i));
        end
        % Symetrisation
        SplinedPoulaine = GaitSymetrisation(SplinedPoulaine);
        
        % Attribution
        
        Data.SplinedGait = SplinedPoulaine;
        
        model.gait = SplinedPoulaine;
        PN = SplinedPoulaine;
        XPoulaineInScaled = FindFootprints(PN);
        
        Data.XSplined = XPoulaineInScaled;
        Data.ROGait= InitialGait;
        
end
end


