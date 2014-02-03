%This is the refactored version of the previous MLTRP codebase.
%This is the main script to perform the experiemts in the corresponding
%paper.

clc; clear all; close all;
s = RandStream('mcg16807','Seed',0);
RandStream.setGlobalStream(s); 
% RandStream.setDefaultStream(s); %Use commented for R2010 and less.

%% Settings
data_path = '../data/intermediate/';
decision_problem_data  = {'','','','','','SixNodeData.mat','SevenNodeData.mat','EightNodeData.mat','','TenNodeData.mat'}; %index = number of nodes

%change into a_b names

%% Read data
% trainAndTestFull.mat was prepared from Bronx area data.
load([data_path 'trainAndTestFull.mat']);
n_features = size(xTrain_o,2);
n_train    = size(xTrain_o,1);

%de-mean and normalize the data using training variance.
var_X_trn = var(xTrain_o);
avg_X_trn = mean(xTrain_o);
X_trn = (xTrain_o - repmat(avg_X_trn,n_train,1))./repmat(sqrt(var_X_trn),n_train,1);
X_val = (xTest_o - repmat(avg_X_trn,n_train,1))./repmat(sqrt(var_X_trn),n_train,1);
X_trn = [X_trn ones(size(X_trn,1),1)]; %add the last feature which is all ones
X_val = [X_val ones(size(X_val,1),1)];
Y_val = yTest_o;
Y_trn = yTrain_o;
clear avg_X_trn var_X_trn xTrain_o yTrain_o xTest_o yTest_o

%tbd: change to a_b variable names for _o stuff

%% Sequential and Naive methods: Prediction

%prediction setting
C2_coeff_range = [0.02 0.05 0.1 0.5];%l2 regularization coefficient
n_folds   = 1;
n_repeats = 1;

%Training: finding the boundary for classification using (penalized) logistic regression

[Y_hat_val,lambda_model,regularize_coeff,cv_matrix,Y_hat_trn] = ...
    cvalidated_model('LogReg',C2_coeff_range,n_folds,n_repeats,...
    X_trn,Y_trn,X_val,0,0.1);
%performance plots
[temp_x,temp_y,~,temp_auc] = perfcurve(Y_trn,Y_hat_trn,1);
figure;plot(temp_x,temp_y); hold on; plot(temp_x,temp_x,'r'); title(['Training ROC with AUC:' num2str(temp_auc)]);
[temp_x,temp_y,~,temp_auc] = perfcurve(Y_val,Y_hat_val,1);
figure;plot(temp_x,temp_y); hold on; plot(temp_x,temp_x,'r'); title(['Test ROC with AUC:' num2str(temp_auc)]);
clear temp_x temp_y temp_auc


%% Forecasted probabilities and wTRP

%Decision problem parameters
decision_problem_nodes = 7;
cost_model_type = 1; % 1 and 2 vary the way predictions are used in wTRP objective.

%Load decision making data
load([data_path decision_problem_data{decision_problem_nodes}]);%saves C, numUnlabeled, unlabeled to the workspace

% Obtain probabilities q on decision problem data which is then fed to wTRP solver.
q = get_predicted_probabilities(unLabeled, n_features, lambda_model, cost_model_type);

% Compute routes
[sequential_route,sequential_cost] = solve_wTRP(C,q,[],[]);
[naive_route,naive_cost]           = get_naive_solution_from(C,q);


%% NM+MILP: Via Fminsearch+CPLEX

%C1arr = [0.005 0.01 0.05 0.1 0.5 1]; %for 7 node data for cost type 1.
%C1arr = [0.005 0.05  0.1 0.2 0.5 1]; %for 7 node data and cost type 2.
C1arr = [1];

nm_param.unLabeled = unLabeled;
nm_param.n_features = n_features;
nm_param.cost_model_type = cost_model_type;
nm_param.C0 = 1000;
nm_param.C2 = nm_param.C0*regularize_coeff;%the best one chosen from sequential
nm_param.X = X_trn;
nm_param.Y = Y_trn;
nm_param.C = C;
nm_param.fminsearch_opts = optimset('display','off','TolFun',1e-4,...
                                'MaxIter', 500,'MaxFunEvals',1000,...
                                'TolX',1e-3); 
for i=1:length(C1arr)
    nm_param.C1 = C1arr(i);
    tic
    [lambda_model_nm,total_objective_nm,exitflag_nm,output_nm] = ...
        fminsearch(@(lambda_model_nm)simultaneous_objective_function(...
                                        lambda_model_nm,...
                                        nm_param),...
                                        zeros(n_features+1,1),...
                                        nm_param.fminsearch_opts);
    %collect information from this run
    nm_data{i}.time_elapsed = toc;
    nm_data{i}.lambda_model = lambda_model_nm;
    nm_data{i}.total_objective = total_objective_nm;
    q = get_predicted_probabilities(unLabeled,...
                                n_features, ...
                                lambda_model_nm, ...
                                cost_model_type);
    [nm_data{i}.route,nm_data{i}.route_cost] = solve_wTRP(C,q,[],[]);
end
