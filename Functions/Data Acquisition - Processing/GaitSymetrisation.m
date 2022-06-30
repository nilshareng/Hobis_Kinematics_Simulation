function SymCurves = GaitSymetrisation(Curves)
% Fonctionnement :
%
%

% Entrée :
%
%

% Sortie :
%
%




% Symmetricalisation of gait curves, for ankles traj and angular traj
% Ankle traj : 2*3 DoF 
% Angular Traj : 11 DoF, 3 + 2*4 
SymCurves = [];
switch size(Curves,2)
    
    case {3, 6} % Ankles, phase opposition for X, Y and Z ; Amp opposition for X 
        mid = fix(size(Curves,1)/2);
        SymCurves = [Curves(:,1:3), Curves(:,1:3)];
        SymCurves(:,4) = -1*[SymCurves(mid+1:end,1) ; SymCurves(1:mid,1)];
        SymCurves(:,5) = [SymCurves(mid+1:end,2) ; SymCurves(1:mid,2)];
        SymCurves(:,6) = [SymCurves(mid+1:end,3) ; SymCurves(1:mid,3)];
                        
    case {11} % TA
        mid = fix(size(Curves,1)/2);
        
%         Curves(:,1:3) = Curves(:,1:3) - mean(Curves(:,1:3));
        
        if 1%(max(Curves(:,7))-min(Curves(:,7))) > (max(Curves(:,11)) - min(Curves(:,11)))
            SymCurves = [Curves(:,1:7) , Curves(:,4:7)];
            SymCurves(:,8) = -1*[SymCurves(mid+1:end,8) ; SymCurves(1:mid,8)];
            SymCurves(:,9) = -1*[SymCurves(mid+1:end,9) ; SymCurves(1:mid,9)];
            SymCurves(:,10) = [SymCurves(mid+1:end,10) ; SymCurves(1:mid,10)];
            SymCurves(:,11) = [SymCurves(mid+1:end,11) ; SymCurves(1:mid,11)];
        else
            SymCurves = [Curves(:,1:3), Curves(:,8:11) , Curves(:,8:11)];
            SymCurves(:,4) = -1*[SymCurves(mid+1:end,4) ; SymCurves(1:mid,4)];
            SymCurves(:,5) = -1*[SymCurves(mid+1:end,5) ; SymCurves(1:mid,5)];
            SymCurves(:,6) = [SymCurves(mid+1:end,6) ; SymCurves(1:mid,6)];
            SymCurves(:,7) = [SymCurves(mid+1:end,7) ; SymCurves(1:mid,7)];
        end
        
    case {7} % TA Pols
        if(size(Curves,1)==26)
            SymCurves = Curves;
            SymCurves(Curves(:,1)==8,2:3) = Curves(Curves(:,1)==4,2:3)+0.5;
            SymCurves(Curves(:,1)==9,2:3) = Curves(Curves(:,1)==5,2:3)+0.5;
            SymCurves(Curves(:,1)==10,2:3) = Curves(Curves(:,1)==6,2:3)+0.5;
%             SymCurves(Curves(:,1)==11,2:3) = Curves(Curves(:,1)==7,2:3)+0.5;
            
%             SymCurves(Curves(:,1)==8,4:7) = -1*Curves(Curves(:,1)==4,4:7);
%             SymCurves(Curves(:,1)==9,4:7) = -1*Curves(Curves(:,1)==5,4:7);
            SymCurves(Curves(:,1)==8,4:7) = -1*Curves(Curves(:,1)==4,4:7);
            SymCurves(Curves(:,1)==9,4:7) = -1*Curves(Curves(:,1)==5,4:7);
%             SymCurves(Curves(:,1)==10,4:7) = -1*Curves(Curves(:,1)==6,4:7);
%             SymCurves(Curves(:,1)==11,4:7) = -1*Curves(Curves(:,1)==7,4:7);
            SymCurves(Curves(:,1)==10,4:7) = Curves(Curves(:,1)==10,4:7);
%             SymCurves(Curves(:,1)==11,4:7) = Curves(Curves(:,1)==11,4:7);
            
            NewCurve = [];
            for i =1:60
                tmp=zeros(1,11);
                for j=1:11
                    tmp(j) = EvalSpline(SymCurves(SymCurves(:,1)==j,:),((i-1))/60);
                end
                NewCurve = [NewCurve ; tmp];
            end
           
            NewCurve(1:3,:) = NewCurve(1:3,:) - mean(NewCurve(1:3,:));
            PCA = ForgePCA(NewCurve,0:1/(size(NewCurve,1)-1):1 ,1 );
            PolA = [];
            for i =1:PCA(end,1)
                PolA = [PolA ; PC_to_spline(PCA(PCA(:,1)==i,2:3),1)];
            end
            PolA(:,1) = PCA(:,1);
            
            SymCurves(SymCurves(:,1)==1,:) = PolA(PolA(:,1)==1,:);
            SymCurves(SymCurves(:,1)==2,:) = PolA(PolA(:,1)==2,:);
            SymCurves(SymCurves(:,1)==3,:) = PolA(PolA(:,1)==3,:);
            
            
%             for i = 1:4
%                 tmp = SymCurves(Curves(:,1)==(7+i),2);
%                 tmp(SymCurves(Curves(:,1)==(7+i),2)>1) = tmp(SymCurves(Curves(:,1)==(7+i),2)>1) -1;
%                 [~,b] = sort(tmp);
%                 SymCurves(Curves(:,1)==(7+i),1:3) = tmp;
%                 TMP = SymCurves(Curves(:,1)==(7+i),2:end);
%                 SymCurves(Curves(:,1)==(7+i),2:end) = TMP(b,:);
%             end
            
        else
            mid = fix(size(Curves,1)/2);
            SymCurves = [Curves(:,1:7) , Curves(:,4:7)];
            SymCurves(:,8) = -1*[SymCurves(mid+1:end,8) ; SymCurves(1:mid,8)];
            SymCurves(:,9) = -1*[SymCurves(mid+1:end,9) ; SymCurves(1:mid,9)];
            SymCurves(:,10) = [SymCurves(mid+1:end,10) ; SymCurves(1:mid,10)];
            SymCurves(:,11) = [SymCurves(mid+1:end,11) ; SymCurves(1:mid,11)];
        end
end

