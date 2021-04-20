function [iliRes, iliAct, err, error, dates] = covid_predictor(PredictAheadBy, dataMatrix, dates)  
% case_data = readtable("us-states.csv");
% case_data = case_data(strcmp(case_data.state, state), :);
% case_data = table2array(case_data);
% b = readtable("caLOS.csv");
% b = b(3:end,2);
% c = readtable("caLOT.csv");
% c = c(3:end,2);

% sum = 0;
% weeklist = [];
% for nat = 1:length(case_data.cases)
%     if mod(nat, 7) == 0
%         weeklist = [weeklist; sum + case_data.cases(nat)];
%         sum = 0;
%     else
%         sum = sum + case_data.cases(nat);
%     end
% end

% dataMatrix = [weeklist, dataMatrix];

zs = zscore(dataMatrix);

figure
hold on
plot(zs)
xlabel('Weeks')
ylabel('Z-score')
legend('cali cases', 'Coronavirus Test')
hold off
%%
numFilesUsed = size(dataMatrix, 2);
% PredictAheadBy = 3;

%%Get Training and Test data
numTimeStepsTrain = floor(0.75*size(zs, 1));
trainData = zs(1:numTimeStepsTrain+1, :);
testData = zs(numTimeStepsTrain:end, :);
dates = dates(numTimeStepsTrain:end, :);

%%Prep predictors
XTrain = trainData(1:end-PredictAheadBy,:)';
YTrain = trainData((PredictAheadBy+1):end,1)';
 
%%LSTM Network training
numFeatures = numFilesUsed;
numResponses = 1;
numHiddenUnits = 327;
layers = [...
    sequenceInputLayer(numFeatures)
    lstmLayer(numHiddenUnits)
    fullyConnectedLayer(numResponses)
    regressionLayer];

options = trainingOptions('adam', ...
    'MaxEpochs', 200, ...
    'GradientThreshold', 1, ...
    'InitialLearnRate', 0.005, ...
    'LearnRateSchedule', 'piecewise', ...
    'LearnRateDropPeriod', 125, ...
    'LearnRateDropFactor', 0.1, ...
    'Verbose', 0, ...
    'Plots','training-progress');

net = trainNetwork(XTrain, YTrain, layers, options);
%% Opperations on Trained Network

%%Prepare test data
XTest = testData(1:end-PredictAheadBy,:);
YTest = testData((PredictAheadBy+1):end,1);

YPred = predict(net, XTest')';

figure
hold on
plot(YTest)
plot(YPred)
xlabel('Weeks')
ylabel('Z-score')
legend('actual ', 'predicted')
hold off

iliRes = (YPred * std(dataMatrix(:,1))) + mean(dataMatrix(:,1));
iliAct = dataMatrix(numTimeStepsTrain+PredictAheadBy:end,1);

err = sqrt(immse(double(iliRes), iliAct));

figure
hold on
plot(iliAct)
plot(iliRes, 'r')
plot(iliRes+err, 'r--')
plot(iliRes-err, 'r--')
xlabel('Weeks')
ylabel('COVID-19 Cases')
legend({'actual ', 'predicted', 'confidence intervals'}, 'Location', 'northwest')
hold off

mapeSum = 0;
sum2 = 0;
for yRow = 1: length(YPred)
    mapeSum = mapeSum + abs(iliRes(yRow) - iliAct(yRow));
    sum2 = sum2 + (iliRes(yRow) + iliAct(yRow));
end
error = mapeSum/sum2;