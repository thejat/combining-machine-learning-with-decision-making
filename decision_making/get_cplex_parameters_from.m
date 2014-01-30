function [c,Aineq,bineq,Aeq,beq,lb,ub,vtypes] = ...
                        get_cplex_parameters_from(C,q)
%Takes as input the symmetric distance matrix C and the number of unlabeled
%decision locations and the forecasted probabilities at each of these
%locations

%Outputs the coefficients and the linear objective, the constraint matrix A
%on LHS, the vector b on RHS, the lb and ub on the decision variables (xij and yij)
% and the type of variables (continuous C and binary B)

%Note: Number of variables: integers numUnlabeled^2 for xij and numUnlabeled^2 binary for yij (could be numUnlabeled^2-numUnlabeled each)

numUnlabeled = length(q);

%% Parameters in the objective
c = [reshape(C,numUnlabeled^2,1);zeros(numUnlabeled^2,1)];% gurobi/cplex input: vectorized form of C Matrix


%% Parameters in the constraints

% Creating the R matrix required for one of the constraints
R = (sum(q)-q(1))*ones(numUnlabeled,numUnlabeled);
for i=1:numUnlabeled
    for j=1:numUnlabeled
        if(j==1)
            R(i,j) = q(1);
        end
        if(i==1)
            R(i,j) = sum(q);
        end
    end
end

% Defining matrix A and vector b
A00 = [diag([1 zeros(1,numUnlabeled-1)]) zeros(numUnlabeled)];
A01 = [zeros(numUnlabeled) diag([1 zeros(1,numUnlabeled-1)])];
for i=1:numUnlabeled
 A0(i,:) = reshape(circshift(A00,[i-1,i-1]),2*numUnlabeled^2,1)'; 
 A0(i+numUnlabeled,:) = reshape(circshift(A01,[i-1,i-1]),2*numUnlabeled^2,1)';
end

A2(1,:) = [zeros(1,numUnlabeled^2) ones(1,numUnlabeled) zeros(1,numUnlabeled^2-numUnlabeled)];                  %colsum of yij
A1(1,:) = [zeros(1,numUnlabeled^2) reshape([ones(numUnlabeled,1) zeros(numUnlabeled,numUnlabeled-1)]',1,numUnlabeled^2)];  %rowsum of yij
for i=2:numUnlabeled
    A2(i,:) = circshift(A2(1,:)',numUnlabeled*(i-1))';
    A1(i,:) = circshift(A1(1,:)',i-1)';
end

A3 = [ones(numUnlabeled,1); zeros(numUnlabeled^2-numUnlabeled,1); zeros(numUnlabeled^2,1)]'; % the Nth leg flow value is 1 back to the first node. column sum
A42(1,:) = [ones(1,numUnlabeled) zeros(1,numUnlabeled^2-numUnlabeled) zeros(1,numUnlabeled^2)];                 %colsum of xij
A41(1,:) = [reshape([ones(numUnlabeled,1) zeros(numUnlabeled,numUnlabeled-1)]',1,numUnlabeled^2) zeros(1,numUnlabeled^2)]; %rowsum of xij
A4(1,:) = A42(1,:) - A41(1,:);
for i=2:numUnlabeled
    A42(i,:) = circshift(A42(1,:)',numUnlabeled*(i-1))';
    A41(i,:) = circshift(A41(1,:)',i-1)';
    A4(i,:) = A42(i,:)-A41(i,:);
end
bA4 = q';
bA4(1) = bA4(1) - sum(q);
A5 = zeros(numUnlabeled^2,2*numUnlabeled^2);
for i=1:numUnlabeled
    for j=1:numUnlabeled
        A50 = [zeros(numUnlabeled) zeros(numUnlabeled)];
        A50(i,j) = 1;           % for xij
        A50(i,j+numUnlabeled) = -R(i,j);   % for yij
        A5(numUnlabeled*(i-1)+j,:) = reshape(A50,2*numUnlabeled^2,1)';
    end
end

Aeq =  sparse([A0; A1; A2; A3; A4]);
beq = [zeros(2*numUnlabeled,1); ones(numUnlabeled,1);ones(numUnlabeled,1); q(1); bA4];
Aineq = sparse(A5);
bineq = zeros(numUnlabeled^2,1);
%Number of constraints: 2*numUnlabeled + numUnlabeled + numUnlabeled + 1 + numUnlabeled + numUnlabeled^2

% Bounds on the decision variables
lb = zeros(2*numUnlabeled^2,1);
ub = [sum(q)*ones(numUnlabeled^2,1);ones(numUnlabeled^2,1)]; % using loosely somewhat. Shoudl Rij figure here?

%Variable types
vtypes = [repmat('C',1,numUnlabeled^2) repmat('B',1,numUnlabeled^2)];