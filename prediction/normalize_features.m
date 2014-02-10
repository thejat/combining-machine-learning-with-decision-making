function [X_trn_norm,X_val_norm,avg_X_trn,var_X_trn] = normalize_features(X_trn,X_val,avg_X_trn,var_X_trn)
%de-mean and normalize the data using training variance.

n_train   = size(X_trn,1);
n_val     = size(X_val,1);

if (max(var_X_trn)==-1) %if these n_feature*1 vectors have not been precomputed.
    var_X_trn = var(X_trn);
    avg_X_trn = mean(X_trn);
end

X_trn_norm = (X_trn - repmat(avg_X_trn,n_train,1))./repmat(sqrt(var_X_trn),n_train,1);
X_val_norm = (X_val - repmat(avg_X_trn,n_val,1))./repmat(sqrt(var_X_trn),n_val,1);

X_trn_norm = [X_trn_norm ones(n_train,1)]; %add the last feature which is all ones
X_val_norm = [X_val_norm ones(n_val,1)];


% %Experimental: Get rid od the 3rd feature col
% fprintf('Experimental: Removing third column of the feature matrix.\n');
% X_trn_norm = X_trn_norm(:,[1 2 4 5]);%the 5th coulmn is all ones
% X_val_norm = X_val_norm(:,[1 2 4 5]);
% %Experimental: end