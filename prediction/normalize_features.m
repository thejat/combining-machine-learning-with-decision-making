function [X_trn_norm,X_val_norm,avg_X_trn,var_X_trn] = normalize_features(X_trn,X_val)
%de-mean and normalize the data using training variance.

n_train   = size(X_trn,1);
n_val     = size(X_val,1);
var_X_trn = var(X_trn);
avg_X_trn = mean(X_trn);

X_trn_norm = (X_trn - repmat(avg_X_trn,n_train,1))./repmat(sqrt(var_X_trn),n_train,1);
X_val_norm = (X_val - repmat(avg_X_trn,n_val,1))./repmat(sqrt(var_X_trn),n_val,1);

X_trn_norm = [X_trn_norm ones(n_train,1)]; %add the last feature which is all ones
X_val_norm = [X_val_norm ones(n_val,1)];