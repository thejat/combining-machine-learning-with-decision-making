function [] = plot_learning_performance(result_path,cost_model_type)


[am_data,sequential,param0,n_sample_size_pcts] = do_patch_work_learning(result_path,cost_model_type);


%%
plot_learning_performance_subroutine(n_sample_size_pcts,param0.n_multirun,sequential,am_data,cost_model_type);


% AUC of an all -1 guesser: No ordering means bad guesser.
% [baseline_train_auc,baseline_test_auc] = performance_of_learning(...
%                             param1.Y_trn,...
%                             -1*ones(size(param1.Y_trn,1),1),...
%                             param1.Y_val,...
%                             -1*ones(size(param1.Y_trn,1),1))