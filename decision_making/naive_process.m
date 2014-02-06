function [naive] = naive_process(q,C)
%Takes two inputs: the predicted probabilities and the distance matrix C of
%the decision problem.

% Compute routes
[naive.route,naive.route_cost]           = get_naive_solution_from(C,q);

