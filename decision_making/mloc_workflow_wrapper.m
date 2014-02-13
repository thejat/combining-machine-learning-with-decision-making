function [sequential,am_data,param] = mloc_workflow_wrapper(param)
%Just a wrapper for the workflow.

% Load decision data
[param.C,param.unLabeled] = ...
    get_decision_data(param.decision_nodes,param.n_multirun,param);

% Sequential Process
sequential = sequential_process(param);
if(sequential.feasible==0)%if infeasibility observed, then regenerate
    param.n_bad_instances = param.n_bad_instances + 1;
    am_data = {}; %useless default value
    return;
end
%only run if forecasts are provided in sequential
%naive = naive_process(sequential.forecasted,param.C);

%%Simultaneous Process
param.C2 = param.C0*sequential.regularized_coeff;%the best one chosen from sequential
am_data = simultaneous_exhausive(param,'AM');% Alternating Minimization (default)
%%nm_data = simultaneous_exhausive(param,'NM');% NM+MILP if needed