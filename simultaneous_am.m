%AM: Grad step in lambda and wTRP in pi for an AM

clear all;
format short;

global Lambda_T xPiT gurobilatency routeCostT2 routeInfo iterate_j C1;
global indexIteration  modelNumber numUnlabeled C unLabeled;
global numFeatures C0 C2 trainingdata numTrain;

global prevGurobioutput permutG indexErr;

%Step 1: Loading training and validation/test data.
dprefix = '../../../data/';
load([dprefix 'trainAndTestFull.mat']);
varXTest = var(xTest_o);
xTest_o = (xTest_o - repmat(mean(xTest_o),23217,1))./repmat(sqrt(varXTest),23217,1);
varXTrain = var(xTrain_o);
xTrain_o = (xTrain_o - repmat(mean(xTest_o),23217,1))./repmat(sqrt(varXTest),23217,1);
numFeatures             = 4;
numTrain                = 23217;
testdata                = [xTest_o yTest_o];        %For validation Only.
trainingdata            = [xTrain_o(1:numTrain,:) yTrain_o(1:numTrain)];
%preprocessing to alleviate the probability values.
% index_train_preprocess1 = find(trainingdata(:,4) > 10);
% numTrain                = length(index_train_preprocess1);
% trainingdata            = trainingdata(index_train_preprocess1,:);

C0 = 1; C2 = 0.1;   %Default coefficients of each of the terms in OBJ.

C1arr = [0.005 0.01 0.05 0.1 0.5 1]; %Perfect for 7 node data for Model 1.

%C1arr = [0.005 0.05 0.1 0.2 0.5 1]; %Perfect for 7 node data and Model 2.

%C1arr = [0.05];

for modelNumber=1:1

    for theja2sims = 7:7 %KEEP CHANGING THIS TO LOAD DIFFERENT DATASETS : 2011-02-02
        if      (theja2sims == 6)
            load([dprefix 'SixNodeData.mat']);
        elseif  (theja2sims == 7)
            load([dprefix 'SevenNodeData.mat']);
        elseif  (theja2sims == 8)
            load([dprefix 'EightNodeData.mat']);
        end

        iterate_i=0;iterate_j=0;iterate_k=0;
        gurobilatency = zeros(numUnlabeled, 1);
        % % OPTION3: NM+MILP: Via Fminsearch+Gurobi.
        for iterate_j=1:length(C1arr)
            C1 = C1arr(iterate_j);
            tic
            
            %OPTION10: Alternating minimization
            % lambda(t+1) = min over lambda (total obj given a permutation pi(t))
            % pi(t+1) = min over permutation space given a lambda lambda(t+1)
            
            clear gurobioutput prevGurobioutput;
            
            opts_AM = optimset('display','off','TolFun',1e-6, 'MaxIter', 5000,'MaxFunEvals',10000, 'TolX',1e-6);
            MaxIter = 25;
            Lambda_T = zeros(numFeatures+1,1);
            prevGurobioutput = [zeros(numUnlabeled-1,1) eye(numUnlabeled-1,numUnlabeled-1); 1 zeros(1,numUnlabeled-1)];
            indexErr = 0;
             
            for indexIteration=1:MaxIter
                
                [Lambda_T,fval_AM,exitflag,output_AM] = fminsearch(@am_lambda,Lambda_T,opts_AM);
                
                [gurobilatency,fval_GAM] = am_gurobi(Lambda_T);
                
                routeCostIterationT1T3(indexIteration) = fval_AM;
                LambdaIteration(:,indexIteration) = Lambda_T;
                
                display(['IterationIndex:' num2str(indexIteration) ' Lambda_T:' int2str(Lambda_T') ' perm:' int2str(permutG)]);
                
                if(((indexIteration>1)&(abs(fval_GAM-routeCostT2(indexIteration-1))<= 10^-4)))
                    %&(abs(fval_AM-routeCostIterationT1T3(indexIteration-1))<= 10^-4)))
                    display('Broke because of successive difference being small.');
                     break;
                 elseif (indexErr>MaxIter/5)
                     routeCostT2(indexIteration) = routeCostT2(indexIteration-1);
                     display('Broke because indexErr was greater than MaxIter/5!');
                     break;
                 end
            end
            iterationCount(iterate_j) = indexIteration;
            timeC1_AM(iterate_j) = toc;
            LambdaC1_AM(:,iterate_j) = Lambda_T;
            fvalC1_AM(:,iterate_j) = fval_AM;
            routeinfoAM_C1{iterate_j} = routeInfo; %{indexIteration};
            routeCostAM_T2C1(iterate_j) = routeCostT2(indexIteration);
            %save(strcat(['result_AM_matlab_workspace_Feb7_Alternate_' int2str(modelNumber) '_' int2str(theja2sims) '_' int2str(iterate_j) '.mat']));
            display([num2str(iterate_j) '_' num2str(theja2sims) '_' num2str(modelNumber)]);
        end % End of for loop over C1arr for NM+MILP
    end %choosing between 6/7/8 node data.
%     save(strcat(['result_AM_mat_Feb7_' int2str(modelNumber) '_' int2str(theja2sims) '_summary.mat']));
end % modelNumber

