function [NPCA,NPolA,Jk, Jkp, V, DJerk, DAC, Log] = JacSingularitiesCheck( NPCA, NPolA, X,dp,M,Cost,JerkRef,ACRef, Period, Sequence, Markers, Reperes, InvE, mid, Threshold, PCA, c, Cflag, rate, model, tmpP2, tmpTA2,Log, SC, Jk, Jkp)
% checking jacobians for singularities / rank decreases
        
        SC = SC+1;
        
        Log.OptiCycleShitCounter(SC).JacSng = c;
        Log.OptiCycleShitCounter(SC).JacSngPC = NPCA;
        Log.OptiCycleShitCounter(SC).JacSngPol = NPolA;
        Log.OptiCycleShitCounter(SC).JacSngPoul = tmpP2;
        Log.OptiCycleShitCounter(SC).CycleJacSngTA = tmpTA2;

        PushCounter = 0;

        while norm(Jk) > 10^3 || norm(Jkp) > 10^3 
            push = [0.01 * ones(size(NPCA(:,1))) , 0.01 * ones(size(NPCA(:,1)))];
            
            [TNPCA,TNPolA] = ModifPCA(push, NPCA, Period, Sequence, Markers, Reperes, InvE, mid, Threshold, PCA, c, Cflag, rate);
            [Jk, V, DJerk, DAC] = calc_jacobien_PC_4D(TNPCA, TNPolA,X,dp,M,Cost,JerkRef,ACRef,Rmarkers,RReperes,Sequence,Inertie, model.jointRangesMin, model.jointRangesMax);
            
            PushCounter = PushCounter +1;
            
        end
        
        Log.OptiCycleShitCounter(SC).JacSngPushCounter = PushCounter; 
end

