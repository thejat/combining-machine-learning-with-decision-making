function data = simultaneous_exhausive(param,str_algorithm)
%This function solves for model and route for a given array of C1 values in
%the param structure object using the AM+MILP and NM+MILP algorithms.

for i=1:length(param.C1array)
    param.C1 = param.C1array(i);
    tic
    
    
    if(strcmp(str_algorithm,'NM'))
        %NM
        [lambda_model,total_objective,exitflag_nm,output_nm] = ...
            fminsearch(@(lambda_model)nm_objective_function(...
                                            lambda_model,...
                                            param),...
                                            zeros(param.n_features+1,1),...
                                            param.fminsearch_opts);
    elseif(strcmp(str_algorithm,'AM'))
        %AM
        lambda_model = zeros(param.n_features,1);%initialize model
        route_am = [2:size(param.unLabeled,1) 1];%initialize route
        total_objective = 0;
        for iter_idx=1:param.am_maximum_iterations
            prev_total_objective = total_objective;

            %lambda(t+1) = min over lambda (total obj given a permutation pi(t))
            [lambda_model,total_objective] = optimize_model_given_route(route_am,param);

            % pi(t+1) = min over permutation space given a lambda lambda(t+1)
            [route_am,route_cost_am] = ...
                optimize_route_given_model(lambda_model,param);

            % Less than am_maximum_iterations if possible
            if (abs(prev_total_objective - total_objective)<= param.am_tolerance)
                fprintf('Stopping AM because objecitve has stabilized at iteration %d.\n',iter_idx);
                break;
            end
        end
    else
        data = [];
        fprintf('Pleas pick the right algorithm.\n');
        return;
    end
    
    %collect information from this run
    data{i}.time_elapsed = toc;
    data{i}.lambda_model = lambda_model;
    data{i}.total_objective = total_objective;
    data{i}.forecasted = get_predicted_probabilities(param.unLabeled,...
                                param.n_features, ...
                                lambda_model, ...
                                param.cost_model_type);
    [data{i}.route,data{i}.route_cost] = solve_wTRP(param.C,data{i}.forecasted,[],[]);
    
    %outputs probabilities, not scores but monotone wrt each other
    Y_hat_val   = 1./(1+exp(-param.X_val*lambda_model));
    Y_hat_trn   = 1./(1+exp(-param.X_trn*lambda_model));
    
    [data{i}.train_auc,data{i}.test_auc] = performance_of_learning(...
                            param.Y_trn,...
                            Y_hat_trn,...
                            param.Y_val,...
                            Y_hat_val);
end % End of for loop over param.C1array for AM+MILP