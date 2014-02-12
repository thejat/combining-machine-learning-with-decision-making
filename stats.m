%This script reads the results dumped by mloc_multirun.m and creats
%evaluation plots for the paper.

clc;clear all;close all;
result_path  = '/Users/theja/Downloads/temp/mloc_results_feb_2014/';%repetition, maybe move to startup? will get cleared unless do addpath
load([result_path 'run_20140210_3pm_cost_type_1.mat']);

%%


close all;
plot_performance(n_sample_size_pcts,n_multirun,sequential,am_data);


%% AUC of an all -1 guesser: No ordering means bad guesser.
[baseline_train_auc,baseline_test_auc] = performance_of_learning(...
                            param1.Y_trn,...
                            -1*ones(size(param1.Y_trn,1),1),...
                            param1.Y_val,...
                            -1*ones(size(param1.Y_trn,1),1))