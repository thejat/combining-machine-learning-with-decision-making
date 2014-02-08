function [X_trn,Y_trn,X_val,Y_val,n_features,latLongs] = ...
                                                get_bronx_data(n_sample_size_pct)


% dat_0.mat contains Bronx area data: strId, strLat,strLon, xTest_o,
% xTrain_o, yTest_o, yTrain_o
prediction_data_path = '../data/input/bronx/';
load([prediction_data_path 'dat_0.mat']);


%Normalize prediction data
[X_trn,X_val] = normalize_features(xTrain_o,xTest_o);
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

%Experimental: Get rid od the 3rd feature col
fprintf('Removing third column of the feature matrix.\n');
X_trn = X_trn(:,[1 2 4]);
X_val = X_val(:,[1 2 4]);
%Experimental: end


n_features = size(X_trn,2);


%Decision data: output the test lat longs. Needed for the multirun experiment.
latLongs.lat = strLat;
latLongs.lon = strLon;


