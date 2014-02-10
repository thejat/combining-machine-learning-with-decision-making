function [X_trn,Y_trn,X_val,Y_val,...
            n_features,latLongs,avg_X_trn,var_X_trn] = ...
                                        get_bronx_data(n_sample_size_pct)


% dat_0.mat contains Bronx area data: strId, strLat,strLon, xTest_o,
% xTrain_o, yTest_o, yTrain_o
prediction_data_path = '../data/input/bronx/';
load([prediction_data_path 'dat_0.mat']);

%Normalize prediction data: this could have happened after sub-selection but
%chose to do it here.
[X_trn,X_val,avg_X_trn,var_X_trn] = normalize_features(xTrain_o,xTest_o,-1,-1);%the last two arguments are for precomputed mean and variance values.
Y_trn = yTrain_o;
Y_val = yTest_o;

%Shrink the training sample size keeping the same proportion of -1s and +1s
neg_idx = find(Y_trn==-1);
neg_subset_idx = ...
    randperm(length(neg_idx),...
            ceil(n_sample_size_pct*length(neg_idx)));%returns some unique integers between 1,length(neg_idx);
pos_idx = find(Y_trn==1);
pos_subset_idx = ...
    randperm(length(pos_idx),...
            ceil(n_sample_size_pct*length(pos_idx)));%returns some unique integers between 1,length(neg_idx);

X_trn = X_trn([pos_idx(pos_subset_idx);neg_idx(neg_subset_idx)]',:);
Y_trn = Y_trn([pos_idx(pos_subset_idx);neg_idx(neg_subset_idx)]');

n_features = size(X_trn,2);


%Decision data: output the test lat longs. Needed for the multirun experiment.
latLongs.lat = strLat;
latLongs.lon = strLon;


