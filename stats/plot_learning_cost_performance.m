function [] = plot_learning_cost_performance(result_path,cost_model_type)

[am_data,sequential,param0,n_sample_size_pcts] = do_patch_work_learning(result_path,cost_model_type);

%%

sample_seq = NaN(length(n_sample_size_pcts),param0.n_multirun);
sample_sim = NaN(length(n_sample_size_pcts),param0.n_multirun);

seq_test_auc = NaN(length(n_sample_size_pcts),param0.n_multirun);
sim_test_auc = NaN(length(n_sample_size_pcts),param0.n_multirun);

for j=1:length(n_sample_size_pcts)
    for k = 1:param0.n_multirun
        if(sequential{j,k}.feasible==0)
            continue;
        end
        best_sim_test_auc = max([am_data{j,k}{1}.test_auc,...%HARDCODED
                                am_data{j,k}{2}.test_auc,...
                                am_data{j,k}{3}.test_auc,...
                                am_data{j,k}{4}.test_auc]);
%         if( best_sim_test_auc < max(sequential{j,k}.test_auc-.10*sequential{j,k}.test_auc,.5) )
%             continue;
%         end
        sim_costs = [am_data{j,k}{1}.route_cost,...%HARDCODED
                                am_data{j,k}{2}.route_cost,...
                                am_data{j,k}{3}.route_cost,...
                                am_data{j,k}{4}.route_cost];
        sim_costs =  sim_costs(sim_costs>0);
        if(isempty(sim_costs))
            continue;
        end
        sample_sim(j,k) = min(sim_costs);
        sample_seq(j,k) = sequential{j,k}.route_cost;
        seq_test_auc(j,k) = sequential{j,k}.test_auc;
        sim_test_auc(j,k) = best_sim_test_auc;
    end
end
sample_norm_diff = (sample_sim'-sample_seq')./sample_seq';


h = figure;
width=2;
set(0,'DefaultAxesLineWidth',width);
set(0,'DefaultLineLineWidth',width);
get(0,'Default');
set(gca,'LineWidth',width);
bh = boxplot(sample_norm_diff,n_sample_size_pcts); hold on;%shoud be below 0 line
for i=1:size(bh,2)
     set(bh(:,i),'linewidth',3);
end
plot(0:length(n_sample_size_pcts)+1,zeros(length(n_sample_size_pcts)+2,1),'g-');hold off;
ylim([-.25 .25]);
ylabel('Percentage cost change','FontSize',18);
xlabel('Training sample size (percentage)','FontSize',18)
set(gca,'FontSize',18,'fontWeight','bold');
set(findall(h,'type','text'),'fontSize',18,'fontWeight','bold');
saveas(h,['../draft/figures/training_decision_cost_performance_cost' int2str(cost_model_type) '.png']);%TEMPORARY

%% Two simple hypothesis tests

% H0: test stats are not very different
for j=1:length(n_sample_size_pcts)
    [p1(j),h1(j),stats1{j}] = signtest(sample_sim(j,:),sample_seq(j,:),'tail','left'); %h=1 implies reject the null at 5% significance level.
end

for j=1:length(n_sample_size_pcts)
    [p2{j},h2{j},stats2{j}] = signtest(sim_test_auc(j,:),seq_test_auc(j,:),'tail','right'); %h=0 implies do not reject the null at 5% significance level.
end
