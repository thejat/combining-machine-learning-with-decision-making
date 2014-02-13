function [sequential] = sequential_process(param)

%The training code here was shifted off to sequential_training.m to save
%time.

% Obtain probabilities q on decision problem data which is then fed to wTRP solver.
q = get_predicted_probabilities(param.unLabeled, param.n_features, param.lambda_model, param.cost_model_type);

% Compute routes
[sequential.route,sequential.route_cost,sequential.feasible] = solve_wTRP(param.C,q,[],[]);

if (sequential.feasible==0)
    return;
end

%Logging other relevant information for the sequential processes
sequential.forecasted = q;              %forecasted probabilities
sequential.lambda_model = param.lambda_model; %the linear model
sequential.regularized_coeff = param.regularize_coeff;%best regularization coefficient
sequential.cv_matrix = param.cv_matrix;       %cross validation matrix
sequential.train_auc = param.train_auc;       %training AUC
sequential.test_auc = param.test_auc;         %Test/Validation AUC

% fprintf('Finished sequential process.');