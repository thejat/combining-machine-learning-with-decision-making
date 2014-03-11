function [] = plot_train_scale_performance(result_path,cost_model_type)



% same as plot_learning_performance.m
if(cost_model_type==1)
    load([result_path 'run_2014_02_12_1900hrs_cost_type_1_addendum.mat'],...
        'sequential','am_data','n_sample_size_pcts');
    sequential_addendum         = sequential;
    am_data_addendum            = am_data;
    n_sample_size_pcts_addendum = n_sample_size_pcts;
    load([result_path 'run_2014_02_10_1500hrs_cost_type_1.mat']);
    [sequential,am_data] = do_patch_work(sequential,am_data,n_sample_size_pcts,...
        sequential_addendum,am_data_addendum,n_sample_size_pcts_addendum);
else
    load([result_path 'run_2014_02_12_1700hrs_cost_type_2_addendum.mat'],...
        'sequential','am_data','n_sample_size_pcts');
    sequential_addendum         = sequential;
    am_data_addendum            = am_data;
    n_sample_size_pcts_addendum = n_sample_size_pcts;
    load([result_path 'run_2014_02_12_1000hrs_cost_type_2.mat']);    
    [sequential,am_data] = do_patch_work(sequential,am_data,n_sample_size_pcts,...
        sequential_addendum,am_data_addendum,n_sample_size_pcts_addendum);
end

% Scaling with training data: number of nodes  = 7
% Time elapsed for different training sample sizes
time_elapsed = NaN(length(n_sample_size_pcts),n_multirun);
for j=1:length(n_sample_size_pcts)
    for k = 1:n_multirun
        
        if(sequential{j,k}.feasible==0)
            continue;
        end 
        time_elapsed(j,k) = am_data{j,k}{1}.time_elapsed;
    end
end

h = figure;
width=2;
set(0,'DefaultAxesLineWidth',width);
set(0,'DefaultLineLineWidth',width);
get(0,'Default');
set(gca,'LineWidth',width);
bh = boxplot(time_elapsed',n_sample_size_pcts); hold on;
for i=1:size(bh,2)
     set(bh(:,i),'linewidth',2);
end
xlabel('Training sample size (in percentage)','FontSize',18)
ylabel('Time elapsed (s) ','FontSize',18);
% ylim([0 2500]);
set(gca,'FontSize',18,'fontWeight','bold');
set(findall(h,'type','text'),'fontSize',18,'fontWeight','bold');
saveas(h,['../draft/figures/scaling_train_cost_type_' num2str(cost_model_type) '.png']);