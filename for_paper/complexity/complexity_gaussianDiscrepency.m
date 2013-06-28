%2011-05-14 finds discrepency measure and empirical rademacher complexity for constrained linear
%function classs by performing optimization multiple times. 2D example
%only.

%Step 1: Generating synthetic data
%Generating Data 2 gaussian clusters (2*N points with N positivs and N negatives)
%splitting into 2 parts: training will contain 2*Ntrain examples.
clc;
clear all;
close all;


global trainingdata nSamples enable_linear_constraint discrepencyMeasure_find_functionFlag sigmaVec;
dimLambda = 3;
Narr = [10 20 50 100 200 500 1000 2000];
nRuns = 30;
discrepencyMeasure_find = 1;
rademacherMeasure_find = 1;
discrepencyMeasure_find_functionFlag = 0;

for i=1:length(Narr)

    nSamples = Narr(i)*2;
    YnSamples = [ones(nSamples/2,1); -ones(nSamples/2,1)];

    for j=1:nRuns        
        XnSamples = [YnSamples/2 + randn(nSamples,1)/1.5  YnSamples/2-randn(nSamples,1)/1.5];
        trainingdata = [XnSamples YnSamples];

        
        if(discrepencyMeasure_find == 1)
            discrepencyMeasure_find_functionFlag = 1;
            
            enable_linear_constraint = 0;

            [lambda,fval,exitflag,output] = fmincon(@myfun,zeros(dimLambda,1),[],[],[],[],[],[],@mycon);
            discrepencyF(i,j) = -fval; 
            discrepencyFSol(i,j,:) = lambda;

            enable_linear_constraint = 1;

            [lambda,fval,exitflag,output] = fmincon(@myfun,zeros(dimLambda,1),[],[],[],[],[],[],@mycon);
            discrepencyFConstr(i,j) = -fval; 
            discrepencyFConstrSol(i,j,:) = lambda;
        end
        if(rademacherMeasure_find == 1)
            discrepencyMeasure_find_functionFlag = 0;
            
            for k=1:30
                sigmaVec = round(rand(nSamples,1)); % Bernoulli random variable.
                
                enable_linear_constraint = 0;
                [lambda,fval,exitflag,output] = fmincon(@myfun,zeros(dimLambda,1),[],[],[],[],[],[],@mycon);
           
                rademacherF(i,j,k) = -fval; 
                rademacherFSol(i,j,k,:) = lambda;

                enable_linear_constraint = 1;

                [lambda,fval,exitflag,output] = fmincon(@myfun,zeros(dimLambda,1),[],[],[],[],[],[],@mycon);
                rademacherFConstr(i,j,k) = -fval; 
                rademacherFConstrSol(i,j,k,:) = lambda;
            end
        end
    end
    
    if(discrepencyMeasure_find == 1)
        discrepencyFE(i) = mean(discrepencyF(i,:));
        discrepencyFConstrE(i) = mean(discrepencyFConstr(i,:));
    end
    if(rademacherMeasure_find == 1)
        rademacherFEE(i) = mean(mean(rademacherF(i,:,:)));
        rademacherFConstrEE(i) = mean(mean(rademacherFConstr(i,:,:)));
    end
end

if(discrepencyMeasure_find == 1)
    figure; plot(Narr,discrepencyFE,'b*-');
    hold on; plot(Narr,discrepencyFConstrE,'r.-'); 
    title('Discrepency measure as a function of sample size');
    legend('original','constrained');
    hold off;
end
if(rademacherMeasure_find == 1)
    figure; plot(Narr,rademacherFEE,'b*-');
    hold on; plot(Narr,rademacherFConstrEE,'r.-'); 
    title('Empirical rademacher complexity as a function of sample size');
    legend('original','constrained');
    hold off;
end

%ADDITIONAL 1: Plotting Training data
%
% indexPosSample = find(YnSamples == 1);
% indexNegSample = find(YnSamples == -1);
% trainingdata_pos = trainingdata(indexPosSample,:);
% trainingdata_neg = trainingdata(indexNegSample,:);
% figure; plot(trainingdata_pos(:,1),trainingdata_pos(:,2),'b.'); hold on;
% plot(trainingdata_neg(:,1),trainingdata_neg(:,2),'g.'); hold off;

%ADDITIONAL 2: Discrepency Surface for 2D lambda. 
% The third coordinate has no affect on
% the optimization, but does have an affect on the value.
%
% coeff = (2/nSamples)*(sum(trainingdata(1:nSamples/2,1:2)) - sum(trainingdata(nSamples/2+1:end,1:2)));
% Lambda1Arr = -1:0.1:1;
% Lambda2Arr = -1:0.1:1;
% for i=1:length(Lambda1Arr)
%     for j=1:length(Lambda2Arr)
%          discrepencySurf(i,j) = coeff(1)*Lambda1Arr(i) + coeff(2)*Lambda2Arr(j);
%     end
% end
% surf(Lambda1Arr,Lambda2Arr,discrepencySurf);