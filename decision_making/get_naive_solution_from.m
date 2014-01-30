function [sol, cost] = get_naive_solution_from(C,q)
%Takes the input distance matrix and the probabilities of failure and 
% computes a naive route according to decreasing order of probabilities

numUnlabeled = length(q);

%The naive route
[~, sol] = sort(q(2:end),'descend');%seq is a row vector, transpose if col is required
sol = [sol+1 1];

%Cost of the naive route

indx_i = [1 sol(1:end-1)]; %relevant indices assuming sol is a row vector**
indx_j = sol;

Aeq_additional = zeros(numUnlabeled,2*numUnlabeled^2);
for k=1:numUnlabeled
    tempidx = (indx_j(k)-1)*numUnlabeled + indx_i(k);
    Aeq_additional(k,numUnlabeled^2+tempidx) = 1;
end
beq_additional = ones(numUnlabeled,1);

[~,cost] = solve_wTRP(C,q,Aeq_additional,beq_additional);

