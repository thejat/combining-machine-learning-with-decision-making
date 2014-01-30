function [Y_hat_val,lambda_model,regularize_coeff,cv_matrix,Y_hat_trn] = ...
    cvalidated_model(str_model,coeffrange,nfolds,nrepeats,...
                    X_trn,Y_trn,X_val,do_not_cv,regularize_coeff)

cv_matrix = [];


if (do_not_cv==0) % is false; that is, we should do cross validation, then:      
    %search for best coeff value
    cv_matrix = zeros(length(coeffrange),nfolds);
    
    for k=1:nrepeats%Get expected CV matrix. Robust in data poor conditions
        %k-fold CV: Generating fold labels
        %changes for each k due to randomness
        foldLabels = get_fold_labels(length(X_trn(:,1)),nfolds);
        for i=1:length(coeffrange)
            for j=1:nfolds
                clear X_tmp X_tmp_eval Y_tmp Y_tmp_eval lambda_model RFmodel Y_tmp_hat_eval
                X_tmp       = X_trn(foldLabels~=j,:);
                X_tmp_eval  = X_trn(foldLabels==j,:);
                Y_tmp       = Y_trn(foldLabels~=j,:);
                Y_tmp_eval  = Y_trn(foldLabels==j,:);

                if(strcmp(str_model,'LogReg')==1)
                    lambda_model = logistic_regression(X_tmp,Y_tmp,coeffrange(i));
                end
                Y_tmp_hat_eval  = 1./(1+exp(-X_tmp_eval*lambda_model));
                [~,~,~,auc_tmp_eval] = perfcurve(Y_tmp_eval,Y_tmp_hat_eval,1);
                cv_matrix(i,j) = cv_matrix(i,j) + (1/nrepeats)*auc_tmp_eval; % AUC
            end
        end
    end
    [~,best_coeff_index] = max(sum(cv_matrix,2));%max for AUC
    regularize_coeff = coeffrange(best_coeff_index);
end
%Final model with the best regularization coefficient
if(strcmp(str_model,'LogReg')==1)
    lambda_model = logistic_regression(X_trn,Y_trn,regularize_coeff);
end
Y_hat_val   = 1./(1+exp(-X_val*lambda_model));%outputs probabilities, not scores but monotone wrt each other
Y_hat_trn   = 1./(1+exp(-X_trn*lambda_model));