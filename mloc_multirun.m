%This is the refactored version of the previous MLTRP codebase.
%This is the main script to perform the experiemts in the corresponding
%paper.

clc; clear all; close all;
s = RandStream('mcg16807','Seed',0); RandStream.setGlobalStream(s); 

% Parameters
flag_single_experiment= 1; %0 implies non anecdotal experiment is run
decision_nodes        = 7; %number of nodes in the decision problem.
param.cost_model_type = 1; % 1 and 2 vary the way predictions are used in wTRP objective.
param.C2_coeff_range  = [0.01 0.025 0.05 0.075];%l2 regularization coefficient range
param.n_folds         = 3;
param.n_repeats       = 3;
param.C0              = 1000;
param.fminsearch_opts = optimset('display','off','TolFun',1e-4,...
                                'MaxIter', 500,'MaxFunEvals',1000,...
                                'TolX',1e-4); 
param.am_maximum_iterations = 25;
param.am_tolerance    = 10^-4;
if (param.cost_model_type==1)
    param.C1array = 0.001*[.5 1 3 5];  %for 7 node data for cost type 1.
else
    param.C1array = 0.001*[.1 .5 1 5]; %for 7 node data and cost type 2.
end

n_sample_size_pcts    = [.1:.1:1];

for j=1:length(n_sample_size_pcts)
    
    % Load prediction data
    param_sample_size{j} = get_data_given_sample_size(param,n_sample_size_pcts(j));
    
    % Load decision data
    [param_sample_size{j}.C,param_sample_size{j}.unLabeled] = ...
        get_decision_data(decision_nodes,flag_single_experiment,param_sample_size{j});

    % Sequential Process
    sequential{j} = sequential_process(param_sample_size{j});
    %only run if forecasts are provided in sequential{j}
    %naive = naive_process(sequential{j}.forecasted,param_sample_size{j}.C);

    % Simultaneous Process
    param_sample_size{j}.C2 = param_sample_size{j}.C0*sequential{j}.regularized_coeff;%the best one chosen from sequential
    am_data{j} = simultaneous_exhausive(param_sample_size{j},'AM');% Alternating Minimization (default)
    %nm_data = simultaneous_exhausive(param_sample_size{j},'NM');% NM+MILP if needed

end

%%
for j=1:length(n_sample_size_pcts)
    fprintf('seqnt: %2d: train auc: %.3f test  auc: %.3f. ',j,sequential{j}.train_auc,sequential{j}.test_auc);
    temp_am1 = 0;
    temp_am2 = 0;
    for i=1:length(am_data{j})
%         fprintf('simul: %d: train auc: %.3f test  auc: %.3f\n',i,am_data{j}{i}.train_auc,am_data{j}{i}.test_auc);
        temp_am1 = max(temp_am1,am_data{j}{i}.train_auc);
        temp_am2 = max(temp_am2,am_data{j}{i}.test_auc);
    end
    fprintf('simul: %2d: train auc: %.3f test  auc: %.3f\n',j,temp_am1,temp_am2);
%     for i=1:length(am_data{j})
%         fprintf('%d: route: %s\n',i,num2str(am_data{j}{i}.route));
%     end
end

%%
for j=1:length(n_sample_size_pcts)
    fprintf('sequn: %d: route: %s\n',i,num2str(sequential{j}.route));
    for i=1:length(am_data{j})
        fprintf('simul: %d: route: %s\n',i,num2str(am_data{j}{i}.route));
    end
end
%%
for j=1:length(n_sample_size_pcts)
    fprintf('seqnt: %2d: train auc: %.3f test  auc: %.3f. ',j,sequential{j}.train_auc,sequential{j}.test_auc);
    temp_am1 = 0;
    temp_am2 = 0;
    for i=1:length(am_data{j})
%         fprintf('simul: %d: train auc: %.3f test  auc: %.3f\n',i,am_data{j}{i}.train_auc,am_data{j}{i}.test_auc);
        temp_am1 = max(temp_am1,am_data{j}{i}.train_auc);
        temp_am2 = max(temp_am2,am_data{j}{i}.test_auc);
    end
    fprintf('simul: %2d: train auc: %.3f test  auc: %.3f\n',j,temp_am1,temp_am2);
end
