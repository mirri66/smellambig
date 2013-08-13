% estimate beta and alpha from huettel risk task responses

% need to address:
% - initial estimates in fminsearch, how to choose?
% - equations make sense?
% - test on more than 4 trials..
% - confidence param? range of possible beta and alpha?

function [b_fit,a_fit]=HuettelRiskEstErich(subjNo, numTrialsPer)

format long g
% constants
xx.option1typeCol = 1; % 1 certain, 2 risk, 3 ambig
xx.option1val1Col = 2;
xx.option1val2Col = 3;
xx.option1probCol = 4;
xx.option2typeCol = 5;
xx.option2val1Col = 6;
xx.option2val2Col = 7;
xx.option2probCol = 8;
xx.keyCol=9;
xx.RTCol=10;
xx.choseCol = 11;
xx.outcomeCol = 12;
xx.nonChosenOutcomeCol = 13;
xx.choiceOnsetCol = 14;
xx.choseOptionTimeCol = 15;
xx.outcomeShownCol = 16;

nIter=100;

% read in data, get subject trials
cd ../data
filename = ['smellambig' num2str(subjNo)];
data = load(filename);
trialdata = data.data.HuettelData;

% %%% beta first (risk, no ambiguity) %%% %
idx = [ones(numTrialsPer,1); zeros(numTrialsPer,1)];
riskIdx = Shuffle(idx);
fprintf('idx: %g \n', size(riskIdx))


% find array of relevant trials
riskTrials = [];

% if option 1 type is certain or risky AND option 2 type is certain or risky, include this trial
for n = 1:size(trialdata,1)
    if (trialdata(n,xx.option1typeCol)==1 || trialdata(n,xx.option1typeCol)==2) && (trialdata(n,xx.option2typeCol)==1 || trialdata(n,xx.option2typeCol)==2 )
        riskTrials=[riskTrials;trialdata(n,:)];
        
    end
    
end

rcount = 0;
for n=1:size(riskTrials,1)
    if(riskIdx(n)==1 && rcount<numTrialsPer)
        riskTrials=[riskTrials;trialdata(n,:)];
        rcount=rcount+1;
    else
        break;
    end
end

% initialize
% upper lower bounds
bUpperBound = 10;
bLowerBound = -1;

wrongGuessB_best = 1;
for i = 1:nIter
    %fprintf('b iter: %g \n', i)
    % initialize out or range
    b=bUpperBound+10;
    while (b>bUpperBound || b<bLowerBound) % while b is out of bounds
        [b,wrongGuessB]=fminsearch(@(b)findb(b,riskTrials,xx),unifrnd(bLowerBound,bUpperBound));
    end
    
    if wrongGuessB < wrongGuessB_best
        b_fit = b;
        wrongGuessB_best = wrongGuessB;
    end
    %fprintf('b: %g, b_fit: %g\n',b,b_fit)
end
%plot?

% %%% now alpha %%% %
% find array of relevant trials
ambigTrials = [];
idx = [ones(numTrialsPer,1); zeros(numTrialsPer,1)];
ambigIdx = Shuffle(idx);
% if option 1 type is certain or ambiguous AND option 2 type is certain or ambiguous, include this trial
for n = 1:size(trialdata,1)
    if (trialdata(n,xx.option1typeCol)==1 || trialdata(n,xx.option1typeCol)==3) && (trialdata(n,xx.option2typeCol)==1 || trialdata(n,xx.option2typeCol)==3 )
        ambigTrials=[ambigTrials;trialdata(n,:)];
    end
    
end

acount = 0;
for n = 1:size(ambigTrials,1)
    if(ambigIdx(n)==1 && acount<numTrialsPer)
        ambigTrials=[ambigTrials;trialdata(n,:)];
        acount = acount+1;
    else
        break;
    end
end



% upper lower bounds
aUpperBound = 1;
aLowerBound = 0;
wrongGuessA_best = 1;

for i = 1:nIter
    %fprintf('a iter: %g \n', i)
    % initialize out or range
    a=aUpperBound+10;
    while (a>aUpperBound || a<aLowerBound) % while a is out of bounds
        [a, wrongGuessA]=fminsearch(@(a)finda(a,b_fit,ambigTrials,xx),unifrnd(aLowerBound,aUpperBound));
    end
    if wrongGuessA < wrongGuessA_best
        a_fit = a;
        wrongGuessA_best = wrongGuessA;
    end
    
end
% the end
cd ../scripts
end

function pWrongGuess = findb(b,riskTrials,xx)
corrGuess=0; % init
for n = 1:size(riskTrials,1) % utility of each choice given a certain beta
    o1u = riskTrials(n,xx.option1val1Col)^b * riskTrials(n,xx.option1probCol) + riskTrials(n,xx.option1val2Col)^b * (1-riskTrials(n,xx.option1probCol));
    o2u = riskTrials(n,xx.option2val1Col)^b * riskTrials(n,xx.option2probCol) + riskTrials(n,xx.option2val2Col)^b * (1-riskTrials(n,xx.option2probCol));
    
    % fprintf('o1v1: %g, o1p1: %g, o2v2: %g, o1p2: %g\n',riskTrials(n,xx.option1val1Col),riskTrials(n,xx.option1probCol), riskTrials(n,xx.option1val2Col),(1-riskTrials(n,xx.option1probCol)))
    
    % was guess correct, i.e. predicted utility of chosen more than the
    % unchosen option's predicted utility?
    if (o1u > o2u && riskTrials(n,xx.choseCol)== 1) || (o1u < o2u && riskTrials(n,xx.choseCol)== 2) % correct
        corrGuess = corrGuess+1;
        %     elseif (o1u < o2u && riskTrials(n,xx.choseCol)==1)
        %
        %     elseif (o1u > o2u && riskTrials(n,xx.choseCol)==2)
        %
        % fprintf('option 1 util: %g, option 2 util: %g, diff: %g\n',o1u,o2u, o1u-o2u)
    end
    
end
pWrongGuess = 1-corrGuess/size(riskTrials,1);
%fprintf('pWrongGuess for b: %g\n', pWrongGuess)

end

function pWrongGuess = finda(a,b,ambigTrials,xx)
corrGuess=0; % init
for n = 1:size(ambigTrials,1) % utility of each choice given a certain beta and alpha *** VAL2 MUST BE ZERO?!
    % utility option 1
    if ambigTrials(n,xx.option1typeCol) == 1 || ambigTrials(n,xx.option1typeCol) == 2 % certain or risky
        o1u = ambigTrials(n,xx.option1val1Col)^b * ambigTrials(n,xx.option1probCol) + ambigTrials(n,xx.option1val2Col)^b * (1-ambigTrials(n,xx.option1probCol));
    elseif ambigTrials(n,xx.option1typeCol) == 3 % ambig
        o1u = (1-a)*(ambigTrials(n,xx.option1val1Col)^b) + a*ambigTrials(n,xx.option1val2Col)^b;
    end
    % utility option 2
    if ambigTrials(n,xx.option2typeCol) == 1 || ambigTrials(n,xx.option2typeCol) == 2 % certain or risky
        o2u = ambigTrials(n,xx.option2val1Col)^b * ambigTrials(n,xx.option2probCol) + ambigTrials(n,xx.option2val2Col)^b * (1-ambigTrials(n,xx.option2probCol));
    elseif ambigTrials(n,xx.option2typeCol) == 3 % ambig
        o2u = (1-a)*(ambigTrials(n,xx.option2val1Col)^b) + a*ambigTrials(n,xx.option2val2Col)^b;
    end
    
    % was guess correct, i.e. predicted utivality of chosen more than the
    % unchosen option's predicted utility?
    if (o1u > o2u && ambigTrials(n,xx.choseCol)== 1) || (o1u < o2u && ambigTrials(n,xx.choseCol)== 2) % correct
        corrGuess = corrGuess+1;
       % fprintf('option1: %g, option 2: %g, diff:%g\n',o1u,o2u,o1u-o2u)
    end
    
end
pWrongGuess = 1-corrGuess/size(ambigTrials,1);
%fprintf('pWrongGuess for a: %g, bval: %g\n', pWrongGuess,ambigTrials(n,xx.option2val1Col)^b)

end