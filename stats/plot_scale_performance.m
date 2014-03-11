function [] = plot_scale_performance(result_path,cost_model_type)


[am_data,sequential,param0,decision_nodes_array] = do_patch_work_scale(result_path,cost_model_type);


%Performance in terms of AUC at different scales
time_elapsed = NaN(length(decision_nodes_array),param0.n_multirun);
for j=1:length(decision_nodes_array)
    for k = 1:param0.n_multirun
        
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
bh = boxplot(log10(time_elapsed'),decision_nodes_array); hold on;
for i=1:size(bh,2)
     set(bh(:,i),'linewidth',2);
end
xlabel('decision problem size (nodes)','FontSize',18)
ylabel('Time elapsed (s) in log scale','FontSize',18);
% ylim([0 2500]);
set(gca,'FontSize',18,'fontWeight','bold');
set(findall(h,'type','text'),'fontSize',18,'fontWeight','bold');
saveas(h,['../draft/figures/scaling_cost_type_' num2str(cost_model_type) '.png']);