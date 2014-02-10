function [X_trn,X_val,avg_X_trn,var_X_trn] = normalize_features(xTrain_o,xTest_o)
%de-mean and normalize the data using training variance.

n_train   = size(xTrain_o,1);
var_X_trn = var(xTrain_o);
avg_X_trn = mean(xTrain_o);

X_trn = (xTrain_o - repmat(avg_X_trn,n_train,1))./repmat(sqrt(var_X_trn),n_train,1);
X_val = (xTest_o - repmat(avg_X_trn,n_train,1))./repmat(sqrt(var_X_trn),n_train,1);

X_trn = [X_trn ones(size(X_trn,1),1)]; %add the last feature which is all ones
X_val = [X_val ones(size(X_val,1),1)];