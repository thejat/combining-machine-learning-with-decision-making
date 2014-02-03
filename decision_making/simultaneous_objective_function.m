% NM algorithm for solving for the simultaneous process.
function val = simultaneous_objective_function(...
                                lambda_model,...
                                param)
% This function will be anonymized and used as an argument to fminsearch
% param is a constant structure for each run of fminsearch.

[~,optimal_route_cost] = optimize_route_given_model(lambda_model,param);

%compute the objective value for the given route and linear model
val = param.C0*sum(log(1+(exp(-(param.X*lambda_model).*param.Y))))/length(param.Y) ...
        + param.C1*optimal_route_cost ...
        + param.C2*norm(lambda_model)^2;
fprintf('MLOC total objective value: %5.3f\n',val);