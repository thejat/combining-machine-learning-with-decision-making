%DM 2




% % CHANGE C1arr



clc;
clear all;
close all;

%SAME AS IN MAIN: DO NOT TOUCH
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

C0 = 1; C1 = 1; C2 = 0.1;   %Default coefficients of each of the terms in OBJ.

C1arr =  [0.005 0.01 0.02 0.05 0.1 0.2 0.5 1 2 5];%
%SAME AS IN MAIN: DO NOT TOUCH
C1arr = [30];

addpath(genpath('./misc_files'));


dm_milp_var_i = 0; dm_milp_var_j = 0; dm_milp_var_k = 0;
for dm_milp_var_i=2:2
    if(dm_milp_var_i==1)
        C1arr =  [0.005 0.01 0.05 0.1 0.5 0.85];
    else
        C1arr =  [0.005 0.05 0.1 0.2 0.5 0.85];
    end
    for dm_milp_var_j=7:7
        for dm_milp_var_k=1:length(C1arr);
            C1 = C1arr(dm_milp_var_k);
            local_filename_minlp = strcat(['./minlp_results_feb09/resultC1_Joint20110204_' int2str(dm_milp_var_i) '_' int2str(dm_milp_var_j) '_' int2str(dm_milp_var_k) '.txt']);
            clear string;
            string = ['awk ''/lambda/, /;/'' ' local_filename_minlp ' | awk ''/[0-9]/'' | awk ''{print $2}'''];
            [status,LambdaAWK] = system(string);
            LambdaAWK = str2num(LambdaAWK);
            clear string;
            string = ['awk ''/y \[/, /;/'' ' local_filename_minlp ' | awk ''/[0-9]/'' | awk ''{ if(NR > 1) { print} }'''];
            [status,routeInfoAWK] = system(string);
            routeInfoAWKx = str2num(routeInfoAWK);
            clear routeInfoAWK;
            routeInfoAWK = routeInfoAWKx(:,2:end);
            clear string;
            string = ['awk ''/costTerm0/'' ' local_filename_minlp ' | awk -F" " ''{print $3}'''];
            [status,costTerm0] = system(string);
            costTerm0 = str2num(costTerm0);
            clear string;
            string = ['awk ''/costTerm1/'' ' local_filename_minlp ' | awk -F" " ''{print $3}'''];
            [status,costTerm1] = system(string);
            costTerm1 = str2num(costTerm1);
            clear string;
            string = ['awk ''/costTerm2/'' ' local_filename_minlp ' | awk -F" " ''{print $3}'''];
            [status,costTerm2] = system(string);
            costTerm2 = str2num(costTerm2);
            clear string;
            string = ['awk ''/prob/, /;/'' ' local_filename_minlp ' | awk ''/[0-9]/'' | awk ''{print}'''];
            [status,probaUnlabeledAWK] = system(string);            
            
            %Things to be collected: LambdaAWK, CostTerms0,1,2, routeInfo 
            
            
            LambdaC1(:,dm_milp_var_k,dm_milp_var_j) = LambdaAWK;
            LambdaC1(:,dm_milp_var_k,dm_milp_var_j) = [LambdaC1(2:end,dm_milp_var_k,dm_milp_var_j) ; LambdaC1(1,dm_milp_var_k,dm_milp_var_j)]; %IMPORTANT BONMIN!
            
            bonmin_functionValTrain(:,dm_milp_var_k,dm_milp_var_j)= trainingdata(:,1:numFeatures)*LambdaC1(1:numFeatures,dm_milp_var_k,dm_milp_var_j) + LambdaC1(end,dm_milp_var_k,dm_milp_var_j);
            %verify_costTermC0(dm_milp_var_k,dm_milp_var_j) = C0*sum(log(1+exp(-(trainingdata(:,end).*bonmin_functionValTrain(:,dm_milp_var_k,dm_milp_var_j))))); 
            %verify_costTermC2(dm_milp_var_k,dm_milp_var_j) = C2*norm(LambdaC1(:,dm_milp_var_k,dm_milp_var_j))^2;
            bonmin_costTermC0(dm_milp_var_k,dm_milp_var_j) = C0*costTerm0;
            bonmin_costTermC2(dm_milp_var_k,dm_milp_var_j) = C2*costTerm2; %Bonmin cost values are not scaled.            
            bonmin_costTermC1(dm_milp_var_k,dm_milp_var_j) = costTerm1; %Bonmin cost values are not scaled. 
            
            bonmin_functionValTest(:,dm_milp_var_k,dm_milp_var_j) = xTest_o(:,1:numFeatures)*LambdaC1(1:numFeatures,dm_milp_var_k,dm_milp_var_j) + LambdaC1(end,dm_milp_var_k,dm_milp_var_j);
            rocInput = [bonmin_functionValTest(:,dm_milp_var_k,dm_milp_var_j) 0.5*(yTest_o+1)];
            dm_temp = rocT(rocInput);%no display of roc curve = 0
            rocdataTestFull(:,dm_milp_var_k,dm_milp_var_j) = [dm_temp.AUC dm_temp.SE];
            clear dm_temp rocInput;
            
            bonmin_functionValTrainFull(:,dm_milp_var_k,dm_milp_var_j) = xTrain_o(:,1:numFeatures)*LambdaC1(1:numFeatures,dm_milp_var_k,dm_milp_var_j) + LambdaC1(end,dm_milp_var_k,dm_milp_var_j);
            rocInput = [bonmin_functionValTrainFull(:,dm_milp_var_k,dm_milp_var_j) 0.5*(yTrain_o+1)];
            dm_temp = rocT(rocInput);%no display of roc curve = 0
            rocdataTrainFull(:,dm_milp_var_k,dm_milp_var_j) = [dm_temp.AUC dm_temp.SE];
            clear dm_temp rocInput;
            
            display([num2str(dm_milp_var_i) '_' num2str(dm_milp_var_j) '_' num2str(dm_milp_var_k)]);
        end
    end
end

% 
% minlp_7nd_m1_aucTest = rocdataTestFull(:,:,7);
% minlp_7nd_m1_aucTrain = rocdataTrainFull(:,:,7);
% minlp_7nd_m1_loss_t1t3 = bonmin_costTermC0(:,7) + bonmin_costTermC2(:,7);
% minlp_7nd_m1_loss_t2 = bonmin_costTermC1(:,7);
% save minlp_results_feb09/minlp_7nd_m1.mat ...
%     minlp_7nd_m1_aucTest ...
%     minlp_7nd_m1_aucTrain ...
%     minlp_7nd_m1_loss_t1t3 ...
%     minlp_7nd_m1_loss_t2;


minlp_7nd_m2_aucTest = rocdataTestFull(:,:,7);
minlp_7nd_m2_aucTrain = rocdataTrainFull(:,:,7);
minlp_7nd_m2_loss_t1t3 = bonmin_costTermC0(:,7) + bonmin_costTermC2(:,7);
minlp_7nd_m2_loss_t2 = bonmin_costTermC1(:,7);
save minlp_results_feb09/minlp_7nd_m2.mat ...
    minlp_7nd_m2_aucTest ...
    minlp_7nd_m2_aucTrain ...
    minlp_7nd_m2_loss_t1t3 ...
    minlp_7nd_m2_loss_t2;