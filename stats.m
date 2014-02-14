%This script reads the results dumped by mloc_multirun.m and creats
%evaluation plots for the paper.

clc;clear all;close all;
result_path  = '../data/mloc_results_feb_2014/';%repetition, maybe move to startup? will get cleared unless do addpath
cost_model_type = 1;


%% Learning performance
plot_learning_performance(result_path,cost_model_type);

%% Scaling performance
plot_scale_performance(result_path,cost_model_type);