%Main: calls joint_ampl

%clc;
clear all;
%close all;
format short;


%Step 1: Loading training and validation/test data.

dprefix = '../../../data/';
load([dprefix 'trainAndTestFull.mat']);
varXTest = var(xTest_o);
xTest_o = (xTest_o - repmat(mean(xTest_o),23217,1))./repmat(sqrt(varXTest),23217,1);
varXTrain = var(xTrain_o);
xTrain_o = (xTrain_o - repmat(mean(xTrain_o),23217,1))./repmat(sqrt(varXTrain),23217,1);
numFeatures             = 4;
numTrain                = 23217;
testdata                = [xTest_o yTest_o];        %For validation Only.
trainingdata            = [xTrain_o(1:numTrain,:) yTrain_o(1:numTrain)];
%preprocessing to alleviate the probability values.
% index_train_preprocess1 = find(trainingdata(:,4) > 10);
% numTrain                = length(index_train_preprocess1);
% trainingdata            = trainingdata(index_train_preprocess1,:);


for modelNumber=2:2

    for theja2sims = 7:7 %KEEP CHANGING THIS TO LOAD DIFFERENT DATASETS : 2011-02-02
        if      (theja2sims == 6)
            load([dprefix 'SixNodeData.mat']);
        elseif  (theja2sims == 7)
            load([dprefix 'SevenNodeData.mat']);
            if(modelNumber ==1)
                %C1arr =  [0.005 0.01 0.05 0.1 0.5 1];%
                %C1arr = [0.85];
            elseif (modelNumber==2)
                clear C1arr;
                %C1arr =  [0.005 0.05 0.1 0.2 0.5 1];%
                %C1arr = [0.15 0.85];
                C1arr = [0.85];
            end
        elseif  (theja2sims == 8)
            load([dprefix 'EightNodeData.mat']);
        end
        

        C0 = 1; C1 = 1; C2 = 0.1;   %Default coefficients of each of the terms in OBJ.

        iterate_i=0;iterate_j=0;iterate_k=0;

        %OPTION2: MINLP: via AMPL+BONMIN
        for iterate_j=1:length(C1arr)
            C1 = C1arr(iterate_j);
            tic
            joint_ampl; % run ampl ampl_combined.pl on commandline. IMPORTANT: CHOOSE MODEL1 or 2
            
            [status,result] = system(['ampl ampl_combinedModel' int2str(modelNumber) '.pl'])%system('cat ./misc_files/temporary.txt');
            filenameSaveBonmin = strcat(['resultC1_Joint20110204_' int2str(modelNumber) '_' int2str(theja2sims) '_' int2str(iterate_j) '.txt']);
            dlmwrite(filenameSaveBonmin,result,'delimiter', '');
            string = ['awk ''/lambda/, /;/'' ' filenameSaveBonmin ' | awk ''/[0-9]/'' | awk ''{print $2}'''];
            [status,LambdaAWK] = system(string);
            toc
            
            timeC1(iterate_j) = toc;
            statusC1{iterate_j} = status;   %Not pertinent
            resultC1{iterate_j} = result;   %Not pertinent
            LambdaC1(:,iterate_j) = str2num(LambdaAWK);
            LambdaC1(:,iterate_j) = [LambdaC1(2:end,iterate_j) ; LambdaC1(1,iterate_j)];
            testlossC1(iterate_j) =  sum(log(1+exp(-(testdata(:,end).*(testdata(:,1:numFeatures)*LambdaC1(1:numFeatures,iterate_j) + LambdaC1(end,iterate_j))))));
            traininglossC1(iterate_j) = sum(log(1+exp(-(trainingdata(:,end).*(trainingdata(:,1:numFeatures)*LambdaC1(1:numFeatures,iterate_j) + LambdaC1(end,iterate_j))))));
            qC1(iterate_j,:) =1./(1+exp(-(unLabeled(:,1:numFeatures)*LambdaC1(1:numFeatures,iterate_j) + LambdaC1(end,iterate_j))))';       
        end % End of for loop over C1arr for NM+MILP
        figure;plot(testlossC1(:),'r.'); %hold on;
        figure;plot(traininglossC1(:),'b*'); %hold off;
        save(strcat(['result_matlab_workspace_model' int2str(modelNumber) '_Feb4_Joint_' int2str(theja2sims) '.mat']));
        clear timeC1 statusC1 resultC1 LambdaC1 testlossC1 traininglossC1 qC1;


    end %choosing between 6/7/8 node data.

end