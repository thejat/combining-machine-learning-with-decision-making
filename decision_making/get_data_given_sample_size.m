function param_new = get_data_given_sample_size(param,n_sample_size_pct)


param_new = param;


[param_new.X_trn,param_new.Y_trn,...
    param_new.X_val,param_new.Y_val,...
    param_new.n_features,param_new.latLongs] = ...
            get_bronx_data(n_sample_size_pct); %read Bronx data (features, labels, lats,longs)

