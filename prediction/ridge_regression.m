function betaCVX = ridge_regression(X,Y,C)

cvx_begin quiet
    variable betaCVX(length(X(1,:)))
    minimize( ( X*betaCVX-Y )'*( X*betaCVX-Y )/length(Y) + C*betaCVX'*betaCVX )
cvx_end