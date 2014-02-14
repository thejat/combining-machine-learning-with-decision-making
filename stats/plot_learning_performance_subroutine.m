function [] = plot_performance(n_sample_size_pcts,n_multirun,sequential,am_data)



%% Best test performance in terms of AUC
auc.seq.train = [];
auc.simul.train = [];
auc.seq.test = [];
auc.simul.test = [];
for j=1:length(n_sample_size_pcts)
    for k = 1:n_multirun

        fprintf('seqnt: %2d,%2d: train auc: %.3f test  auc: %.3f. ',j,k,sequential{j,k}.train_auc,sequential{j,k}.test_auc);
        temp_am1 = 0;
        temp_am2 = 0;
        for i=1:length(am_data{j,k})
    %         fprintf('simul: %d: train auc: %.3f test  auc: %.3f\n',i,am_data{j}{i}.train_auc,am_data{j}{i}.test_auc);
            temp_am1 = max(temp_am1,am_data{j,k}{i}.train_auc);
            temp_am2 = max(temp_am2,am_data{j,k}{i}.test_auc);
        end
        fprintf('simul: %2d,%2d: train auc: %.3f test  auc: %.3f\n',j,k,temp_am1,temp_am2);
        
        auc.seq.train(j,k) = sequential{j,k}.train_auc;
        auc.seq.test(j,k) = sequential{j,k}.test_auc;
        auc.simul.train(j,k) = temp_am1;
        auc.simul.test(j,k) = temp_am2;
    end
end


% figure(1)
% surf(auc.seq.train);
% figure(2)
% surf(auc.seq.test);
% figure(3)
% surf(auc.simul.train);
% figure(4)
% surf(auc.simul.test);

var_train = var(auc.simul.train');
var_test = var(auc.simul.test');

% figure(1)
% plot(mean(auc.seq.train'),'b'); hold on;
% plot(mean(auc.seq.test'),'b*-');
% plot(mean(auc.simul.train') - 1.96*sqrt(var_train),'g-'); 
% plot(mean(auc.simul.train'),'r'); 
% plot(mean(auc.simul.train') + 1.96*sqrt(var_train),'g-');
% plot(mean(auc.simul.test') - 1.96*sqrt(var_test),'k-');
% plot(mean(auc.simul.test'),'r*-');
% plot(mean(auc.simul.test') + 1.96*sqrt(var_test),'k-');
% hold off;


h = figure;
width=2;
set(0,'DefaultAxesLineWidth',width);
set(0,'DefaultLineLineWidth',width);
get(0,'Default');
set(gca,'LineWidth',width);
%positions = [n_sample_size_pcts n_sample_size_pcts+.02];
%boxplot([auc.simul.train' auc.simul.test'],[1:2*n_sample_size_pcts],'positions',positions);
boxplot(auc.simul.train',n_sample_size_pcts); hold on;
plot(mean(auc.seq.train'),'go-'); hold off;
ylabel('Training AUC','FontSize',18);
xlabel('training sample size (percentage)','FontSize',18)
set(gca,'FontSize',18,'fontWeight','bold');
set(findall(h,'type','text'),'fontSize',18,'fontWeight','bold');
saveas(h,'../draft/training_performance.png');%TEMPORARY
h = figure;
width=2;
set(0,'DefaultAxesLineWidth',width);
set(0,'DefaultLineLineWidth',width);
get(0,'Default');
set(gca,'LineWidth',width);
boxplot(auc.simul.test',n_sample_size_pcts); hold on;
plot(mean(auc.seq.test'),'go-'); hold off;
xlabel('training sample size (percentage)','FontSize',18)
ylabel('Test AUC','FontSize',18);
% title('Performance of the two processes on randomly generated decision instances at various training sample sizes')
set(gca,'FontSize',18,'fontWeight','bold');
set(findall(h,'type','text'),'fontSize',18,'fontWeight','bold');
saveas(h,'../draft/test_performance.png');%TEMPORARY


% %% Routes
% for j=1:length(n_sample_size_pcts)
%     for k = 1:n_multirun
%         fprintf('sequn: %d,%d,0: route: %s\n',j,k,num2str(sequential{j,k}.route));
%         for i=1:length(am_data{j})
%             fprintf('simul: %d,%d,%d: route: %s\n',j,k,i,num2str(am_data{j,k}{i}.route));
%         end
%     end
% end
% %% Forecasted probabilities
% for j=1:length(n_sample_size_pcts)
%     for k = 1:n_multirun
% 
%         fprintf('seqnt forecast %d,%d,0: %s \n',j,k,num2str(sequential{j,k}.forecasted));
%         for i=1:length(am_data{j,k})
%             fprintf('simul forecast %d,%d,%d: %s\n',j,k,i,num2str(am_data{j,k}{i}.forecasted));
%         end
%     end
% end