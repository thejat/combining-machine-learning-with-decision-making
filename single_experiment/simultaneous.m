%Simultaneous Process described in the ML&TRP Paper.

clc;
close all;
clear all;
format short;


%% Options
simultaneous_nm = 0;
simultaneous_am = 1;


%% Global Variables

%Globals for simutaneous_nm
global routeCostT2 routeInfo C1 nm_iterationCount; %Things which get updated by gurobiIterative.m
global C numUnlabeled unLabeled numFeatures C0  C2 trainingdata numTrain costVersion; %Parameters for gurobiIterative.m

%Additional Globals for simultaneous_am
global Lambda_T gurobilatency iterate_j indexIteration prevGurobioutput permutG indexErr;


%% Step 1: Loading training and validation/test data.
datafolderprefix = '../data/';
previous_config=0; %Previous runs were doing different normalization to train and test.
load([datafolderprefix 'trainAndTestFull.mat']);
if previous_config==1
    varXTest = var(xTest_o);
    xTest_o = (xTest_o - repmat(mean(xTest_o),23217,1))./repmat(sqrt(varXTest),23217,1);
    varXTrain = var(xTrain_o);
    xTrain_o = (xTrain_o - repmat(mean(xTrain_o),23217,1))./repmat(sqrt(varXTrain),23217,1);
else
    varXTrain = var(xTrain_o);
    xTrain_o = (xTrain_o - repmat(mean(xTrain_o),23217,1))./repmat(sqrt(varXTrain),23217,1);
    xTest_o = (xTest_o - repmat(mean(xTrain_o),23217,1))./repmat(sqrt(varXTrain),23217,1);
end
numFeatures             = length(xTest_o(1,:));
numTrain                = length(xTest_o(:,1));
testdata                = [xTest_o yTest_o];        %For validation Only.
trainingdata            = [xTrain_o(1:numTrain,:) yTrain_o(1:numTrain)];

%% Parameters for simulation
C0 = 1; C1 = 1; C2 = 0.1;   %Default coefficients of each of the terms in OBJ.

%C1arr = [0.005 0.01 0.05 0.1 0.5 1]; %Perfect for 7 node data for Model 1.
%C1arr = [0.005 0.05  0.1 0.2 0.5 1]; %Perfect for 7 node data and Model 2.
C1arr = [0.85];

costVersion  = 2; % values: 1 or 2 corresponding to Cost 1 and Cost 2 in paper.
decisionDataSize = 7; % 6,7,8,10 for that number of node dataset.


if      (decisionDataSize == 6)
    load([datafolderprefix 'SixNodeData.mat']);
elseif  (decisionDataSize == 7)
    load([datafolderprefix 'SevenNodeData.mat']);
elseif  (decisionDataSize == 8)
    load([datafolderprefix 'EightNodeData.mat']);
elseif  (decisionDataSize == 10)
    load([datafolderprefix 'TenNodeData.mat']);
end

%% NM+MILP: Via Fminsearch+Gurobi.
if(simultaneous_nm==1)
    for iterate_j=1:length(C1arr)
        C1 = C1arr(iterate_j);
        nm_iterationCount = 0;
        opts_fminsearch = optimset('display','off','TolFun',1e-6, 'MaxIter', 5000,'MaxFunEvals',10000, 'TolX',1e-6);
        tic
        [Lambda_Alternating,fval_Alternating,exitflag,output_Alternating] = fminsearch(@gurobiIterative,zeros(numFeatures+1,1),opts_fminsearch);
        timeC1_alt(iterate_j) = toc;
        display(['Found optimal route for C1 = ' num2str(C1) ' in ' num2str(timeC1_alt(iterate_j)) ' seconds for Cost ' int2str(costVersion) '. IterationIndex is ' num2str(nm_iterationCount)]);

        %Collecting outputs
        LambdaC1_alt(:,iterate_j)       = Lambda_Alternating;%          LOCAL
        fvalC1_Alternating(:,iterate_j) = fval_Alternating;%            LOCAL
        routeinfoC1{iterate_j}          = routeInfo;   %               GLOBAL
        routeCostT2C1(iterate_j)        = routeCostT2; % unnormalized. GLOBAL
    end
    %   save(strcat(['result_nm_matlab_workspace_Feb7_' int2str(costVersion) '_' int2str(decisionDataSize) '_summary.mat']));
end

%% AM+MILP: Via Fminsearch+Gurobi
    %Alternating minimization
    % lambda(t+1) = min over lambda (total obj given a permutation pi(t))
    % pi(t+1) = min over permutation space given a lambda lambda(t+1)
if(simultaneous_am==1)
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
end