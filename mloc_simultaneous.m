% AM+MILP: Via Fminsearch+Gurobi
    %Alternating minimization
    % lambda(t+1) = min over lambda (total obj given a permutation pi(t))
    % pi(t+1) = min over permutation space given a lambda lambda(t+1)

am_param = nm_param;
am_param.fminsearch_opts = nm_fminsearch_opts;
am_param.maximum_iterations  = 25;

for i=1:length(C1arr)
    C1 = C1arr(i);
    lambda_model_am = zeros(n_features+1,1);%initialize model
    route_am = [2 3 4 5 6 7 1];%initialize route

    for iter_idx=1:am_param.maximum_iterations
        
        %lambda(t+1) = min over lambda (total obj given a permutation pi(t))
        [lambda_model_am] = optimize_model_given_route(route_am,am_param);
        
        % pi(t+1) = min over permutation space given a lambda lambda(t+1)
        [route_am,route_cost_am] = ...
            optimize_route_given_model(lambda_model_am,am_param);

        
        % Less than am_maximum_iterations if possible
        if((iter_idx>1) && (abs(fval)<= 10^-4))
            display('Stopped AM because of successive difference being small.');
             break;
         end
    end
end % End of for loop over C1arr for AM+MILP