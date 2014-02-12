function [sequential_new,am_data_new] = do_patch_work(...
                                            sequential_old,...
                                            am_data_old,...
                                            n_sample_size_pcts_old,...
                                            sequential_addendum,...
                                            am_data_addendum,...
                                            n_sample_size_pcts_addendum)

sequential_new = sequential_old;
am_data_new = am_data_old;


for i=1:length(n_sample_size_pcts_addendum)
    clear idx
    idx = find(abs(n_sample_size_pcts_old-n_sample_size_pcts_addendum(i))<10^-5);
    fprintf('Iserting at row %d\n',idx);
    for k=1:size(sequential_addendum,2)
        sequential_new{idx,k} = sequential_addendum{i,k};
        am_data_new{idx,k} = am_data_addendum{i,k};
    end
end


