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
    [~,unLabeled,~,~] = normalize_features(unLabeled,unLabeled,param.avg_X_trn,param.var_X_trn);%the first argument is not used and is ineffective.

else
    
    dist_matrix_norm_single_exp = 50.6179;%norm(C);%This is the value for the C matrix for 7 node example which affects the range of C1 we can consider.
    %clear C unLabeled numUnlabeled; %since these were loaded by default. see line 10.
     
    c = pi/180;
    distance =  @(lat1,lon1,lat2,lon2) 6370*2*asin(sqrt(sin(c*(lat1-lat2)/2)^2 + cos(c*lat1)*cos(c*lat2) * sin(c*(lon1-lon2)/2)^2));%Haversine formula
    %Randomly generate a instance using test data
    n_val = size(param.X_val,1);
    unlabeled_indices = randperm(n_val,decision_nodes);
    unLabeled = param.X_val(unlabeled_indices,:);%no need to normalize again
    C = zeros(decision_nodes,decision_nodes);
    for i=1:size(C,1)
        for j=i+1:size(C,2)
            C(i,j) = distance(param.latLongs.lat(unlabeled_indices(i)),...
                              param.latLongs.lon(unlabeled_indices(i)),...
                              param.latLongs.lat(unlabeled_indices(j)),...
                              param.latLongs.lon(unlabeled_indices(j)));
        end
    end
    C = (C + C'); %in Kms
    C = C*dist_matrix_norm_single_exp/norm(C);%to have the same norm as the single experiment datasets
end
% fprintf('Got decision data.');
