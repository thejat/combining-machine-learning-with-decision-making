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



for j=1:length(param0.n_sample_size_pcts)
    % Load prediction data
    param1 = get_data_given_sample_size(param0,param0.n_sample_size_pcts(j));
    
    k = 0;
    while( k < param0.n_multirun)
        %increment k
        k = k +1;
        
        % The follwing ensures we don't resample training when new decision
        % data is generated.
        clear param;
        param = param1;
        
        
        %Workflow: Get decision data, do sequential, do simultaneous
        
        % Load decision data
        [param.C,param.unLabeled] = ...
            get_decision_data(param.decision_nodes,param.n_multirun,param);

        % Sequential Process
        sequential{j,k} = sequential_process(param);
        if(sequential{j,k}.feasible==0)%if infeasibility observed, then regenerate
            k = k-1;
            param.n_bad_instances = param.n_bad_instances + 1;
            continue;
        end
        %only run if forecasts are provided in sequential{j}
        %naive = naive_process(sequential{j,k}.forecasted,param.C);

        %%Simultaneous Process
        param.C2 = param.C0*sequential{j,k}.regularized_coeff;%the best one chosen from sequential
        am_data{j,k} = simultaneous_exhausive(param,'AM');% Alternating Minimization (default)
        %%nm_data{j,k} = simultaneous_exhausive(param,'NM');% NM+MILP if needed

        param_sample_size{j,k} = param;
        fprintf('MLOC multirun: j:%2d, k:%2d finished.\n',j,k);
    end
    save([param.result_path 'run_' ...
        datestr(now,'yyyy_mm_dd_HHMM') 'hrs_cost_type_' ...
        num2str(param0.cost_model_type) param.str_addendum '.mat']);
end