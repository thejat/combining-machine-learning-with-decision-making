%This script reads the results dumped by scalability_test.m and creates
%evaluation plots for the paper.


close all;clear all;clc;

load('run_scalability_2014_02_13_2056hrs_cost_type_2.mat',...
    'am_data','sequential','param0','decision_nodes_array');

am_data1 = am_data;
sequential1 = sequential;
param01 = param0;
decision_nodes_array1 =decision_nodes_array;

load('run_scalability_2014_02_13_2125hrs_cost_type_2.mat',...
    'am_data','sequential','decision_nodes_array');
am_data = [am_data1;am_data];
sequential = [sequential1;sequential];
decision_nodes_array = [decision_nodes_array1 decision_nodes_array];
plot_performance_scalability(am_data,sequential,param0,decision_nodes_array);