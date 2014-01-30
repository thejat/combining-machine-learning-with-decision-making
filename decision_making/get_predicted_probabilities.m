function q = get_predicted_probabilities(unLabeled, n_features, lambda_model, cost_model_type)
%This function takes the constructed prediction model and uses the
%features of the decision making data to come up with predicted
%probabilities of failure.


numUnlabeled = size(unLabeled,1);

scores_unLabeled=[unLabeled(:,1:n_features) ones(numUnlabeled,1)]*lambda_model;
if      (cost_model_type==1)
    q = 1./(1+exp(-scores_unLabeled))';     % For cost model 1 (see paper)
elseif  (cost_model_type==2)
    q = log(1+exp(scores_unLabeled))';    % For cost model 2 (see paper)
end

%tbd: remove n_features