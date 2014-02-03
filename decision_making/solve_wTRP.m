function [route,fval] = solve_wTRP(C,q,Aeq_additional,beq_additional)
%This functions solve an instance of the wTRP problem given ALL parameters.


numUnlabeled = length(q);
% Preparing the Objective and the constraints of the MILP to be passed to
% Cplex.
[c,Aineq,bineq,Aeq,beq,lb,ub,vtypes] = get_cplex_parameters_from(C,q);
Aeq = [Aeq;Aeq_additional];%appending additional equality constraints here.
beq = [beq;beq_additional];

try
   % Since cplexmilp solves minimization problems and the problem
   % is a maximization problem, negate the objective

   options = cplexoptimset;
   options.Diagnostics = 'off';
   
   [x, fval, exitflag, output] = cplexmilp (c, Aineq, bineq, Aeq, beq,...
      [ ], [ ], [ ], lb, ub, vtypes, [ ], options);
   
   fprintf ('wTRP solution status: %s \n', output.cplexstatusstring);
   fprintf ('  Route cost: %f, ', fval);
   Yij = round(reshape(x(numUnlabeled^2+1:end),numUnlabeled,numUnlabeled));
   route = sequence_from_binary_mat(Yij);
   fprintf ('route: %s\n',int2str(route));
catch m
   throw (m);
end


% %Second opinion if needed: Using gurobi
% try
%    model.obj = c;
%    model.A = [Aineq;Aeq];
%    model.rhs = [bineq;beq];
%    model.sense = [repmat('<',1,size(Aineq,1)) repmat('=',1,size(Aeq,1))];
%    model.vtype = vtypes;
%    model.modelsense = 'min';
%    clear params
%    params.outputflag = 0;
%    result = gurobi(model,params);
%    
%    fprintf ('Solution value = %f \n', result.objval);
%    disp ('Yij Matrix =');
%    disp (round(reshape(result.x(numUnlabeled^2+1:end),numUnlabeled,numUnlabeled)));
% catch gurobiError
%    fprintf('gurobi reported error.\n');
% end