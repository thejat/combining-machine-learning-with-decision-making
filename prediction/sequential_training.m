function [param] = sequential_training(param)
%This is simply performing a l2-reg cvalidaed logistic regression and
%noting down the test and training AUC values.

%Training: finding the boundary for classification using (penalized) logistic regression
[param.Y_hat_val,param.lambda_model,param.regularize_coeff,param.cv_matrix,param.Y_hat_trn] = ...
            cvalidated_model('LogReg',param.C2_coeff_range,param.n_folds,param.n_repeats,...
                                param.X_trn,param.Y_trn,param.X_val,0,0.1);
[param.train_auc,param.test_auc] = performance_of_learning(param.Y_trn,param.Y_hat_trn,param.Y_val,param.Y_hat_val);
% fprintf('Finished sequential process CV-logistic regression.');