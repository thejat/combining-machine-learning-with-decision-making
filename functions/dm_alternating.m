%DM 2

clc;
clear all;
close all;

for dm2_var_i=1:2
    load(['result_alternating_matlab_workspace_Feb2_Alternate_1_7_' int2str(dm2_var_i)]);  
%     figure;
%     subplot(2,1,1)
%     plot(routeCostIterationT1T3);   
%     subplot(2,1,2)
%     plot(routeCostIterationT2);
%     
    routeCostC1(dm2_var_i,:) = [routeCostIterationT1T3(end) routeCostIterationT2(end)];
    
    clear routeCostIterationT1T3 routeCostIterationT2;
end

% load result_matlab_workspace_model1_Feb2_Joint_6;

