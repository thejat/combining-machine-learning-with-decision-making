function [] = plot_learning_performance(result_path,cost_model_type)


%%
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

%%
plot_learning_performance_subroutine(n_sample_size_pcts,n_multirun,sequential,am_data);


% AUC of an all -1 guesser: No ordering means bad guesser.
% [baseline_train_auc,baseline_test_auc] = performance_of_learning(...
%                             param1.Y_trn,...
%                             -1*ones(size(param1.Y_trn,1),1),...
%                             param1.Y_val,...
%                             -1*ones(size(param1.Y_trn,1),1))