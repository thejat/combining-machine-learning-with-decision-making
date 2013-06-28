%ONly does NM+Gurobi
clc;
close all;
clear all;
format short;

global routeCostT2 routeInfo C1 nm_iterationCount; %Things which get updated by gurobiIterative.m
global C numUnlabeled unLabeled numFeatures C0  C2 trainingdata numTrain costVersion; %Parameters for gurobiIterative.m

%% Step 1: Loading training and validation/test data.
datafolderprefix = '../../../data/';
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
decisionDataSize = 6; % 6,7,8,10 for that number of node dataset.


if      (decisionDataSize == 6)
    load([datafolderprefix 'SixNodeData.mat']);
elseif  (decisionDataSize == 7)
    load([datafolderprefix 'SevenNodeData.mat']);
elseif  (decisionDataSize == 8)
    load([datafolderprefix 'EightNodeData.mat']);
elseif  (decisionDataSize == 10)
    load([datafolderprefix 'TenNodeData.mat']);
end

iterate_i=0;iterate_j=0;iterate_k=0;

%% NM+MILP: Via Fminsearch+Gurobi.
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