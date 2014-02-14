%This script generates for different decision size nodes, generates different
%decision instances and solves the sequential and simultaneous processes.
%Settings are preserved in get_initial_parameters.m function. The output is
%dumped to file.


clc; clear all; close all;

% Parameters
param0 = get_initial_parameters();
decision_nodes_array = [3 5];
% Load prediction data
param1 = get_data_given_sample_size(param0,.1);%n_sample_size fixed to 10%    
param1 = sequential_training(param1); %does a single training for all decision instances
time_loop_start = datevec(now);
%%
parpool
for j=1:length(decision_nodes_array)
    param1.decision_nodes = decision_nodes_array(j);
    parfor k=1:param0.n_multirun
        time_loop{j,k} = datevec(now);
        %Workflow: Get decision data, do sequential, do simultaneous
        [sequential{j,k},am_data{j,k},param_sample_size{j,k}] = ...
                                    mloc_workflow_wrapper(param1);

        if(sequential{j,k}.feasible==0)%if infeasibility observed, then regenerate
            continue;
        end
        fprintf(['MLOC multirun: j:%2d, k:%2d finished.' ...
            ' Total elapsed time: %4.4f, this instance: %4.4f\n'],...
            j,k,etime(datevec(now),time_loop_start),...
                etime(datevec(now),time_loop{j,k}));
    end
    save([param0.result_path 'run_scalability_' ...
        datestr(now,'yyyy_mm_dd_HHMM') 'hrs_cost_type_' ...
        num2str(param0.cost_model_type) param0.str_addendum '.mat']);
end