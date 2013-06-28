function [c,ceq] = mycon(lambda)

global enable_linear_constraint;

% Compute nonlinear inequalities at x.

c(1) = norm(lambda) - 1 ;
if(enable_linear_constraint==1)
    c(2) = sum(lambda) - 0.5;
else
    c(2) = 0;
end

% Compute nonlinear equalities at x.
ceq = 0 ;   
