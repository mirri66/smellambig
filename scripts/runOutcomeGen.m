% random trial payment outcome generator
% This script takes one trial from the subject's trials
% and draws a random trial to count for real. Then the outcome of that
% choice is computed.

function [payout] = runOutcomeGen(subjNo)

RandStream.setDefaultStream(RandStream('mt19937ar','seed',sum(100*clock)));

%% CHANGE THESE
xx.outcomeCol = 12;


dataFile=['smellambig' num2str(subjNo) '.mat'];

if exist(dataFile) == 0
    fprintf('datafile missing?');
elseif exist(dataFile) >0
    r=load(dataFile);
    trials = r.data.HuettelData;
end


randTrial=randi(size(trials,1));

payout = trials(randTrial,xx.outcomeCol)/10; % pay a tenth



