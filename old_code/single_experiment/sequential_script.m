%2 step method.

%clc;
clear all;
%close all;
format short;

%Step 1: Loading training and validation/test data.
dprefix = '../data/input/';
load([dprefix 'trainAndTestFull.mat']);
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

C2arr = [0.1];%[0.02 0.05 0.1 0.5];
C0 = 1;

modelNumber = 2; 

dm_2step_var_NumNodes = 6; dm_2step_var_k = 0;
    
    for dm_2step_var_NumNodes=7:7 % number of nodes
    
        if      (dm_2step_var_NumNodes == 6)
            load([dprefix 'SixNodeData.mat']);
        elseif  (dm_2step_var_NumNodes == 7)
            load([dprefix 'SevenNodeData.mat']);
        elseif  (dm_2step_var_NumNodes == 8)
            load([dprefix 'EightNodeData.mat']);
        end
    
        for dm_2step_var_k=1:length(C2arr) %Array of C1 or C2
            
            C2 = C2arr(dm_2step_var_k);
            %modelNumber = dm_2step_var_modelNumber; % TODO: modelNumber can be used by two_step_gurobi
            
            % Two Step Control: via Glmfit+MILP(Cplex/Gurobi)
            flag_step1_twoStep = 1;
            flag_step2_twoStep = 1;
            flag_cplex = 0;
            twostep_method_gurobi;

            LambdaC2(:,dm_2step_var_k) = Lambda;
            
            twoStep_functionValTest(:,dm_2step_var_k) = xTest_o(:,1:numFeatures)*LambdaC2(1:numFeatures,dm_2step_var_k) + LambdaC2(end,dm_2step_var_k);
            rocInput = [twoStep_functionValTest(:,dm_2step_var_k) 0.5*(yTest_o+1)];
            dm_2steptemp = rocT(rocInput);%no display of roc curve = 0
            rocdataTestFull(:,dm_2step_var_k) = [dm_2steptemp.AUC dm_2steptemp.SE];
            clear dm_2steptemp rocInput;
            
            twoStep_functionValTrain(:,dm_2step_var_k) = trainingdata(:,1:numFeatures)*LambdaC2(1:numFeatures,dm_2step_var_k) + LambdaC2(end,dm_2step_var_k);
            rocInput = [twoStep_functionValTrain(:,dm_2step_var_k) 0.5*(trainingdata(:,end)+1)];
            dm_2steptemp = rocT(rocInput);%no display of roc curve = 0
            rocdataTrain(:,dm_2step_var_k) = [dm_2steptemp.AUC dm_2steptemp.SE];
            clear dm_2steptemp rocInput;
            
            twoStep_functionValTrainFull(:,dm_2step_var_k) = xTrain_o(:,1:numFeatures)*LambdaC2(1:numFeatures,dm_2step_var_k) + LambdaC2(end,dm_2step_var_k);
            rocInput = [twoStep_functionValTrainFull(:,dm_2step_var_k) 0.5*(yTrain_o+1)];
            dm_2steptemp = rocT(rocInput);%no display of roc curve = 0
            rocdataTrainFull(:,dm_2step_var_k) = [dm_2steptemp.AUC dm_2steptemp.SE];
            clear dm_2steptemp rocInput;
            
            val_firstterm(dm_2step_var_k) = sum(log(1+(exp(-([trainingdata(:,1:numFeatures) ones(numTrain,1)]*Lambda).*trainingdata(:,end)))));
            val_normterm(dm_2step_var_k) = C2*norm(Lambda)^2;
            
        end
    end


% figure;
% subplot(3,2,1); plot(C2arr,rocdataTestFull(1,:));
% subplot(3,2,2); plot(C2arr,rocdataTestFull(2,:));
% subplot(3,2,3); plot(C2arr,rocdataTrain(1,:));
% subplot(3,2,4); plot(C2arr,rocdataTrain(2,:));
% subplot(3,2,5); plot(C2arr,rocdataTrainFull(1,:));
% subplot(3,2,6); plot(C2arr,rocdataTrainFull(2,:));

% figure; plot(C2arr,val_normterm)
% figure; plot(C2arr,val_firstterm)
% [a,b] = max(rocdataTrainFull(1,:))

% seq_7nd_m1_Lambda = Lambda;
% seq_7nd_m1_fvalStep1 = fvalLR;
% seq_7nd_m1_routeInfo = gurobioutput;
% seq_7nd_m1_rocdataTest = rocdataTestFull;
% seq_7nd_m1_rocdataTrain = rocdataTrain;
% seq_7nd_m1_fvalStep2 = val;
% save seq_7nd_m1.mat ...
%     seq_7nd_m1_fvalStep1 ...
%     seq_7nd_m1_fvalStep2 ...
%     seq_7nd_m1_Lambda ...
%     seq_7nd_m1_rocdataTest ...
%     seq_7nd_m1_rocdataTrain ...
%     seq_7nd_m1_routeInfo;

% seq_7nd_m2_Lambda = Lambda;
% seq_7nd_m2_fvalStep1 = fvalLR;
% seq_7nd_m2_routeInfo = gurobioutput;
% seq_7nd_m2_rocdataTest = rocdataTestFull;
% seq_7nd_m2_rocdataTrain = rocdataTrain;
% seq_7nd_m2_fvalStep2 = val;
% save seq_7nd_m2.mat ...
%     seq_7nd_m2_fvalStep1 ...
%     seq_7nd_m2_fvalStep2 ...
%     seq_7nd_m2_Lambda ...
%     seq_7nd_m2_rocdataTest ...
%     seq_7nd_m2_rocdataTrain ...
%     seq_7nd_m2_routeInfo;





