function foldLabels = get_fold_labels(n_sample,nfolds)
%This function uses randomness to create random folds of data

idxs = randperm(n_sample);
foldLabels = zeros(length(idxs),1);
sampleLabel = 1;
for i = 1:length(idxs)
    foldLabels(idxs(i)) = sampleLabel;
    sampleLabel = sampleLabel + 1;
    if ( sampleLabel > nfolds)
       sampleLabel = 1;
    end
end