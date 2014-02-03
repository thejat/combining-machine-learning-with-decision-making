function am_data = am_exhausive(param)
%This function solves for model and route for a given array of C1 values in
%the param structure object using the AM+MILP algorithm.

for i=1:length(param.C1array)
    param.C1 = param.C1array(i);
    lambda_model_am = zeros(param.n_features+1,1);%initialize model
    route_am = [2:size(param.unLabeled,1) 1];%initialize route
    total_objective_am = 0;
    tic
    for iter_idx=1:param.am_maximum_iterations
        prev_total_objective_am = total_objective_am;
        
        %lambda(t+1) = min over lambda (total obj given a permutation pi(t))
        [lambda_model_am,total_objective_am] = optimize_model_given_route(route_am,param);
        
        % pi(t+1) = min over permutation space given a lambda lambda(t+1)
        [route_am,route_cost_am] = ...
            optimize_route_given_model(lambda_model_am,param);

        % Less than am_maximum_iterations if possible
        if (abs(prev_total_objective_am - total_objective_am)<= param.am_tolerance)
            fprintf('Stopping AM because objecitve has stabilized at iteration %d.\n',iter_idx);
            break;
        end
    end
    am_data{i}.time_elapsed = toc;
    am_data{i}.lambda_model = lambda_model_am;
    am_data{i}.total_objective = total_objective_am;
    am_data{i}.route = route_am;
    am_data{i}.route_cost = route_cost_am;
    am_data{i}.forecasted = get_predicted_probabilities(param.unLabeled,...
                                param.n_features, ...
                                lambda_model_am, ...
                                param.cost_model_type);
    
    %outputs probabilities, not scores but monotone wrt each other
    Y_hat_val   = 1./(1+exp(-param.X_val*lambda_model_am));
    Y_hat_trn   = 1./(1+exp(-param.X_trn*lambda_model_am));
    [am_data{i}.train_auc,am_data{i}.test_auc] = performance_of_learning(...
                            param.Y_trn,...
                            Y_hat_trn,...
                            param.Y_val,...
                            Y_hat_val);
end % End of for loop over param.C1array for AM+MILP