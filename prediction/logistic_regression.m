function betaCVX = logistic_regression(X,Y,C)

%cvx_begin quiet
%    variable betaCVX(size(X,2))
%    minimize( sum(log(1+(exp(-(X*betaCVX).*Y))))/length(Y) + C*(betaCVX')*betaCVX )
%cvx_end

opts = optimset('display','notify','TolFun',1e-9, 'MaxIter', 5000,...
                'MaxFunEvals',10000, 'TolX',1e-6);
[betaCVX,temp1,temp2,~] = fminsearch(...
    @(betaCVX)(sum(log(1+(exp(-(X*betaCVX).*Y))))/length(Y) + C*(betaCVX')*betaCVX),...
    zeros(size(X,2),1),opts);
%fprintf('Logistic regrssion using fminsearch: C = %2.2f, fval=%5.5f, exitflag=%d\n',C,temp1,temp2);
