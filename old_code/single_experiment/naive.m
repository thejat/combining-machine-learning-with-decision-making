%the naive method of sorting probabilities in decreasing order and forming
%the route.

% q_m1 = [0.3001    0.4184    0.7240    0.9784    0.9870    0.1321    0.0367];
% q_m2 = [0.3568    0.5419    1.2875    3.8331    4.3419    0.1417    0.0373];
% 
% % order_m1_naive = [1 5 4 3 2 6 7 1];
% % order_m2_naive = [1 5 4 3 2 6 7 1];
% order_m1_naive = [1 5 3 4 2 6 7 1];
% order_m2_naive = [1 5 3 4 2 6 7 1];
% 
% 
% C_original =[...
%          0   10.5800   10.2700   16.2900   10.1500    0.4100   13.3000;
%    10.5800         0    7.3300    5.9500    7.4500    1.8500   12.6800;
%    10.2700    7.3300         0    6.0100    0.1200   10.7200    5.3500;
%    16.2900    5.9500    6.0100         0    6.1400    7.8000   11.3700;
%    10.1500    7.4500    0.1200    6.1400         0   10.6000    5.2300;
%     0.4100    1.8500   10.7200    7.8000   10.6000         0   12.8900;
%    13.3000   12.6800    5.3500   11.3700    5.2300   12.8900         0];
% 
% naive_cost_m1 = 0;
% naive_cost_m2 = 0;
% for i=2:8
%     sum_d_m1 = 0;
%     sum_d_m2 = 0;
%     for j=1:i-1
%             sum_d_m1 = sum_d_m1 + C(order_m1_naive(j),order_m1_naive(j+1));
%             sum_d_m2 = sum_d_m2 + C(order_m2_naive(j),order_m2_naive(j+1));
%     end
%     naive_cost_m1 = naive_cost_m1 + sum_d_m1*q_m1(order_m1_naive(i));
%     naive_cost_m2 = naive_cost_m2 + sum_d_m2*q_m2(order_m2_naive(i));
% end

ratios_seq_m1 = 62.3031;
ratios_seq_m2 = 154.4714;
ratios_naive_m1 = 77.5922;
ratios_naive_m2 = 177.9716;
ratios_c1pt05_m1 = 35.1829;
ratios_c1pt05_m2 = 23.1681;
ratios_c1pt5_m1 = 3.8614;
ratios_c1pt5_m2 = 0.7088;

NvsS_m1 = (ratios_naive_m1 - ratios_seq_m1)/ratios_seq_m1;
NvsS_m2 = (ratios_naive_m2 - ratios_seq_m2)/ratios_seq_m2;
SvsPt05_m1 = (ratios_seq_m1 - ratios_c1pt05_m1)/ratios_c1pt05_m1;
SvsPt05_m2 = (ratios_seq_m2 - ratios_c1pt05_m2)/ratios_c1pt05_m2;
SvsPt5_m1 = (ratios_seq_m1 - ratios_c1pt5_m1)/ratios_c1pt5_m1;
SvsPt5_m2 = (ratios_seq_m2 - ratios_c1pt5_m2)/ratios_c1pt5_m2;
NvsPt5_m1 = (ratios_naive_m1 - ratios_c1pt5_m1)/ratios_c1pt5_m1;