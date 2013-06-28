%am_gurobi;
function  [gurobilatency,fval_GAM] = am_gurobi(Lambda_T)

global unLabeled numFeatures numTrain modelNumber C numUnlabeled prevGurobioutput routeCostT2 indexIteration permutG indexErr
global routeInfo routeCostT2

%Use off the Lambda_T value to get q.
FunLabeled=unLabeled(:,1:numFeatures)*Lambda_T(1:numFeatures) + Lambda_T(end);
if (modelNumber==1)
    q = 1./(1+exp(-FunLabeled))'; % For Model 1
elseif (modelNumber==2)
    q = log(1+exp(FunLabeled))'; % For Model 2
end


%Preparing the Objective and constraints of the MILP to be passed to Gurobi.

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


contypes = [repmat('=',1,2*numUnlabeled+numUnlabeled + numUnlabeled + 1 + numUnlabeled) repmat('<',1,numUnlabeled^2)]; 
%'===============================<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<';%31eq 36ineq for 6 nodes
objtype = 1;                        % gurobi input: 1 for minimize, -1 for maximize

clear opts
opts.IterationLimit = 4000; opts.FeasibilityTol = 1e-6;
opts.IntFeasTol = 1e-7;     opts.OptimalityTol = 1e-4;
opts.LPMethod = 1;         % 0 - primal, 1 - dual
opts.Presolve = -1;        % -1 - auto, 0 - no, 1 - conserv, 2 - aggressive
opts.Display = 0;
opts.DisplayInterval=0;
opts.OutputFlag=0; 
[xPiT,fval_GAM,exitflag,output] = gurobi_mex(c,objtype,A,b,contypes,lb,ub,vtypes,opts);
if(exitflag==2)
    gurobioutput = round(reshape(xPiT(numUnlabeled^2+1:2*numUnlabeled^2),numUnlabeled,numUnlabeled));
    routeInfo = gurobioutput;
    prevGurobioutput = gurobioutput;
else
    fval_GAM = 50000;
    gurobioutput = prevGurobioutput;
    routeInfo = prevGurobioutput;
    indexErr =  indexErr+1;
end
routeCostT2(indexIteration) = fval_GAM; % not multiplied by C2 here!


%finding latencies to get the second term as a function of latencies.
tempG_k = 1;
permutG(tempG_k) = 1;
for tempG_i=1:numUnlabeled
    permutG(tempG_k+1) = find(gurobioutput(permutG(tempG_k),:) ==1);
    tempG_k = tempG_k+1;
end
gurobilatency = zeros(numUnlabeled,1);
for tempG_i=2:numUnlabeled
    for tempG_k=tempG_i:-1:2
        gurobilatency(tempG_i) = gurobilatency(tempG_i) + C(permutG(tempG_k),permutG(tempG_k-1));
    end
end
gurobilatency(1) = gurobilatency(numUnlabeled) + C(permutG(numUnlabeled),1);
if(fval_GAM==50000)
    gurobilatency(1) = 50000;
end
