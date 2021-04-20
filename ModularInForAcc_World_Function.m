function [iliRes, iliAct, err, error, dates] = ModularInForAcc_World_Function(PredictAheadBy, dataMatrix, dates)
%  Give the number of features, and how far ahead we are predicting
numFilesUsed = size(dataMatrix, 2);

%%standardized Data
dataMatrixZ = zscore(dataMatrix);

%%Get Training and Test data
numTimeStepsTrain = floor(0.75*size(dataMatrixZ, 1));
trainData = dataMatrixZ(1:numTimeStepsTrain+1, :);
testData = dataMatrixZ(numTimeStepsTrain:end, :);
dates = dates(numTimeStepsTrain:end, :);

%%Prep predictors
XTrain = trainData(1:end-PredictAheadBy,:)';
YTrain = trainData((PredictAheadBy+1):end,1)';

%%LSTM Network training
numFeatures = numFilesUsed;
numResponses = 1;
%750 hidden units uses for USA data, best for AUS = 835/803/775,
% numHiddenUnits = 750;
numHiddenUnits = 327;
layers = [...
    sequenceInputLayer(numFeatures)
    lstmLayer(numHiddenUnits)
    fullyConnectedLayer(numResponses)
    regressionLayer];

% options = trainingOptions('adam', ...
%     'MaxEpochs', 200, ...
%     'GradientThreshold', 1, ...
%     'InitialLearnRate', 0.005, ...
%     'LearnRateSchedule', 'piecewise', ...
%     'LearnRateDropPeriod', 125, ...
%     'LearnRateDropFactor', 0.1, ...
%     'Verbose', 0, ...
%     'Plots','training-progress');

options = trainingOptions('adam', ...
    'MaxEpochs', 200, ...
    'GradientThreshold', 1, ...
    'InitialLearnRate', 0.005, ...
    'LearnRateSchedule', 'piecewise', ...
    'LearnRateDropPeriod', 125, ...
    'LearnRateDropFactor', 0.1, ...
    'Verbose', 0);


net = trainNetwork(XTrain, YTrain, layers, options);
% Opperations on Trained Network

%Prepare test data
XTest = testData(1:end-PredictAheadBy,:);
YTest = testData((PredictAheadBy+1):end,1);

YPred = predict(net, XTest')';

% figure
% hold on
% plot(YTest)
% plot(YPred)
% xlabel('Weeks')
% ylabel('Z-score of Influenza Positive Viruses')
% legend('actual ', 'predicted')
% hold off

iliRes = (YPred * std(dataMatrix(:,1))) + mean(dataMatrix(:,1));
iliAct = dataMatrix(numTimeStepsTrain+PredictAheadBy:end,1);

err = sqrt(immse(double(iliRes), iliAct));

% figure
% hold on
% plot(iliAct)
% plot(iliRes, 'r')
% plot(iliRes+err, 'r--')
% plot(iliRes-err, 'r--')
% xlabel('Weeks')
% ylabel('ILI Cases')
% legend({'actual ', 'predicted', 'confidence intervals'}, 'Location', 'northwest')
% hold off

mapeSum = 0;
sum2 = 0;
for yRow = 1: length(YPred)
    mapeSum = mapeSum + abs(iliRes(yRow) - iliAct(yRow));
    sum2 = sum2 + (iliRes(yRow) + iliAct(yRow));
end
error = mapeSum/sum2;
