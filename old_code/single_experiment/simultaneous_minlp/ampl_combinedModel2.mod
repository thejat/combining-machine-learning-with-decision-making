#Joint minimization of the regularized training and TRP
#theja 2011-01-30: checked.

#a. parameters related to training error term (term0)
param C0; #weight for term0
param numTrain > 0, integer; #number of training nodes
param dimLambda > 0, integer; # dimension of the parameter vector lambda, d for d-1 D data.
set vecnumTrain := 1..numTrain; #enumerating the training examples
set vecDimLambda := 1..dimLambda; #enumerating the dimensions of lambda
param xtrain{vecnumTrain,vecDimLambda}; #creating an input feature matrix of size dimLambda*numTrain. x = [x1 x2 1].
param ytrain{vecnumTrain}; #creating label vector.

#b. parameters related to route cost term (term1)
param C1; #weight for term1
param numUnlabeled > 0, integer; # number of test nodes
set vecnumUnlabeled := 1..numUnlabeled; # enumerating the test nodes as Vertices
param d{vecnumUnlabeled,vecnumUnlabeled} >= 0; # creating an input ditance matrix of the size (test vertices) ^2.
param xUnlabeled{vecnumUnlabeled,vecDimLambda};

#c. parameters related to the $\ell_2$ regularization (term2)
param C2; #weight for term2

#a. variables related to training error (term0) and $\ell_2$ regularizer (term2)
var lambda{vecDimLambda}; # the parameters of the probability estimator.
var costTerm0;#dummy variable
var costTerm2;#dummy variable

#b. variables related to route cost (term1)
var y{vecnumUnlabeled,vecnumUnlabeled} >=0 binary; # binary on-off variables indicating whether the edge exists in the solution.
var z{vecnumUnlabeled,vecnumUnlabeled} >=0; # flow variables indicating the flow on each edge.
var prob{vecnumUnlabeled} >=0; #probabilities as flow values. dummy. see constraints "prob_2_lambda"
var costTerm1;#dummy variable



#objective:
minimize totalcost : C0*(sum{i in vecnumTrain}log(1+exp(-ytrain[i]*(sum{j in vecDimLambda} lambda[j]*(xtrain[i,j]))))) + C1*(sum{i in vecnumUnlabeled, j in vecnumUnlabeled} d[i,j] * z[i,j]) + C2*(sum{j in vecDimLambda} lambda[j]*lambda[j]); 

#constraints:
#subject to lambda_1: lambda[1] = 1;
#subject to lambda_2: lambda[2] = 1;
#subject to lambda_3: lambda[3] = 1;
subject to dummy_costTerm0: costTerm0 = sum{i in vecnumTrain}log(1+exp(-ytrain[i]*(sum{j in vecDimLambda} lambda[j]*(xtrain[i,j]))));
subject to dummy_costTerm1: costTerm1 = sum{i in vecnumUnlabeled, j in vecnumUnlabeled} d[i,j] * z[i,j];
subject to dummy_costTerm2: costTerm2 = sum{j in vecDimLambda} lambda[j]*lambda[j];
subject to prob_2_lambda {i in vecnumUnlabeled}: prob[i] = log(1+exp((sum{j in vecDimLambda} lambda[j]*xUnlabeled[i,j])));
subject to no_self_loop1 {i in vecnumUnlabeled}: y[i,i] = 0; 				# No edge from node i to itself
subject to no_self_loop2 {i in vecnumUnlabeled}: z[i,i] = 0; 				# No flow from node i to itself
subject to successor {i in vecnumUnlabeled} : sum{j in vecnumUnlabeled} y[i,j] = 1; 	# Exactly one edge out from each node
subject to predecessor {j in vecnumUnlabeled} : sum{i in vecnumUnlabeled} y[i,j] = 1;	# Exactly one edge into each node
	#Flow coming back to initial at end of the loop is p(1)
subject to flow_comming_back_to_node_1: sum{i in vecnumUnlabeled} z[i,1] = prob[1]; 	
	#Change of flow after crossing node k is either p(k) or it is the sum of p’s minus p(1)
subject to flow_changes {k in vecnumUnlabeled:k !=1}: sum{i in vecnumUnlabeled} z[i,k] - sum{j in vecnumUnlabeled} z[k,j] = prob[k];
subject to one_more_flow_change {k in vecnumUnlabeled: k==1}: sum{i in vecnumUnlabeled} z[i,k] - sum{j in vecnumUnlabeled} z[k,j] = prob[1] - (sum{i1 in vecnumUnlabeled} prob[i1]);
	#Connects flows z to indicators of edge y
subject to relation_btw_y_z {i in vecnumUnlabeled,j in vecnumUnlabeled: i!=1 && j!=1}: z[i,j] <= ((sum{i1 in vecnumUnlabeled} prob[i1]) - prob[1])*y[i,j]; 
subject to relation_btw_y_z_1 {i in vecnumUnlabeled}: z[i,1] <= prob[1]*y[i,1];
subject to relation_btw_y_z_2 {j in vecnumUnlabeled}: z[1,j] <= (sum{i1 in vecnumUnlabeled} prob[i1])*y[1,j];
