%creating 7 node and 8 node datasets

clc;
clear all;
close all;

load TenNodeData_full.mat;   %contains dists_obtained_from_GMAPquery, numUnlabeled, unLabeled.

unLabeled_10node = unLabeled; clear unLabeled;

dists_obtained_from_GMAPquery = dists_obtained_from_GMAPquery/100;
% Casting the distances in a format amenable to Gurobi/ampl/Cplex.
iterate_k=1;
for iterate_i=1:numUnlabeled
    for iterate_j=1:iterate_i-1
        C_10node(iterate_i,iterate_j) = dists_obtained_from_GMAPquery(iterate_k,1);
        C_10node(iterate_j,iterate_i) = C_10node(iterate_i,iterate_j);
        iterate_k = iterate_k+1;
    end
end

%% 10 node data
C = C_10node;
numUnlabeled = 10;
unLabeled = unLabeled_10node;
save TenNodeData.mat C numUnlabeled unLabeled;
clear unLabeled C numUnlabeled;
%% 7 node data
numUnlabeled = 7;
unLabeled = [unLabeled_10node(1:6,:); unLabeled_10node(9,:)] ;
C = zeros(numUnlabeled,numUnlabeled);
C(1:6,1:6) = C_10node(1:6,1:6);
C(7,1:6) = C_10node(9,1:6);
C(1:6,7) = C(7,1:6)';

save SevenNodeData.mat C numUnlabeled unLabeled;
clear unLabeled C numUnlabeled;

%% 8 node data
numUnlabeled = 8;
unLabeled = [unLabeled_10node(1:6,:); unLabeled_10node(8:9,:)] ;
C = zeros(numUnlabeled,numUnlabeled);
C(1:6,1:6) = C_10node(1:6,1:6);
C(7,1:6) = C_10node(8,1:6);
C(1:6,7) = C(7,1:6)';
C(8,1:6) = C_10node(9,1:6);
C(8,7)   = C_10node(9,8);
C(1:6,8) = C(8,1:6)';
C(7,8) = C(8,7);

save EightNodeData.mat C numUnlabeled unLabeled;
clear unLabeled C numUnlabeled;

