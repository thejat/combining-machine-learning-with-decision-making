function lossVal = am_lambda(Lambda)

global numUnlabeled unLabeled numFeatures C0 C2 trainingdata numTrain;
global gurobilatency modelNumber C1;


%Given xPiT
%use it in the cost for fminsearch.

fun1 = @(lambdafun)(1./(1+exp(-(unLabeled(:,1:numFeatures)*lambdafun(1:numFeatures) + lambdafun(end))))');
fun2 = @(lambdafun)(log(1+exp(unLabeled(:,1:numFeatures)*lambdafun(1:numFeatures) + lambdafun(end)))');

tempG_1 = fun1(Lambda);
tempG_2 = fun2(Lambda);
funQ = 0;
if (modelNumber==1)
    for tempG_3 = 1:numUnlabeled
        funQ = funQ + tempG_1(tempG_3)*gurobilatency(tempG_3); % For Model 1
    end
elseif (modelNumber==2)
    for tempG_3 = 1:numUnlabeled
        funQ = funQ + tempG_2(tempG_3)*gurobilatency(tempG_3); % For Model 1
    end
end

lossVal_1 = C0*sum(log(1+(exp(-([trainingdata(:,1:numFeatures) ones(numTrain,1)]*Lambda).*trainingdata(:,end)))));
lossVal_2 = C2*norm(Lambda)^2;
lossVal_3 = C1* funQ;
lossVal = lossVal_1 + lossVal_2 + lossVal_3;