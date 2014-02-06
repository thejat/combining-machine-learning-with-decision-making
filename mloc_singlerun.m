%This is the refactored version of the previous MLTRP codebase.
%This is the main script to perform the experiemts in the corresponding
%paper.

clc; clear all; close all;
s = RandStream('mcg16807','Seed',0);
RandStream.setGlobalStream(s); 
% RandStream.setDefaultStream(s); %Use this for R2010 and less.

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
C2_coeff_range = [0.02 0.05 0.1 0.5];%l2 regularization coefficient range
n_folds   = 1;
n_repeats = 1;

%Training: finding the boundary for classification using (penalized) logistic regression

[Y_hat_val,lambda_model,regularize_coeff,cv_matrix,Y_hat_trn] = ...
            cvalidated_model('LogReg',C2_coeff_range,n_folds,n_repeats,...
                                X_trn,Y_trn,X_val,0,0.1);
[train_auc,test_auc] = performance_of_learning(Y_trn,Y_hat_trn,Y_val,Y_hat_val);


%% Forecasted probabilities and wTRP

%Decision problem parameters
decision_problem_nodes = 7;
cost_model_type = 1; % 1 and 2 vary the way predictions are used in wTRP objective.

%Load decision making data
load([data_path decision_problem_data{decision_problem_nodes}]);%saves C, numUnlabeled, unlabeled to the workspace

% Obtain probabilities q on decision problem data which is then fed to wTRP solver.
q = get_predicted_probabilities(unLabeled, n_features, lambda_model, cost_model_type);

% Compute routes
[sequential.route,sequential.route_cost] = solve_wTRP(C,q,[],[]);
[naive.route,naive.route_cost]           = get_naive_solution_from(C,q);

%Logging other relevant information for naive and sequential processes
sequential.forecasted = q;
naive.forecasted = q;
sequential.lambda_model = lambda_model;
naive.lambda_model = lambda_model;
sequential.train_auc = train_auc;
sequential.test_auc = test_auc;

%% Simultaneous Process

simultaneous_param.X_trn = X_trn;
simultaneous_param.Y_trn = Y_trn;
simultaneous_param.X_val = X_val;
simultaneous_param.Y_val = Y_val;
simultaneous_param.C = C;
simultaneous_param.unLabeled = unLabeled;
simultaneous_param.n_features = n_features;
simultaneous_param.cost_model_type = cost_model_type;
simultaneous_param.C0 = 1000;
simultaneous_param.C1array = [0.005 0.01 0.015 0.02 0.025 0.03 0.035 0.04]; %for 7 node data for cost type 1.
%simultaneous_param.C1array = [0.005 0.05  0.1 0.2 0.5 1]; %for 7 node data and cost type 2.
simultaneous_param.C2 = simultaneous_param.C0*regularize_coeff;%the best one chosen from sequential
simultaneous_param.fminsearch_opts = optimset('display','off','TolFun',1e-4,...
                                'MaxIter', 500,'MaxFunEvals',1000,...
                                'TolX',1e-3); 
simultaneous_param.am_maximum_iterations  = 25;
simultaneous_param.am_tolerance = 10^-4;

%NM+MILP: Via Fminsearch+CPLEX
%nm_data = simultaneous_exhausive(simultaneous_param,'NM');

%AM+MILP: Via Fminsearch+Gurobi: Alternating minimization
% lambda(t+1) = min over lambda (total obj given a permutation pi(t))
% pi(t+1) = min over permutation space given a lambda lambda(t+1)
am_data = simultaneous_exhausive(simultaneous_param,'AM');


for i=1:length(am_data)
    fprintf('%d: train auc: %.3f test  auc: %.3f\n',i,am_data{i}.train_auc,am_data{i}.test_auc);
end
for i=1:length(am_data)
    fprintf('%d: route: %s\n',i,num2str(am_data{i}.route));
end