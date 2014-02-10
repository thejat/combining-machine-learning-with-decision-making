function [C,unLabeled] = get_decision_data(decision_nodes,flag_single_experiment,param)


if (flag_single_experiment==1) %then supply the legacy data for single experiment
    %Legacy Single Experiment data paths
    single_exp_data   = {'','','','','',...
                            '../data/intermediate/SixNodeData.mat',...
                            '../data/intermediate/SevenNodeData.mat',...
                            '../data/intermediate/EightNodeData.mat','',...
                            '../data/intermediate/TenNodeData.mat'}; %index = number of nodes

    load(single_exp_data{decision_nodes});%loads decision prob params C, (optional) numUnlabeled, unLabeled feature mat
    
    
    %Remove the label information of the unLabeled matrix. It
    %is not needed.
    unLabeled = unLabeled(:,1:end-1);%removing the last column which has true label information. [Legacy compatibility].
    %Normalizing the unLabeled matrix: see normalize_features.m
    numUnlabeled = size(unLabeled,1);
    unLabeled = (unLabeled - repmat(param.avg_X_trn,numUnlabeled,1))./repmat(sqrt(param.var_X_trn),numUnlabeled,1);
    %Add a column of ones: see normalize_features.m
    unLabeled = [unLabeled ones(numUnlabeled,1)];
    
    
    %Experimental: Get rid of the 3rd feature col
    fprintf('Removing third column of the unlabeled feature matrix.\n');
    unLabeled = unLabeled(:,[1 2 4 5]);
    %Experimental: end


    
else
    %do something... auto_data_generator()
    x = param;
    C = 0;
    unLabeled = 0;
end