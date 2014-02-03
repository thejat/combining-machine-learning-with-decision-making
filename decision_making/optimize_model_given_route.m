function [lambda_model] = optimize_model_given_route(optimal_route,optimal_route_cost,param)



%latencies
latencies = optimal_route;

[lambda_model,fval_model,exitflag,output] = fminsearch(,zeros(param.n_features+1,1),param.fminsearch_opts);


val = param.C0*sum(log(1+(exp(-(param.X*lambda_model).*param.Y))))/length(param.Y) ...
        + param.C1*optimal_route_cost ...
        + param.C2*norm(lambda_model)^2;
fprintf('MLOC total objective value: %5.3f\n',val);