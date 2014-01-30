function betaCVX = support_vector_regression(X,Y,C)
epsil = 0.1;

% cvx_begin quiet
%    variables w(length(X(1,:))-1) b xi(length(X(:,1))) xip(length(X(:,1)))
%    minimize 1/2*sum(w.*w) + C*(sum(xi) + sum(xip))
%    subject to 
%    Y- (X(:,1:end-1)*w + b) <= epsil + xi;
%    (X(:,1:end-1)*w + b) - Y <= epsil + xip;
%    xi >= 0;
%    xip >= 0;
% cvx_end
% betaCVX = [w;b];


% libsvm version
addpath('/Users/theja/Downloads/local/libsvm/matlab');
options_string = ['-t 0 -s 3 -p ' num2str(epsil) ' -c ' num2str(C)];
%-t 0 for linear, 1 for poly, 2 for rbf, 3 for sigmoid
%-s 3 for eps-SVR. Other options not relevant.
%-c Cost C
%-p epsilon of the epsilon-SVR algo
model = svmtrain(Y,X(:,1:end-1),options_string);
w = (model.sv_coef' * full(model.SVs));
bias = -model.rho;
betaCVX = [w bias]';



%% Debug code for libsvm after doing a make in that ..libsvm/matlab/ directory (edit Makefile if needed).
% clear all;
% [heart_scale_label, heart_scale_inst] = libsvmread('/Users/theja/Downloads/local/libsvm/heart_scale');
% model = svmtrain(heart_scale_label, heart_scale_inst, '-c 1 -t 0 -g 0.07');
% [predict_label, accuracy, dec_values] = svmpredict(heart_scale_label, heart_scale_inst, model); % test the training data
% w = (model.sv_coef' * full(model.SVs));
% bias = -model.rho;
% betaCVX = [w bias]';
% predict_label2 = sign([heart_scale_inst ones(size(heart_scale_inst,1),1)]*betaCVX);
