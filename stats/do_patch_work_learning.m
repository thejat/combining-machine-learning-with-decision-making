%patches together different sets of experiments.
function [am_data,sequential,param0,n_sample_size_pcts] = do_patch_work_learning(result_path,cost_model_type)

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

%Hack to include n_multirum in the param0 structure which is needed for
%subsequent plotting routines. Should not be necessary with the latest
%mloc_multirun code.
if(exist('n_multirun'))
    param0.n_multirun = n_multirun;
end