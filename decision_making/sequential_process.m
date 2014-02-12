function [sequential] = sequential_process(param)

%Training: finding the boundary for classification using (penalized) logistic regression
[Y_hat_val,lambda_model,regularize_coeff,cv_matrix,Y_hat_trn] = ...
            cvalidated_model('LogReg',param.C2_coeff_range,param.n_folds,param.n_repeats,...
                                param.X_trn,param.Y_trn,param.X_val,0,0.1);
[train_auc,test_auc] = performance_of_learning(param.Y_trn,Y_hat_trn,param.Y_val,Y_hat_val);
% fprintf('Finished sequential process CV-logistic regression.');

% Obtain probabilities q on decision problem data which is then fed to wTRP solver.
q = get_predicted_probabilities(param.unLabeled, param.n_features, lambda_model, param.cost_model_type);

% Compute routes
[sequential.route,sequential.route_cost,sequential.feasible] = solve_wTRP(param.C,q,[],[]);

if (sequential.feasible==0)
    return;
end

%Logging other relevant information for the sequential processes
sequential.forecasted = q;              %forecasted probabilities
sequential.lambda_model = lambda_model; %the linear model
sequential.regularized_coeff = regularize_coeff;%best regularization coefficient
sequential.cv_matrix = cv_matrix;       %cross validation matrix
sequential.train_auc = train_auc;       %training AUC
sequential.test_auc = test_auc;         %Test/Validation AUC

% fprintf('Finished sequential process.');