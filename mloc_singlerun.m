%This is the refactored version of the previous MLTRP codebase.
%This is the main script to perform the experiemts in the corresponding
%paper.

clc; clear all; close all;
s = RandStream('mcg16807','Seed',0); RandStream.setGlobalStream(s); 

flag_single_experiment  = 1; %0 implies non anecdotal experiment is run
decision_nodes          = 7; %number of nodes in the decision problem.


[param.X_trn,param.Y_trn,param.X_val,param.Y_val,param.n_features,param.latLongs] = ...
    get_bronx_data(); %read Bronx data (features, labels, lats,longs)
[param.C,param.unLabeled] = get_decision_data(decision_nodes,flag_single_experiment,param);

param.cost_model_type = 1; % 1 and 2 vary the way predictions are used in wTRP objective.
param.C2_coeff_range  = [0.01 0.025 0.05 0.075];%l2 regularization coefficient range
param.n_folds         = 10;
param.n_repeats       = 3;

%% Sequential and Naive Processes
sequential = sequential_process(param);
naive = naive_process(sequential.forecasted,param.C);%Can only run if forecasts are provided.

%% Simultaneous Process

param.C0 = 1000;
if (param.cost_model_type==1)
    param.C1array = [0.005 0.01 0.015]; %for 7 node data for cost type 1.
else
    param.C1array = [0.005 0.05  0.1 0.2 0.5 1]; %for 7 node data and cost type 2.
end
param.C2 = param.C0*sequential.regularized_coeff;%the best one chosen from sequential
param.fminsearch_opts = optimset('display','off','TolFun',1e-4,...
                                'MaxIter', 500,'MaxFunEvals',1000,...
                                'TolX',1e-4); 
param.am_maximum_iterations  = 25;
param.am_tolerance = 10^-4;


%nm_data = simultaneous_exhausive(param,'NM');%NM+MILP
am_data = simultaneous_exhausive(param,'AM');% Alternating Minimization


for i=1:length(am_data)
    fprintf('%d: train auc: %.3f test  auc: %.3f\n',i,am_data{i}.train_auc,am_data{i}.test_auc);
end
for i=1:length(am_data)
    fprintf('%d: route: %s\n',i,num2str(am_data{i}.route));
end