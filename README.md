Introduction:
For theory, see paper at http://arxiv.org/abs/1104.5061.

Here we are providing code for doing the computation for simultaneous and and the sequential process. For the former, we provide three different ways:
(a) Solving using Bonmin via AMPL with some data processing with matlab (hours)
(b) Solving using NelderMead and Gurobi in Matlab (minutes)
(c) Solving using an Alternate Minimization approach with Gurobi in Matlab (minutes)

*the time in brackets is for solving a weighted TRP of size 7 within the simultaneous process.


System requirements: 
Matlab 7.11.0 R2010b
Bonmin from COIN-OR
Gurobi
Gurobi-Mex by Wotao Yin available at http://www.convexoptimization.com/wikimization/index.php/Gurobi_Mex:_A_MATLAB_interface_for_Gurobi

*One can also use Cplex and Cplex mex integration (look for Cplexint100) . Note that Starting from Gurobi 5+, Gurobi matively supports matlab interfacing but the code was written before this feature.


The code is split among several directories.
You will need to appropriately supply data:
1. Physical graph distances.
2. Training data with appropriate feature dimensions.
3. Unlabeled data associated with corresponding nodes on the graph.
4. For validation of the estimation model, you will need test data.

Setting of parameter C2 is by Cross validation or other equivalent means (is not done here.)
Setting of the tradeoff parameter C1 is by testing a few values.


Quickstart:
Go to folder for_paper/illustration6node/main.m where you can feed your learning data for logistic regression and then perform a weighted TRP.


Reference: http://arxiv.org/abs/1104.5061