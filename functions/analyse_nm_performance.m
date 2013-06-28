% analyze nm performance.
%can also analysize AM performance! :) 2011-02-07
clear all
close all
clc

%load ./best_results_feb7/result_nm_matlab_workspace_Feb7_2_7_summary.mat
%load ./result_nm_matlab_workspace_Feb7_2_7_summary.mat

load ./correctionPt/result_AM_mat_Feb7_2_7_summary.mat
LambdaC1_alt = LambdaC1_AM;

%Step 1: Loading training and validation/test data.

load('../data/trainAndTestFull.mat');
varXTest = var(xTest_o);
xTest_o = (xTest_o - repmat(mean(xTest_o),23217,1))./repmat(sqrt(varXTest),23217,1);
varXTrain = var(xTrain_o);
xTrain_o = (xTrain_o - repmat(mean(xTrain_o),23217,1))./repmat(sqrt(varXTrain),23217,1);
numFeatures             = 4;
numTrain                = 23217;
testdata                = [xTest_o yTest_o];        %For validation Only.
trainingdata            = [xTrain_o(1:numTrain,:) yTrain_o(1:numTrain)];
%preprocessing to alleviate the probability values.
% index_train_preprocess1 = find(trainingdata(:,4) > 10);
% numTrain                = length(index_train_preprocess1);
% trainingdata            = trainingdata(index_train_preprocess1,:);


%SAME COPIED FROM MAIN.

addpath(genpath('./misc_files'));

iterate_i = 1;

for iterate_i=1:size(LambdaC1_alt,2)


    nm_functionValTest(:,iterate_i) = xTest_o(:,1:numFeatures)*LambdaC1_alt(1:numFeatures,iterate_i) + LambdaC1_alt(end,iterate_i);
    rocInput = [nm_functionValTest(:,iterate_i) 0.5*(yTest_o+1)];
    dm_2steptemp = rocT(rocInput);%no display of roc curve = 0
    rocdataTestFull(:,iterate_i) = [dm_2steptemp.AUC dm_2steptemp.SE];
    clear dm_2steptemp rocInput;

    nm_functionValTrain(:,iterate_i) = trainingdata(:,1:numFeatures)*LambdaC1_alt(1:numFeatures,iterate_i) + LambdaC1_alt(end,iterate_i);
    rocInput = [nm_functionValTrain(:,iterate_i) 0.5*(trainingdata(:,end)+1)];
    dm_2steptemp = rocT(rocInput);%no display of roc curve = 0
    rocdataTrain(:,iterate_i) = [dm_2steptemp.AUC dm_2steptemp.SE];
    clear dm_2steptemp rocInput;

%     nm_functionValTrainFull(:,iterate_i) = xTrain_o(:,1:numFeatures)*LambdaC1_alt(1:numFeatures,iterate_i) + LambdaC1_alt(end,iterate_i);
%     rocInput = [nm_functionValTrainFull(:,iterate_i) 0.5*(yTrain_o+1)];
%     dm_2steptemp = rocT(rocInput);%no display of roc curve = 0
%     rocdataTrainFull(:,iterate_i) = [dm_2steptemp.AUC dm_2steptemp.SE];
%     clear dm_2steptemp rocInput;
end

% am_7nd_m1_auc_test = rocdataTestFull
% am_7nd_m1_auc_train = rocdataTrain
% am_7nd_m1_lambda = LambdaC1_alt;
% am_7nd_m1_C1arr = C1arr;
% am_7nd_m1_lossT1T3_C1 = fvalC1_AM - C1arr.*routeCostAM_T2C1;
% am_7nd_m1_lossT2nomultC1 = routeCostAM_T2C1;
% save am_7nd_m1.mat am_7nd_m1_auc_test am_7nd_m1_auc_train am_7nd_m1_C1arr am_7nd_m1_lambda am_7nd_m1_lossT1T3_C1 am_7nd_m1_lossT2nomultC1;

% IterationIndex:1 Lambda_T:0  0  0  0 -5 perm:1  5  3  4  2  6  7  1   
% IterationIndex:2 Lambda_T:0  0  0  0 -5 perm:1  5  3  4  2  6  7  1
% IterationIndex:3 Lambda_T:0  0  0  0 -5 perm:1  5  3  4  2  6  7  1
% Broke because of successive difference being small.
% 1_7_1
% IterationIndex:1 Lambda_T:0  0  0  0 -5 perm:1  5  3  4  2  6  7  1
% IterationIndex:2 Lambda_T:0  0  0  0 -5 perm:1  5  3  4  2  6  7  1
% Broke because of successive difference being small.
% 2_7_1
% IterationIndex:1 Lambda_T:0  0  0  0 -5 perm:1  5  3  4  2  6  7  1
% IterationIndex:2 Lambda_T:0  0  0  0 -5 perm:1  5  3  4  2  6  7  1
% Broke because of successive difference being small.
% 3_7_1
% IterationIndex:1 Lambda_T:0  0  0  0 -5 perm:1  5  3  4  2  6  7  1
% IterationIndex:2 Lambda_T:0  0  0  0 -5 perm:1  5  3  4  2  6  7  1
% Broke because of successive difference being small.
% 4_7_1
% IterationIndex:1 Lambda_T:0  0  0  0 -5 perm:1  5  3  4  2  6  7  1
% IterationIndex:2 Lambda_T:0  0  0  0 -5 perm:1  5  3  4  2  6  7  1
% Broke because of successive difference being small.
% 5_7_1
% IterationIndex:1 Lambda_T:0  0  0  0 -5 perm:1  5  3  4  2  6  7  1
% IterationIndex:2 Lambda_T:0  0  0 -0 -5 perm:1  6  7  3  2  1  6  7
% IterationIndex:3 Lambda_T:0  0  0  0 -5 perm:1  6  7  3  2  1  6  7
% IterationIndex:4 Lambda_T:0  0  0 -0 -5 perm:1  6  2  3  7  1  6  2
% IterationIndex:5 Lambda_T:0  0  0  0 -5 perm:1  6  2  3  7  1  6  2
% IterationIndex:6 Lambda_T:0  0  0 -0 -5 perm:1  6  7  5  3  4  2  1
% IterationIndex:7 Lambda_T:0  0  0  0 -5 perm:1  6  7  5  3  4  2  1
% IterationIndex:8 Lambda_T:0  0  0 -0 -5 perm:1  6  7  3  2  1  6  7
% IterationIndex:9 Lambda_T:0  0  0  0 -5 perm:1  6  7  3  2  1  6  7
% IterationIndex:10 Lambda_T:0  0  0 -0 -5 perm:1  6  7  3  2  1  6  7
% IterationIndex:11 Lambda_T:0  0  0  0 -5 perm:1  6  7  3  2  1  6  7
% Broke because indexErr was greater than MaxIter/5!
% 6_7_1



% am_7nd_m2_auc_test = rocdataTestFull
% am_7nd_m2_auc_train = rocdataTrain
% am_7nd_m2_lambda = LambdaC1_alt;
% am_7nd_m2_C1arr = C1arr;
% am_7nd_m2_lossT1T3_C1 = fvalC1_AM - C1arr.*routeCostAM_T2C1;
% am_7nd_m2_lossT2nomultC1 = routeCostAM_T2C1;
% save am_7nd_m2.mat ...
%     am_7nd_m2_auc_test ...
%     am_7nd_m2_auc_train ...
%     am_7nd_m2_C1arr ...
%     am_7nd_m2_lambda ...
%     am_7nd_m2_lossT1T3_C1 ...
%     am_7nd_m2_lossT2nomultC1;

% IterationIndex:1 Lambda_T:0  0  0  0 -5 perm:1  5  3  4  2  6  7  1
% IterationIndex:2 Lambda_T:0  0  0  0 -5 perm:1  5  3  4  2  6  7  1
% IterationIndex:3 Lambda_T:0  0  0  0 -5 perm:1  5  3  4  2  6  7  1
% IterationIndex:4 Lambda_T:0  0  0  0 -5 perm:1  5  3  4  2  6  7  1
% Broke because of successive difference being small.
% 1_7_2
% IterationIndex:1 Lambda_T:0  0  0  0 -5 perm:1  5  3  4  2  6  7  1
% IterationIndex:2 Lambda_T:0  0  0  0 -5 perm:1  5  3  4  2  6  7  1
% Broke because of successive difference being small.
% 2_7_2
% IterationIndex:1 Lambda_T:0  0  0  0 -5 perm:1  5  3  4  2  6  7  1
% IterationIndex:2 Lambda_T:0  0  0  0 -5 perm:1  5  3  4  2  6  7  1
% Broke because of successive difference being small.
% 3_7_2
% IterationIndex:1 Lambda_T:0  0  0  0 -5 perm:1  5  3  4  2  6  7  1
% IterationIndex:2 Lambda_T:0  0  0  0 -5 perm:1  5  3  4  2  6  7  1
% Broke because of successive difference being small.
% 4_7_2
% IterationIndex:1 Lambda_T:0  0  0  0 -5 perm:1  5  3  4  2  6  7  1
% IterationIndex:2 Lambda_T:0  0  0  0 -5 perm:1  5  3  4  2  6  7  1
% Broke because of successive difference being small.
% 5_7_2
% IterationIndex:1 Lambda_T:0  0  0  0 -5 perm:1  5  3  4  2  6  7  1
% IterationIndex:2 Lambda_T:0  0  0 -0 -5 perm:1  6  7  3  2  1  6  7
% IterationIndex:3 Lambda_T:0  0  0  0 -5 perm:1  6  7  3  2  1  6  7
% IterationIndex:4 Lambda_T:0  0  0 -0 -5 perm:1  6  7  5  3  4  2  1
% IterationIndex:5 Lambda_T:0  0  0  0 -5 perm:1  6  7  5  3  4  2  1
% IterationIndex:6 Lambda_T:0  0  0 -0 -5 perm:1  6  2  3  7  1  6  2
% IterationIndex:7 Lambda_T:0  0  0  0 -5 perm:1  6  2  3  7  1  6  2
% IterationIndex:8 Lambda_T:0  0  0 -0 -5 perm:1  6  7  5  3  4  2  1
% IterationIndex:9 Lambda_T:0  0  0  0 -5 perm:1  6  7  5  3  4  2  1
% IterationIndex:10 Lambda_T:0  0  0 -0 -5 perm:1  6  7  5  3  4  2  1
% IterationIndex:11 Lambda_T:0  0  0  0 -5 perm:1  6  7  5  3  4  2  1
% Broke because indexErr was greater than MaxIter/5!


% nm_7nd_m1_auc_test = rocdataTestFull
% nm_7nd_m1_auc_train = rocdataTrain
% nm_7nd_m1_lambda = LambdaC1_alt;
% nm_7nd_m1_C1arr = C1arr;
% nm_7nd_m1_lossT1T3_C1 = fvalC1_Alternating - C1arr.*routeCostT2C1;
% nm_7nd_m1_lossT2nomultC1 = routeCostT2C1;
% nm_7nd_m1_routeInfoC1 = routeinfoC1;
% save nm_7nd_m1.mat ...
%     nm_7nd_m1_auc_test ...
%     nm_7nd_m1_auc_train ...
%     nm_7nd_m1_C1arr ...
%     nm_7nd_m1_lambda ...
%     nm_7nd_m1_lossT1T3_C1 ...
%     nm_7nd_m1_lossT2nomultC1...
%     nm_7nd_m1_routeInfoC1;


% nm_7nd_m2_auc_test = rocdataTestFull
% nm_7nd_m2_auc_train = rocdataTrain
% nm_7nd_m2_lambda = LambdaC1_alt;
% nm_7nd_m2_C1arr = C1arr;
% nm_7nd_m2_lossT1T3_C1 = fvalC1_Alternating - C1arr.*routeCostT2C1;
% nm_7nd_m2_lossT2nomultC1 = routeCostT2C1;
% nm_7nd_m2_routeInfoC1 = routeinfoC1;
% save nm_7nd_m2.mat ...
%     nm_7nd_m2_auc_test ...
%     nm_7nd_m2_auc_train ...
%     nm_7nd_m2_C1arr ...
%     nm_7nd_m2_lambda ...
%     nm_7nd_m2_lossT1T3_C1 ...
%     nm_7nd_m2_lossT2nomultC1 ...
%     nm_7nd_m2_routeInfoC1;

% auc_7nd_m2_nm_125_test = rocdataTestFull;
% auc_7nd_m2_nm_125_train = rocdataTrain;
% t2_7nd_m2_nm_125 = routeCostT2;
% t1t3_7nd_m2_nm_125 = fvalC1_Alternating;
% routeinf_7nd_m2_nm_125 = routeInfo;
% save nm_7nd_m2_125_corr.mat ...
%     auc_7nd_m2_nm_125_test ...
%     auc_7nd_m2_nm_125_train ...
%     t2_7nd_m2_nm_125 ...
%     t1t3_7nd_m2_nm_125 ...
%     routeinf_7nd_m2_nm_125;

% auc_7nd_m1_am_125_test = rocdataTestFull;
% auc_7nd_m1_am_125_train = rocdataTrain;
% t2_7nd_m1_am_125 = routeCostT2;
% t1t3_7nd_m1_am_125 = fvalC1_AM;
% routeinf_7nd_m1_am_125 = routeInfo;
% save am_7nd_m1_125_corr.mat ...
%     auc_7nd_m1_am_125_test ...
%     auc_7nd_m1_am_125_train ...
%     t2_7nd_m1_am_125 ...
%     t1t3_7nd_m1_am_125 ...
%     routeinf_7nd_m1_am_125;
