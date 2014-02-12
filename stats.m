%This script reads the results dumped by mloc_multirun.m and creats
%evaluation plots for the paper.

clc;clear all;close all;
result_path  = '/Users/theja/Downloads/temp/mloc_results_feb_2014/';%repetition, maybe move to startup? will get cleared unless do addpath
load([result_path 'run_20140210_3pm_cost_type_1.mat']);

%%


close all;
plot_performance(n_sample_size_pcts,n_multirun,sequential,am_data);

