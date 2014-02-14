%This script reads the results dumped by mloc_multirun.m and creats
%evaluation plots for the paper.

clc;clear all;close all;
result_path  = '../data/mloc_results_feb_2014/';%repetition, maybe move to startup? will get cleared unless do addpath
cost_model_type = 1;

plot_learning_performance(result_path,cost_model_type);


%% AUC of an all -1 guesser: No ordering means bad guesser.
[baseline_train_auc,baseline_test_auc] = performance_of_learning(...
                            param1.Y_trn,...
                            -1*ones(size(param1.Y_trn,1),1),...
                            param1.Y_val,...
                            -1*ones(size(param1.Y_trn,1),1))