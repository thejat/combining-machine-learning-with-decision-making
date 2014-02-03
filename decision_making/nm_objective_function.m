% NM algorithm for solving for the simultaneous process.
function val = nm_objective_function(...
                                lambda_model,...
                                param)
% This function will be anonymized and used as an argument to fminsearch
% param is a constant structure for each run of fminsearch.

[optimal_route,~] = optimize_route_given_model(lambda_model,param);

%compute the objective value for the given route and linear model
val = simultaneous_objective_function(lambda_model,optimal_route,param);