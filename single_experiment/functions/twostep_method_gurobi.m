%2011-01-28: Trying to separate data from the 2 step and joint methods.
%What: This implements Method of first performing the supervised
%learning and then dealing with the route cost optimization.


%INPUTS
%numFeatures
%trainingdata (numTrain,numFeatures+1)


%OUTPUTS
Lambda                  = zeros(numFeatures+1,1); %numFeatures+1 length vector 
functionValTrain        = zeros(numTrain,1);   %Evaluationo of the linear function on training data
trainingloss            = -1;          %Training loss normalized.
Funlabeled              = zeros(length(unLabeled(:,1)),1);   %function on graph nodes.
q                       = zeros(length(unLabeled(:,1)),1);    %probabilities on graph nodes.

if(flag_step1_twoStep == 1) % Starting Step 1

    % % Step 1a : Finding the boundary for classification using (penalized)
    % Logistic regression
    
    fminsearchLRopts = optimset('display','off','TolFun',1e-9, 'MaxIter', 5000,'MaxFunEvals',10000, 'TolX',1e-6);
    [Lambda,fvalLR,exitflagLR,outputLR] = fminsearch(@(Lambda)(sum(log(1+(exp(-([trainingdata(:,1:numFeatures) ones(numTrain,1)]*Lambda).*trainingdata(:,end))))) + C2*norm(Lambda)^2),zeros(numFeatures+1,1),fminsearchLRopts);
    functionValTrain=trainingdata(:,1:numFeatures)*Lambda(1:numFeatures) + Lambda(end);
    trainingloss = sum(log(1+exp(-(trainingdata(:,end).*functionValTrain))));

    % % Step 1b : Find probabilities q on test data which is fed to wTRP problem.

    FunLabeled=unLabeled(:,1:numFeatures)*Lambda(1:numFeatures) + Lambda(end);
    
    if(modelNumber==1)
        q=1./(1+exp(-FunLabeled))';     % For Model 1
    elseif (modelNumber==2)
        q = log(1+exp(FunLabeled))';    % For Model 2
    end

end % End of Step 1


if(flag_step2_twoStep==1) % Starting Step 2

    % % Step 2a : Preparing the Objective and the constraints of the MILP to be
    % passed to Cplex/Gurobi.
    
    c = [reshape(C,numUnlabeled^2,1);zeros(numUnlabeled^2,1)];% gurobi/cplex input: vectorized form of C Matrix
    % Number of variables: integers numUnlabeled^2 for xij and numUnlabeled^2 binary for yij (could be numUnlabeled^2-numUnlabeled each)
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
    A =  sparse([A0; A1; A2; A3; A4; A5]);
    b = [zeros(2*numUnlabeled,1); ones(numUnlabeled,1);ones(numUnlabeled,1); q(1); bA4; zeros(numUnlabeled^2,1)];
    %2*numUnlabeled+numUnlabeled + numUnlabeled + 1 + numUnlabeled + numUnlabeled^2
    lb = zeros(2*numUnlabeled^2,1); % scalar means a uniform lower bound equal to scalar (which is zero here)
    ub = [sum(q)*ones(numUnlabeled^2,1);ones(numUnlabeled^2,1)]; % using loosely somewhat. Shoudl Rij figure here?
    vtypes = [repmat('C',1,numUnlabeled^2) repmat('B',1,numUnlabeled^2)];



    % Step 2b : Solving using Cplex or Gurobi as chosen in main.m

    if(flag_cplex ==1)
        INDEQ = [1:2*numUnlabeled+numUnlabeled + numUnlabeled + 1 + numUnlabeled]' ;% first 31 are eq constraints, next 36 areineq
        OPTIONS=[];                             % use standard options
        %OPTIONS.save_prob='test_cplex.lp';      % save problem to the file test_cplex.lp
        OPTIONS.verbose = 2;
        [XMIN,FMIN,SOLSTAT,DETAILS] = cplexint([], c, A, b, INDEQ, [], lb, ub,vtypes',OPTIONS);
        cplexoutput = round(reshape(XMIN(37:72),6,6));
    end

    flag_gurobi = ~flag_cplex;
    if(flag_gurobi==1)
        contypes = [repmat('=',1,2*numUnlabeled+numUnlabeled + numUnlabeled + 1 + numUnlabeled) repmat('<',1,numUnlabeled^2)]; 
        %'===============================<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<';%31eq 36ineq for 6 nodes
        objtype = 1;                        % gurobi input: 1 for minimize, -1 for maximize

        clear opts
        opts.IterationLimit = 4000; opts.FeasibilityTol = 1e-3;
        opts.IntFeasTol = 1e-3;     opts.OptimalityTol = 1e-3;
        opts.LPMethod = 1;         % 0 - primal, 1 - dual
        opts.Presolve = -1;        % -1 - auto, 0 - no, 1 - conserv, 2 - aggressive
        opts.Display = 1;
        [x,val,exitflag,output] = gurobi_mex(c,objtype,A,b,contypes,lb,ub,vtypes,opts);
        if(exitflag==2)
            gurobioutput = round(reshape(x(numUnlabeled^2+1:2*numUnlabeled^2),numUnlabeled,numUnlabeled))
        end
    end

end % End of Step 2
 

%%ADDITIONAL INFORMATION ABOUT THE SOLVERS

% Syntax for Cplexint100 mex:    
%    min    0.5*x'*H*x + f'*x
%     x
%    s.t.:  A x {'<=' | '='} b
%           x' * QC(i).Q * x + QC(i).L * x <= QC(i).r,  i=1,...,nQC
%           x >= LB
%           x <= UB
%           x(i) is of VARTYPE(i), i=1,...,n
% The calling syntax is:
% [XMIN,FMIN,SOLSTAT,DETAILS] = cplexint(H, f, A, b, INDEQ, QC, LB, UB,...
%                                        VARTYPE, PARAM, OPTIONS)

% % Syntax for Gurobi:
%     x = gurobi_mex(c, objtype, A, b, contypes, lb, ub, vartypes, options); 
%     *  c: objective coefficient vector, double. 
%     [] (empty array) means uniformly 0 coefficients, and scalar means all coefficients equal to scalar.  
%     * objtype: 1 (minimization) or -1 (maximization).
%     * A: constraint coefficient matrix, double, sparse.
%     * b: constraint right-hand side vector, double. 
%     * contypes: constraint types. Char array of '>', '<', '='. 
%     * lb: variable lower bound vector, double. 
%     * ub: variable upper bound vector, double. 
%     * vartypes: variable types. Char array of chars 'C', 'B', 'I', 'S', 'N'. C for continuous; B for binary; I for integer; S for semi-continuous; N for semi-integer. [] (empty array) means all variables are continuous. 
% Output Description
%     * x: primal solution vector; empty if Gurobi encounters errors or stops early (in this case, check output flag).
%     * val: optimal objective value; empty if Gurobi encounters errors or
%     stops early.