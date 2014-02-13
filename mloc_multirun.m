function [] = mloc_multirun(varargin)
%This function generates different samples sizes and generates different
%decision instances and solves the sequential and simultaneous processes.
%Settings are preserved in get_initial_parameters.m function. The output is
%dumped to file. So you need to load the file to see the results.


%clc; clear all; close all;

% Parameters
param0 = get_initial_parameters();


%Hack to do a subset of simulations
if (nargin>1)
    fprintf('Either give no arguments or a single n_sample_size_pcts array)\n');
elseif(nargin==1)%the assume it is the n_sample_size_pcts array
    param0.n_sample_size_pcts = varargin{1};
    param0.str_addendum = '_addendum';
end


time_loop_start = datevec(now);
for j=1:length(param0.n_sample_size_pcts)
    % Load prediction data
    param1 = get_data_given_sample_size(param0,param0.n_sample_size_pcts(j));
    
    param1 = sequential_training(param1); %does a single training for all decision instances
    
    k = 0;
    while( k < param0.n_multirun)
        k = k +1;        %increment k
        
        time_jk = datevec(now);
        %Workflow: Get decision data, do sequential, do simultaneous
        [sequential{j,k},am_data{j,k},param_sample_size{j,k}] = ...
                                    mloc_workflow_wrapper(param1);
        
        if(sequential{j,k}.feasible==0)%if infeasibility observed, then regenerate
            k = k-1;
            continue;
        end
        fprintf(['MLOC multirun: j:%2d, k:%2d finished.' ...
            ' Total elapsed time: %4.4f, this instance: %4.4f\n'],...
            j,k,etime(datevec(now),time_loop_start),...
                etime(datevec(now),time_jk));
    end
    save([param0.result_path 'run_' ...
        datestr(now,'yyyy_mm_dd_HHMM') 'hrs_cost_type_' ...
        num2str(param0.cost_model_type) param0.str_addendum '.mat']);
end