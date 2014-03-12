#Introduction:

This is the accompanying code for the following paper: [On combining machine learning with decision making](http://arxiv.org/abs/1104.5061).

This was the code used for performing the experiments in Section 5 for the simultaneous and the sequential processes. 


The code is split among several directories. The main scripts are at the top level and the helper functions are in the corresponding directories.

You will need to appropriately supply prediction data (not included here):
1. Physical graph distances.
2. Training data with appropriate feature dimensions.
3. Unlabeled data associated with corresponding nodes on the graph.
4. For validation of the estimation model, you will need test data.

Setting of parameter C2 is by Cross validation. Setting of the tradeoff parameter C1 is exploratory in nature.

#Requirements:
	- Appropriate datasets for prediction and decision making
	- Gurobi 5.x or ILOG CPLEX 12.x


#Todo

 - Debug flag for fprintf statements in varius routines.
 - parallelization
 - profiling


#Quickstart (before Dec 2011):
Go to folder for_paper/illustration6node/main.m where you can feed your learning data for logistic regression and then perform a weighted TRP.



#Solving the mixed integer nonlinear programs (before Dec 2011):

For solving the sumultaneous process, we used three different ways:

	(a) Solving using Bonmin via AMPL with some data processing with matlab (hours)
	(b) Solving using NelderMead and Gurobi in Matlab (minutes)
	(c) Solving using an Alternate Minimization approach with Gurobi in Matlab (minutes)

*the time in brackets is for solving a weighted TRP of size 7 within the simultaneous process.

The following configuration was used:
	- Matlab 7.11.0 R2010b
	- Bonmin from COIN-OR
	- Gurobi and [Gurobi-Mex](http://www.convexoptimization.com/wikimization/index.php/Gurobi_Mex:_A_MATLAB_interface_for_Gurobi) by Wotao Yin.

*We also attempted using Cplex and Cplex mex integration (Cplexint100).


