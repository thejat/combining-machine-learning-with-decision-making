function betaCVX = lasso(X,Y,C)

cvx_begin quiet
   variable betaCVX(length(X(1,:)))
   minimize( ( X*betaCVX-Y )'*( X*betaCVX-Y )/length(Y) + C*norm(betaCVX,1) )
cvx_end