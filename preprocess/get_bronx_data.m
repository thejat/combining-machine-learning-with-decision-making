function [X_trn,Y_trn,X_val,Y_val,n_features,latLongs] = ...
                                                get_bronx_data()


% dat_0.mat contains Bronx area data: strId, strLat,strLon, xTest_o,
% xTrain_o, yTest_o, yTrain_o
prediction_data_path = '../data/input/bronx/';
load([prediction_data_path 'dat_0.mat']);


n_features = size(xTrain_o,2);
n_train    = size(xTrain_o,1);


[X_trn,X_val] = normalize_features(xTrain_o,xTest_o,n_train);
 

Y_trn = yTrain_o;
Y_val = yTest_o;

%Also output the lat longs read. Needed for the multirun experiment.
latLongs.lat = strLat;
latLongs.lon = strLon;