%This is the refactored version of the previous MLTRP codebase.
%This is the main script to perform the experiemts in the corresponding
%paper.

clc; clear all; close all;

% Parameters
n_sample_size_pcts     = [.1:.3:1];
param0.C2_coeff_range  = [0.01 0.025 0.05 0.075];%l2 regularization coefficient range, default reg param may be bad. see cvalidated.m
param0.n_folds         = 5;
param0.n_repeats       = 3;
param0.C0              = 1000;
param0.fminsearch_opts = optimset('display','off','TolFun',1e-4,...
                                'MaxIter', 500,'MaxFunEvals',1000,...
                                'TolX',1e-4); 

for j=1:length(n_sample_size_pcts)
    % Load prediction data
    s = RandStream('mcg16807','Seed',0); RandStream.setGlobalStream(s); 
    param = get_data_given_sample_size(param0,n_sample_size_pcts(j));

    %Training: finding the boundary for classification using (penalized) logistic regression
    [param.Y_hat_val,param.lambda_model,param.regularize_coeff,param.cv_matrix,param.Y_hat_trn] = ...
                cvalidated_model('LogReg',param.C2_coeff_range,param.n_folds,param.n_repeats,...
                                    param.X_trn,param.Y_trn,param.X_val,0,0.1);
    [param.train_auc,param.test_auc] = performance_of_learning(param.Y_trn,param.Y_hat_trn,param.Y_val,param.Y_hat_val);
    
    param_sample_size{j} = param;
    fprintf('MLOC multirun: j:%2d finished.\n',j);
end

%%
for j=1:length(n_sample_size_pcts)
    auc.test(j) = param_sample_size{j}.test_auc;
    auc.train(j) = param_sample_size{j}.train_auc;
end
figure;
plot(auc.test); hold on;
plot(auc.train,'r'); hold off;