function [train_auc,test_auc] = performance_of_learning(Y_trn,Y_hat_trn,Y_val,Y_hat_val)
%function returns the insample (train) auc and out-of-sample (test) auc
%also plots the ROC curve.


%performance plots for training
[temp_x,temp_y,~,train_auc] = perfcurve(Y_trn,Y_hat_trn,1);
%figure;plot(temp_x,temp_y); hold on; plot(temp_x,temp_x,'r'); title(['Training ROC with AUC:' num2str(train_auc)]);
clear temp_x temp_y

%performance plots for testing
[temp_x,temp_y,~,test_auc] = perfcurve(Y_val,Y_hat_val,1);
%figure;plot(temp_x,temp_y); hold on; plot(temp_x,temp_x,'r'); title(['Test ROC with AUC:' num2str(test_auc)]);
