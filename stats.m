%This script reads the results dumped by mloc_multirun.m and creats
%evaluation plots for the paper.

clc;clear all;close all;
result_path  = '../data/mloc_results_feb_2014/';%repetition, maybe move to startup? will get cleared unless do addpath

%% Learning performance
plot_learning_performance(result_path,1);
plot_learning_performance(result_path,2);

%% Scaling performance
plot_scale_performance(result_path,1);
plot_scale_performance(result_path,2);
plot_train_scale_performance(result_path,1);
plot_train_scale_performance(result_path,2);