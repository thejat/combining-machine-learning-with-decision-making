%Simultaneous Process described in the ML&TRP Paper.

clc; close all; clear all;




%% AM+MILP: Via Fminsearch+Gurobi
    %Alternating minimization
    % lambda(t+1) = min over lambda (total obj given a permutation pi(t))
    % pi(t+1) = min over permutation space given a lambda lambda(t+1)
simultaneous_am = 1;
%Additional Globals for simultaneous_am
global Lambda_T gurobilatency iterate_j indexIteration prevGurobioutput permutG indexErr;

gurobilatency = zeros(numUnlabeled, 1);
for iterate_j=1:length(C1arr)
    C1          = C1arr(iterate_j);
    opts_AM     = optimset('display','off','TolFun',1e-6, 'MaxIter', 5000,'MaxFunEvals',10000, 'TolX',1e-6);
    MaxIter     = 25;
    Lambda_T    = zeros(numFeatures+1,1);
    prevGurobioutput = [zeros(numUnlabeled-1,1) eye(numUnlabeled-1,numUnlabeled-1); 1 zeros(1,numUnlabeled-1)];
    indexErr    = 0;

    tic
    for indexIteration=1:MaxIter
        [Lambda_T,fval_AM,exitflag,output_AM] = fminsearch(@am_lambda,Lambda_T,opts_AM);
        [gurobilatency,fval_GAM] = am_gurobi(Lambda_T);

        routeCostIterationT1T3(indexIteration) = fval_AM;
        LambdaIteration(:,indexIteration) = Lambda_T;

        display(['IterationIndex:' num2str(indexIteration) ' Lambda_T:' num2str(Lambda_T') ' perm:' int2str(permutG)]);
        if((indexIteration>1) & (abs(fval_GAM-routeCostT2(indexIteration-1))<= 10^-4))
            display('Stopped AM because of successive difference being small.');
             break;
         elseif (indexErr>MaxIter/5)
             routeCostT2(indexIteration) = routeCostT2(indexIteration-1);
             display('Stopped AM because indexErr was greater than MaxIter/5!');
             break;
         end
    end
    timeC1_AM(iterate_j) = toc;

    iterationCount(iterate_j)   = indexIteration;
    LambdaC1_AM(:,iterate_j)    = Lambda_T;
    fvalC1_AM(:,iterate_j)      = fval_AM;
    routeinfoAM_C1{iterate_j}   = routeInfo; %{indexIteration};
    routeCostAM_T2C1(iterate_j) = routeCostT2(indexIteration);
    %save(strcat(['result_AM_matlab_workspace_Feb7_Alternate_' int2str(costVersion) '_' int2str(decisionDataSize) '_' int2str(iterate_j) '.mat']));
end % End of for loop over C1arr for AM+MILP
%   save(strcat(['result_AM_mat_Feb7_' int2str(costVersion) '_' int2str(theja2sims) '_summary.mat']));
