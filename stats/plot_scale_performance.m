function [] = plot_scale_performance(result_path,cost_model_type)


[am_data,sequential,param0,decision_nodes_array] = do_patch_work_scale(result_path,cost_model_type);


%Performance in terms of AUC at different scales
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
boxplot(time_elapsed',decision_nodes_array); hold on;
xlabel('decision node size','FontSize',18)
ylabel('Time elapsed','FontSize',18);
set(gca,'FontSize',18,'fontWeight','bold');
set(findall(h,'type','text'),'fontSize',18,'fontWeight','bold');




%%If you want to know the train and test performances using the same
%%dataset but different decision instances.
%Performance in terms of AUC at different scales
% auc.seq.train = [];
% auc.simul.train = [];
% auc.seq.test = [];
% auc.simul.test = [];
% for j=1:length(decision_nodes_array)
%     for k = 1:param0.n_multirun
%         
%         if(sequential{j,k}.feasible==0)
%             continue;
%         end
% 
%         fprintf('seqnt: %2d,%2d: train auc: %.3f test  auc: %.3f. ',j,k,sequential{j,k}.train_auc,sequential{j,k}.test_auc);
%         fprintf('simul: %2d,%2d: train auc: %.3f test  auc: %.3f\n',j,k,am_data{j,k}{1}.train_auc,am_data{j,k}{1}.test_auc);
%         
%         auc.seq.train(j,k) = sequential{j,k}.train_auc;
%         auc.seq.test(j,k) = sequential{j,k}.test_auc;
%         auc.simul.train(j,k) = am_data{j,k}{1}.train_auc;
%         auc.simul.test(j,k) = am_data{j,k}{1}.test_auc;
%     end
% end
% h = figure;
% width=2;
% set(0,'DefaultAxesLineWidth',width);
% set(0,'DefaultLineLineWidth',width);
% get(0,'Default');
% set(gca,'LineWidth',width);
% boxplot(auc.simul.train',decision_nodes_array); hold on;
% % plot(mean(auc.seq.train'),'go-'); hold off;
% ylabel('Training AUC','FontSize',18);
% xlabel('decision node size','FontSize',18);
% ylim([.5 .65]);
% set(gca,'FontSize',18,'fontWeight','bold');
% set(findall(h,'type','text'),'fontSize',18,'fontWeight','bold');
% % saveas(h,'../draft/training_performance.png');%TEMPORARY
% h = figure;
% width=2;
% set(0,'DefaultAxesLineWidth',width);
% set(0,'DefaultLineLineWidth',width);
% get(0,'Default');
% set(gca,'LineWidth',width);
% boxplot(auc.simul.test',decision_nodes_array); hold on;
% % plot(mean(auc.seq.test'),'go-'); hold off;
% xlabel('decision node size','FontSize',18)
% ylabel('Test AUC','FontSize',18);
% ylim([.5 .65]);
% % title('Performance of the two processes on randomly generated decision instances at various training sample sizes')
% set(gca,'FontSize',18,'fontWeight','bold');
% set(findall(h,'type','text'),'fontSize',18,'fontWeight','bold');
% % saveas(h,'../draft/test_performance.png');%TEMPORARY