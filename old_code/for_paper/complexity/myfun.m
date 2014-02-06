%function which computes the vaue at a position lambda
function f = myfun(lambda)

global trainingdata nSamples discrepencyMeasure_find_functionFlag sigmaVec;

lambdaTx = [trainingdata(:,1:2) ones(nSamples,1)] *lambda;


if(discrepencyMeasure_find_functionFlag ==1)
%discrepency

    f = (2/nSamples)*(sum(lambdaTx(1:nSamples/2)) - sum(lambdaTx(nSamples/2+1:end)));
    f = -f; %to support maximization. Will be negated back after a sol has been found.
else
%rademacher
    f = (2/nSamples)*(sum(sigmaVec.*lambdaTx));
    f = -f; %to support maximization. Will be negated back after a sol has been found.
end

