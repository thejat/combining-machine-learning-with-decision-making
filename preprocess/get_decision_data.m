function [C,unLabeled] = get_decision_data(decision_nodes,flag_single_experiment,param)


if (flag_single_experiment==1) %then supply the legacy data for single experiment
    %Legacy Single Experiment data paths
    single_exp_data   = {'','','','','',...
                            '../data/intermediate/SixNodeData.mat',...
                            '../data/intermediate/SevenNodeData.mat',...
                            '../data/intermediate/EightNodeData.mat','',...
                            '../data/intermediate/TenNodeData.mat'}; %index = number of nodes

    load(single_exp_data{decision_nodes});%loads decision prob params C, (optional) numUnlabeled, unLabeled feature mat
else
    %do something... auto_data_generator()
    x = param;
    C = 0;
    unLabeled = 0;
end