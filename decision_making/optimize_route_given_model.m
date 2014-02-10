function [optimal_route,optimal_route_cost] = optimize_route_given_model(lambda_model,param)
%This function is ued in both NM and AM implementations.
%It takes the model and decision making problem data and conditional on the
%model, get the best route for the decision problem.
%It computes the forecasted probabilities internally.

% Obtain probabilities q on decision problem data which is then fed to wTRP solver.
q = get_predicted_probabilities(param.unLabeled,...
                                param.n_features, ...
                                lambda_model, ...
                                param.cost_model_type);

% Compute route
[optimal_route,optimal_route_cost,~] = solve_wTRP(param.C,q,[],[]); %todo: exception handling

