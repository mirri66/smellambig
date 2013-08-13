% smellHuettelRisk
% -----------
% risky vs certain vs ambiguous choices, under the influence of smell
% usage: data = smellHuettelRisk(c)
%
% arguments:
%   c -- see exptSetup
%
% output:
%   b,a - beta, alpha
%   datamat - details individual trials
%
% reference: Huettel et al. (2006), Neural Signatures of Economic
%   Preferences for Risk and Ambiguity. Neuron 49, 765-775
%
% author: Grace (tsmgrace@gmail.com) 2013

function [datamat] = smellHuettelRisk(c,v)
csvfile = [c.exptname num2str(c.subjNo) '.csv'];

scanner = 0;
practice = 0;
xx.odorFlag = v.odorFlag;
xx.debugFlag=1; % 1 for debug mode - gets rid of a lot of waiting

% % scents
% 1 - lemon
% 2 - vanillaice
% 3 - trash
% 4 - onionoil
% 5 - greentea
% 6 - air

% Print a loading screen
DrawFormattedText(c.Window, 'Loading -- the experiment will begin shortly','center','center',250);
Screen('Flip',c.Window);

% some constants for storing data
% xx contains variables that need to be passed to other functions
xx.option1typeCol = 1;
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
% additional smell columns
xx.odorCondCol = 17;
xx.odorOnsetCol = 18;
xx.odorOffsetCol = 19;

% ss contains column numbers for reading the stimulus file
ss.option1typeCol = 1;
ss.option1val1Col = 2;
ss.option1val2Col = 3;
ss.option1probCol = 4;
ss.option2typeCol = 5;
ss.option2val1Col = 6;
ss.option2val2Col = 7;
ss.option2probCol = 8;
ss.scentCondCol = 9;


% scent channels that will be used
scentArr = [25:30];
flowrate=10; % max 400
odorOn=6; % how long odor should be presented
xx.ISI=1.5;

% additional graphics stuff
c.hPosR = 3*c.scrsz(3)/5;
c.hPosL = c.scrsz(3)/5;
c.hPosition = c.scrsz(3);
c.vPosition = c.scrsz(4);
c.instr_X = 2.5*c.scrsz(3)/7;
c.radius = c.scrsz(3)/7;
c.outerradius = 0.1; % factor by which radius should be expanded for outer ring
c.circR = .9*c.scrsz(3); %horizontal positioning for right circle
c.circL = c.scrsz(3)/3; %horizontal positioning for left circle

c.LriskHDisplace=0.7; % factor by which the certain and left risky options get displaced horizontally
c.riskVDisplace=0.7; % factor by which risky options get displaced vertically

c.blackText = [0 0 0];
c.borderColor = [250 250 150];
c.rouletteRadius = c.outerradius*c.radius/2;

xx.brightness =125;

%c.frameRate = frameRate;
c.TR=2;

xx.startTime =GetSecs;
% trials
% option 1 type, option 1 val 1, option 1 val 2, option 1 prob of val 1
% option 2 type, option 2 val 1, option 2 val 2, option 2 prob of val 1
% option types: 1 = certain, 2 = risky, 3 = ambig

if xx.debugFlag==1
    %     trialMat = [
    %         2 20 8 0.5 1 12 0 1 % certain vs risky
    %         2 20 4 0.75 2 50 10 0.25 % risky vs risky
    %         3 35 0 0.25 1 12 0 1 % ambig vs certain
    %         3 35 0 0.25 2 20 12 0.25 % ambig vs risky
    %         ];
    
    trialMat=[
        3	0	45	0	1	14	0	1	4	4
        3	45	0	1	1	25	0	1	5	4
        3	15	0	1	1	12	0	1	6	4
        3	0	25	0.25	1	20	0	1	1	4
        3	45	0	0.5	1	0	25	0	2	4
        3	50	0	0.5	1	0	5	0	3	4
        3	0	40	1	1	0	10	0	4	4
        3	15	0	0	1	0	14	0	5	4
        ];
    
    
else
    cd(c.path.stim)
    %trialsFile='huettelvals_matlab.xls';
    % columns: 1=o1type, o1v1, o1v2, o1v1p,
    % o2type,o2v1,o2v2,o2prob,scentCond,trialType(Huettel values),
    % see struct 'ss'
    trialsFile='huettelvals_wScents_n120.xls';
    trialMat = xlsread(trialsFile);
    cd(c.path.main)
    
    idx = Shuffle(1:length(trialMat));
    trialMat=trialMat(idx,:);
end



ListenChar(2) %Ctrl-c to enable Matlab keyboard interaction.
HideCursor; % Remember to type ShowCursor or sca later


%% the study::

hSide1 = c.hPosition/2-c.radius;
hSide2 = c.hPosition/2-c.radius;
wrap = 80;
instrCircleVdisplace = c.vPosition/1750;
bottom2h=c.hPosition/6;
bottom2v=15*c.vPosition/18;
bottom1h=c.hPosition/6;
bottom1v=16*c.vPosition/18;

% Instructions
DrawFormattedText(c.Window, ['In this game, you will have the chance to play gambles for real money! '...
    'In each round, you will be asked to indicate your preference between two options. The gambles are presented '...
    'as pies with each slice representing the chance of winning a certain sum of money: the bigger a slice, the more likely the outcome. \n\n'...
    'Press ''3'' to continue.'],'center','center',250,wrap,[],[],2); %changed location
Screen('Flip',c.Window);
GetKey('3#',[],[],-3);

DrawFormattedText(c.Window, ['Some options will lead to a fixed amount of money. For example, when you see a circle like this:'],'center',c.vPosition/9,250,wrap, [],[],1.5);
Screen('FillOval', c.Window, c.borderColor, [c.hPosR-c.radius*c.outerradius, c.vPosition/2-c.radius-c.radius*c.outerradius,c.hPosR+c.radius*2+c.radius*c.outerradius, c.vPosition/2+c.radius+c.radius*c.outerradius])
Screen('FillArc', c.Window, [xx.brightness 0 0], [c.hPosR, c.vPosition/2-c.radius,c.hPosR+c.radius*2, c.vPosition/2+c.radius], 0, 360)
Screen('DrawText', c.Window, ['$' num2str(50,'%#4.2f')], c.hPosR+c.radius*0.65, c.vPosition/2, c.blackText);

DrawFormattedText(c.Window, ['You will get $50 for sure if you choose it.'],'center', bottom2v,250,wrap, [],[],1.5);
DrawFormattedText(c.Window, ['Press ''3'' to continue.'],'center',bottom1v,250,wrap, [],[],1.5);
Screen('Flip',c.Window);
GetKey('3#',[],[],-3);


DrawFormattedText(c.Window, ['Others options will have more than one possible amount of money. If you see a circle like this: '],'center',c.vPosition/9,250,wrap, [],[],1.5);
Screen('FillOval', c.Window, c.borderColor, [c.hPosR-c.radius*c.outerradius, c.vPosition/2-c.radius-c.radius*c.outerradius+instrCircleVdisplace,c.hPosR+c.radius*2+c.radius*c.outerradius, c.vPosition/2+c.radius+c.radius*c.outerradius+instrCircleVdisplace])

Screen('FillArc', c.Window, [xx.brightness 0 0], [c.hPosR, c.vPosition/2-c.radius+instrCircleVdisplace,c.hPosR+c.radius*2, c.vPosition/2+c.radius+instrCircleVdisplace], 0, 0.25*360)
Screen('FillArc', c.Window, [0 xx.brightness 0], [c.hPosR, c.vPosition/2-c.radius+instrCircleVdisplace,c.hPosR+c.radius*2, c.vPosition/2+c.radius+instrCircleVdisplace], 0.25*360, 0.75*360)
Screen('DrawText', c.Window, ['$' num2str(12,'%#4.2f')], c.hPosR+c.LriskHDisplace*c.radius/2, c.vPosition/2-c.riskVDisplace*c.radius/2*((0.25-0.5)/0.25)+instrCircleVdisplace, c.blackText);
Screen('DrawText', c.Window, ['$' num2str(20,'%#4.2f')], c.hPosR+c.radius*1.5*0.8, c.vPosition/2+c.riskVDisplace*c.radius/2*((0.25-0.5)/0.25)+instrCircleVdisplace, c.blackText);

DrawFormattedText(c.Window, ['If you choose this, you will have a 25% chance of winning $20, or a 75% chance of winning $12.'],'center', bottom2v,250,wrap, [],[],1.5);
DrawFormattedText(c.Window, ['Press ''3'' to continue.'],'center',bottom1v+50,250,wrap, [],[],1);
Screen('Flip',c.Window);
GetKey('3#',[],[],-3);

DrawFormattedText(c.Window, ['Sometimes you will not know the probability of winning each amount. When you see a circle like this:'],'center',c.vPosition/9,250,wrap, [],[],1.5);
Screen('FillOval', c.Window, c.borderColor, [c.hPosR-c.radius*c.outerradius, c.vPosition/2-c.radius-c.radius*c.outerradius+instrCircleVdisplace,c.hPosR+c.radius*2+c.radius*c.outerradius, c.vPosition/2+c.radius+c.radius*c.outerradius+instrCircleVdisplace])

Screen('FillOval', c.Window, [100 100 100], [c.hPosR, c.vPosition/2-c.radius+instrCircleVdisplace,c.hPosR+c.radius*2, c.vPosition/2+c.radius+instrCircleVdisplace])
Screen('DrawText', c.Window, '?', c.hPosR+c.radius, c.vPosition/2+instrCircleVdisplace, c.blackText);
Screen('DrawText', c.Window, ['$' num2str(35,'%#4.2f')], c.hPosR-c.radius*c.outerradius, c.vPosition/2-c.radius-c.radius*c.outerradius*2+instrCircleVdisplace, c.textColor);
Screen('DrawText', c.Window, ['$' num2str(0,'%#4.2f')], c.hPosR+2*c.radius+c.radius*c.outerradius, c.vPosition/2+c.radius-c.radius*c.outerradius*2+instrCircleVdisplace, c.textColor);

DrawFormattedText(c.Window, ['If you choose this option, you will have an unknown chance of winning either $35 or $0.'],'center', bottom2v,250,wrap, [],[],1.5);
DrawFormattedText(c.Window, ['Press ''3'' to continue.'],'center',bottom1v+30,250,wrap, [],[],1.5);
Screen('Flip',c.Window);
GetKey('3#',[],[],-3);


DrawFormattedText(c.Window, ['Make your choice by pressing the ''1'' key if you prefer the option on the left, '...
    'or the ''4'' key if you prefer the option on the right.\n\n When you make your choice, '...
    'a blue square will appear around your chosen option. After a delay, a ball will start to spin around your chosen option. '...
    'How much your gamble pays out will be determined by where the ball stops.\n\n There will then be a short delay till the next trial.\n\n'...
    'Press ''3'' to continue.'],'center','center',250,wrap, [],[],2);
Screen('Flip',c.Window);
GetKey('3#',[],[],-3);

if xx.odorFlag == 1
    DrawFormattedText(c.Window, ['Additionally, you will smell some scents during the study. '...
        'For the duration of the experiment, please place your chin on the chin rest such that your nose is near the glass nose piece. '...
        'You might want to adjust the height of your chair now so that you can comfortably hold this position throughout the session.\n\n'...
        'When a scent is being delivered, the word "INHALE" will appear on the screen.' ...
        'Please breathe normally: That is, there is no need to take deeper or longer breaths than normal. '...
        'Conversely, do not hold your breath or reduce your breaths. \n\n '...
        'Press ''3'' to continue.'],'center','center',250, wrap, [],[],1.75);
    Screen('Flip',c.Window);
    GetKey('3#',[],[],-3);
    
    notRushString='Your reaction time will also not affect the amount of time each smell is presented. ';
else
    notRushString='';
end


DrawFormattedText(c.Window, ['How quickly you respond will not change the amount of time you spend playing the game. ' notRushString 'Please do not rush!\n\n '...
    'On the other hand, please do not spend too long on each decision. Try to go with your gut feeling. \n\n'...
    'Press ''3'' to continue.'],'center','center',250, wrap, [],[],1.75);
Screen('Flip',c.Window);
GetKey('3#',[],[],-3);


if practice == 1
    startString='Press ''3'' when you are ready to practice.';
else
    startString='Press ''3'' to begin.';
end

DrawFormattedText(c.Window, ['Out of the choices you make on this task, one will be chosen at random to count for real. '...
    'You will be paid a bonus that is a fraction of the outcome of that trial. \n\n'...
    'Please treat each choice as if it counts for real. Bear in mind that only ONE choice will be selected to count for real, '...
    'therefore treat each choice as if it were the only one being presented to you. \n\n'...
    'Please respond as quickly as possible, and try to go with your gut feeling. \n\n'...
    startString],'center','center',250,wrap, [],[],2);
Screen('Flip',c.Window);
GetKey('3#',[],[],-3);

if practice == 1
    
    
    DrawFormattedText(c.Window, ['There will now be four practice rounds before we start the actual task.\n\n'...
        'Press ''3'' to begin the practice rounds.'],'center','center',250,wrap, [],[],1);
    Screen('Flip',c.Window);
    GetKey('3#',[],[],-3);
    
    if xx.odorFlag == 1
        pracScent1=1; pracScent2=3; pracScent3=2; pracScent4=4;
    end
    
    opt1type = 1;    opt1val1 = 12;    opt1val2 = 0;    opt1prob = 1;    opt2type = 2;    opt2val1 = 8;    opt2val2 = 20;    opt2prob = 0.5;
    if xx.odorFlag == 1
        odor=pracScent1;
        v.setChannel(odor,flowrate);
        DrawFormattedText(c.Window, 'INHALE','center','center',255,100);
        Screen('Flip',c.Window);
        WaitSecs(odorOn-xx.ISI);
        odorOffset = GetSecs;
        
        DrawFormattedText(c.Window, '+','center','center',255,100);
        Screen('Flip',c.Window);
        WaitSecs(xx.ISI);
    end
    pracdata12 = HuettelTrial(c,v,xx,opt1type, opt1val1,opt1val2,opt1prob,opt2type, opt2val1,opt2val2,opt2prob);
    
    opt1type = 1;    opt1val1 = 12;    opt1val2 = 0;    opt1prob = 1;    opt2type = 3;    opt2val1 = 35;    opt2val2 = 0;    opt2prob = 0.5;
    if xx.odorFlag == 1
        odor=pracScent2;
        v.setChannel(odor,flowrate);
        DrawFormattedText(c.Window, 'INHALE','center','center',255,100);
        Screen('Flip',c.Window);
        WaitSecs(odorOn-xx.ISI);
        odorOffset = GetSecs;
        
        DrawFormattedText(c.Window, '+','center','center',255,100);
        Screen('Flip',c.Window);
        WaitSecs(xx.ISI);
    end
    pracdata13 = HuettelTrial(c,v,xx,opt1type, opt1val1,opt1val2,opt1prob,opt2type, opt2val1,opt2val2,opt2prob);
    
    opt1type = 2;    opt1val1 = 4;    opt1val2 = 20;    opt1prob = 0.25;    opt2type = 2;    opt2val1 = 10;    opt2val2 = 50;    opt2prob = 0.75;
    if xx.odorFlag == 1
        odor=pracScent3;
        v.setChannel(odor,flowrate);
        DrawFormattedText(c.Window, 'INHALE','center','center',255,100);
        Screen('Flip',c.Window);
        WaitSecs(odorOn-xx.ISI);
        odorOffset = GetSecs;
        
        DrawFormattedText(c.Window, '+','center','center',255,100);
        Screen('Flip',c.Window);
        WaitSecs(xx.ISI);
    end
    pracdata22 = HuettelTrial(c,v,xx,opt1type, opt1val1,opt1val2,opt1prob,opt2type, opt2val1,opt2val2,opt2prob);
    
    opt1type = 2;    opt1val1 = 12;    opt1val2 = 20;    opt1prob = 0.75;    opt2type = 3;    opt2val1 = 35;    opt2val2 = 0;    opt2prob = 0.25;
    if xx.odorFlag == 1
        odor=pracScent4;
        v.setChannel(odor,flowrate);
        DrawFormattedText(c.Window, 'INHALE','center','center',255,100);
        Screen('Flip',c.Window);
        WaitSecs(odorOn-xx.ISI);
        odorOffset = GetSecs;
        
        DrawFormattedText(c.Window, '+','center','center',255,100);
        Screen('Flip',c.Window);
        WaitSecs(xx.ISI);
    end
    pracdata23 = HuettelTrial(c,v,xx,opt1type, opt1val1,opt1val2,opt1prob,opt2type, opt2val1,opt2val2,opt2prob);
    
    pracmat = [pracdata12; pracdata13; pracdata22; pracdata23];
    %pracsavename = ['smellambig' num2str(c.subjNo) '_prac.mat'];
    %save(pracsavename,'pracmat');
    datamat.pracdata = pracmat;
    
    DrawFormattedText(c.Window, ['You are done with practice! If you have any questions, please ask the experimenter now.'],'center', 'center',250,wrap, [],[],1.5);
    DrawFormattedText(c.Window, ['Otherwise, press ''3'' to begin the task.'],'center',bottom1v,250,wrap, [],[],1.5);%changed height of text
    Screen('Flip',c.Window);
    GetKey('3#',[],[],-3);
    
else
    DrawFormattedText(c.Window, ['The game will begin on the next page. If you have any questions please ask the experimenter now.'], 'center', 'center', 250, wrap, [],[],2);
    DrawFormattedText(c.Window, ['Otherwise, press ''3'' to begin the task.'],'center',bottom1v,250,wrap, [],[],1.5);%changed height of text
    Screen('Flip',c.Window);
    GetKey('3#',[],[],-3);
    
    
end



fprintf('\n\nHuettel Risk/Ambiguity: \n\n')

datamat=[]; %where stuff is actually recorded

%% TASK PROPER



if scanner == 1
    % scanner trigger %%%
    while 1
        % AG1getKey('3#',-3); % deviceNumber -3 means query all
        [status, xx.startTime] = AG1startScan; % startTime corresponds to getSecs in startScan
        fprintf('Status = %d\n',status);
        if status == 0  % successful trigger otherwise try again
            break
        else
            %  Screen(Window,'DrawTexture',blank);
            message = 'Trigger failed, "3" to retry';
            DrawFormattedText(Window,message,'center','center',255);
            Screen(Window,'Flip');
        end
    end
    
elseif scanner == 0
    xx.startTime = GetSecs;
end



for n = 1:size(trialMat,1)
    fprintf('\ntrial %g\n',n)
    opt1type = trialMat(n,ss.option1typeCol);
    opt1val1 = trialMat(n,ss.option1val1Col);
    opt1val2 = trialMat(n,ss.option1val2Col);
    opt1prob = trialMat(n,ss.option1probCol);
    opt2type = trialMat(n,ss.option2typeCol);
    opt2val1 = trialMat(n,ss.option2val1Col);
    opt2val2 = trialMat(n,ss.option2val2Col);
    opt2prob = trialMat(n,ss.option2probCol);
    
    % if odor
    if xx.odorFlag == 1
        odor = trialMat(n,ss.scentCondCol);
        
        ons_start = GetSecs;
        odorOnset = ons_start-xx.startTime;
        fprintf('odor %g, onset: %g\n',odor, odorOnset);
        v.setChannel(odor,flowrate);
        DrawFormattedText(c.Window, 'INHALE','center','center',255,100);
        Screen('Flip',c.Window);
        WaitSecs(odorOn-xx.ISI);
        odorOffset = GetSecs;
        
        DrawFormattedText(c.Window, '+','center','center',255,100);
        Screen('Flip',c.Window);
        WaitSecs(xx.ISI);
        
        
    end
    
    data = HuettelTrial(c,v,xx,opt1type, opt1val1,opt1val2,opt1prob,opt2type, opt2val1,opt2val2,opt2prob);
    
    if xx.odorFlag == 1
        datarow = [data,odor,odorOnset, odorOffset];
    else
        datarow = data;
    end
    datamat = [datamat; datarow];
    %for saving
    csvrow= {datarow};
    IterativeCSVWriter(c.path.data, csvfile, csvrow);
end



end

function data = HuettelTrial(c,v,xx,opt1type, opt1val1,opt1val2,opt1prob,opt2type, opt2val1,opt2val2,opt2prob)
data=[];


% if using huettel xls sheet:
%(in our sheets we always put certain value as option value 1, probability=1, but huettel switches these around)
% this section compensates for that
if opt2type==1 % in huettel sheets certain options are always option 2
    opt2prob=1; % adjust so 100% certain
    if opt2val1>0 % if value 1 is the non zero value
        opt2val1=opt2val1;
    else % otherwise, value 2 is the non zero value
        opt2val1=opt2val2;
    end
    
end
%randomize which side they see option 1 vs 2

sidePres = randi(2);
if sidePres==1
    hSide1=c.circL;
    hSide2=c.circR;
else
    hSide1=c.circR;
    hSide2=c.circL;
end
fprintf('opt1type: %g, opt1val1: %g, opt1val2: %g, opt1prob: %g\n', opt1type, opt1val1, opt1val2, opt1prob);
fprintf('opt2type: %g, opt2val1: %g, opt2val2: %g, opt2prob: %g\n', opt2type, opt2val1, opt2val2, opt2prob);

% %%%% draw choices %%%% %
% outer circles
Screen('FillOval', c.Window, c.borderColor, [hSide2-c.radius*c.outerradius, c.vPosition/2-c.radius-c.radius*c.outerradius,hSide2+c.radius*2+c.radius*c.outerradius, c.vPosition/2+c.radius+c.radius*c.outerradius])
Screen('FillOval', c.Window, c.borderColor, [hSide1-c.radius*c.outerradius, c.vPosition/2-c.radius-c.radius*c.outerradius,hSide1+c.radius*2+c.radius*c.outerradius, c.vPosition/2+c.radius+c.radius*c.outerradius])

% arcs for option 1
color1 = round(rand);
if opt1type == 1 % certain
    Screen('FillArc', c.Window, [xx.brightness*color1 xx.brightness*(1-color1) 0], [hSide1, c.vPosition/2-c.radius,hSide1+c.radius*2, c.vPosition/2+c.radius], 0, opt1prob*360)
    Screen('DrawText', c.Window, ['$' num2str(opt1val1,'%#4.2f')], hSide1+c.radius*c.LriskHDisplace, c.vPosition/2, c.blackText);
elseif opt1type == 2 % risky
    Screen('FillArc', c.Window, [xx.brightness*color1 xx.brightness*(1-color1) 0], [hSide1, c.vPosition/2-c.radius,hSide1+c.radius*2, c.vPosition/2+c.radius], 0, opt1prob*360)
    Screen('FillArc', c.Window, [xx.brightness*(1-color1) xx.brightness*color1 0], [hSide1, c.vPosition/2-c.radius,hSide1+c.radius*2, c.vPosition/2+c.radius], opt1prob*360, (1-opt1prob)*360)
    Screen('DrawText', c.Window, ['$' num2str(opt1val2,'%#4.2f')], hSide1+c.LriskHDisplace*c.radius/2, c.vPosition/2-c.riskVDisplace*c.radius/2*((opt1prob-0.5)/0.25), c.blackText);
    Screen('DrawText', c.Window, ['$' num2str(opt1val1,'%#4.2f')], hSide1+c.radius*1.5*0.8, c.vPosition/2+c.riskVDisplace*c.radius/2*((opt1prob-0.5)/0.25), c.blackText);
elseif opt1type == 3 % ambig
    Screen('FillOval', c.Window, [100 100 100], [hSide1, c.vPosition/2-c.radius,hSide1+c.radius*2, c.vPosition/2+c.radius])
    Screen('DrawText', c.Window, '?', hSide1+c.radius, c.vPosition/2, c.blackText);
    Screen('DrawText', c.Window, ['$' num2str(opt1val2,'%#4.2f')], hSide1-c.radius*c.outerradius, c.vPosition/2-c.radius-c.radius*c.outerradius*2, c.textColor);
    Screen('DrawText', c.Window, ['$' num2str(opt1val1,'%#4.2f')], hSide1+2*c.radius+c.radius*c.outerradius, c.vPosition/2+c.radius-c.radius*c.outerradius*2, c.textColor);
end

% arcs for option 2
color2 = round(rand);
if opt2type == 1 % certain
    Screen('FillArc', c.Window, [xx.brightness*color2 xx.brightness*(1-color2) 0], [hSide2, c.vPosition/2-c.radius,hSide2+c.radius*2, c.vPosition/2+c.radius], 0, opt2prob*360)
    Screen('DrawText', c.Window, ['$' num2str(opt2val1,'%#4.2f')], hSide2+c.radius*c.LriskHDisplace, c.vPosition/2, c.blackText);
elseif opt2type == 2 % risky
    Screen('FillArc', c.Window, [xx.brightness*color2 xx.brightness*(1-color2) 0], [hSide2, c.vPosition/2-c.radius,hSide2+c.radius*2, c.vPosition/2+c.radius], 0, opt2prob*360)
    Screen('FillArc', c.Window, [xx.brightness*(1-color2) xx.brightness*color2 0], [hSide2, c.vPosition/2-c.radius,hSide2+c.radius*2, c.vPosition/2+c.radius], opt2prob*360, (1-opt2prob)*360)
    Screen('DrawText', c.Window, ['$' num2str(opt2val2,'%#4.2f')], hSide2+c.LriskHDisplace*c.radius/2, c.vPosition/2-c.riskVDisplace*c.radius/2*((opt2prob-0.5)/0.25), c.blackText);
    Screen('DrawText', c.Window, ['$' num2str(opt2val1,'%#4.2f')], hSide2+c.radius*1.5*0.8, c.vPosition/2+c.riskVDisplace*c.radius/2*((opt2prob-0.5)/0.25), c.blackText);
elseif opt2type == 3 % ambig
    Screen('FillOval', c.Window, [100 100 100], [hSide2, c.vPosition/2-c.radius,hSide2+c.radius*2, c.vPosition/2+c.radius])
    Screen('DrawText', c.Window, '?', hSide2+c.radius, c.vPosition/2, c.blackText);
    Screen('DrawText', c.Window, ['$' num2str(opt2val2,'%#4.2f')], hSide2-c.radius*c.outerradius, c.vPosition/2-c.radius-c.radius*c.outerradius*2, c.textColor);
    Screen('DrawText', c.Window, ['$' num2str(opt2val1,'%#4.2f')], hSide2+2*c.radius+c.radius*c.outerradius, c.vPosition/2+c.radius-c.radius*c.outerradius*2, c.textColor);
end


Screen('DrawText', c.Window, 'Press ''1'' for the option on the left, ''4'' for the option on the right.', c.instr_X ,4*c.vPosition/5, c.textColor);


% record time after render but just before screen flip
ons_start = GetSecs;
nChoiceOnset = ons_start - xx.startTime;
fprintf('choice onset: %g \n', nChoiceOnset);


Screen('Flip',c.Window);
% Now collect a keypress from the user.
[testTrials.key testTrials.RT] = GetKey({'1!','4$'},[],[],-3);


fprintf('RT: %g, key: %s\n', testTrials.RT, testTrials.key);

if strcmp(testTrials.key,'1!')
    choseKey = 1;
    hChosenSide = c.circL;
    hNotChosenSide = c.circR;
    if sidePres == 1
        chosenOption = 1;
    elseif sidePres == 2
        chosenOption = 2;
    end
elseif strcmp(testTrials.key,'4$')
    choseKey=4;
    hChosenSide = c.circR;
    hNotChosenSide = c.circL;
    if sidePres == 1
        chosenOption = 2;
    elseif sidePres == 2
        chosenOption = 1;
    end
end

fprintf('chose option: %g\n', chosenOption);
ons_start = GetSecs;
nChoiceMadeOnset = ons_start - xx.startTime;
fprintf('choice made: %g\n',nChoiceMadeOnset);

% %%%% delay %%%% %
% outer circles
Screen('FillOval', c.Window, c.borderColor, [hSide2-c.radius*c.outerradius, c.vPosition/2-c.radius-c.radius*c.outerradius,hSide2+c.radius*2+c.radius*c.outerradius, c.vPosition/2+c.radius+c.radius*c.outerradius])
Screen('FillOval', c.Window, c.borderColor, [hSide1-c.radius*c.outerradius, c.vPosition/2-c.radius-c.radius*c.outerradius,hSide1+c.radius*2+c.radius*c.outerradius, c.vPosition/2+c.radius+c.radius*c.outerradius])

% original choice circles
if opt1type == 1 % certain
    
    Screen('FillArc', c.Window, [xx.brightness*color1 xx.brightness*(1-color1) 0], [hSide1, c.vPosition/2-c.radius,hSide1+c.radius*2, c.vPosition/2+c.radius], 0, opt1prob*360)
    Screen('DrawText', c.Window, ['$' num2str(opt1val1,'%#4.2f')], hSide1+c.radius*c.LriskHDisplace, c.vPosition/2, c.blackText);
elseif opt1type == 2 % risky
    Screen('FillArc', c.Window, [xx.brightness*color1 xx.brightness*(1-color1) 0], [hSide1, c.vPosition/2-c.radius,hSide1+c.radius*2, c.vPosition/2+c.radius], 0, opt1prob*360)
    Screen('FillArc', c.Window, [xx.brightness*(1-color1) xx.brightness*color1 0], [hSide1, c.vPosition/2-c.radius,hSide1+c.radius*2, c.vPosition/2+c.radius], opt1prob*360, (1-opt1prob)*360)
    Screen('DrawText', c.Window, ['$' num2str(opt1val2,'%#4.2f')], hSide1+c.LriskHDisplace*c.radius/2, c.vPosition/2-c.riskVDisplace*c.radius/2*((opt1prob-0.5)/0.25), c.blackText);
    Screen('DrawText', c.Window, ['$' num2str(opt1val1,'%#4.2f')], hSide1+c.radius*1.5*0.8, c.vPosition/2+c.riskVDisplace*c.radius/2*((opt1prob-0.5)/0.25), c.blackText);
elseif opt1type == 3 % ambig -- reveal
    Screen('FillOval', c.Window, [100 100 100], [hSide1, c.vPosition/2-c.radius,hSide1+c.radius*2, c.vPosition/2+c.radius])
    Screen('DrawText', c.Window, '?', hSide1+c.radius, c.vPosition/2, c.blackText);
    Screen('DrawText', c.Window, ['$' num2str(opt1val2,'%#4.2f')], hSide1-c.radius*c.outerradius, c.vPosition/2-c.radius-c.radius*c.outerradius*2, c.textColor);
    Screen('DrawText', c.Window, ['$' num2str(opt1val1,'%#4.2f')], hSide1+2*c.radius+c.radius*c.outerradius, c.vPosition/2+c.radius-c.radius*c.outerradius*2, c.textColor);
end

if opt2type == 1 % certain
    Screen('FillArc', c.Window, [xx.brightness*color2 xx.brightness*(1-color2) 0], [hSide2, c.vPosition/2-c.radius,hSide2+c.radius*2, c.vPosition/2+c.radius], 0, opt2prob*360)
    Screen('DrawText', c.Window, ['$' num2str(opt2val1,'%#4.2f')], hSide2+c.radius*c.LriskHDisplace, c.vPosition/2, c.blackText);
elseif opt2type == 2 % risky
    Screen('FillArc', c.Window, [xx.brightness*color2 xx.brightness*(1-color2) 0], [hSide2, c.vPosition/2-c.radius,hSide2+c.radius*2, c.vPosition/2+c.radius], 0, opt2prob*360)
    Screen('FillArc', c.Window, [xx.brightness*(1-color2) xx.brightness*color2 0], [hSide2, c.vPosition/2-c.radius,hSide2+c.radius*2, c.vPosition/2+c.radius], opt2prob*360, (1-opt2prob)*360)
    Screen('DrawText', c.Window, ['$' num2str(opt2val2,'%#4.2f')], hSide2+c.LriskHDisplace*c.radius/2, c.vPosition/2-c.riskVDisplace*c.radius/2*((opt2prob-0.5)/0.25), c.blackText);
    Screen('DrawText', c.Window, ['$' num2str(opt2val1,'%#4.2f')], hSide2+c.radius*1.5*0.8, c.vPosition/2+c.riskVDisplace*c.radius/2*((opt2prob-0.5)/0.25), c.blackText);
elseif opt2type == 3 % ambig -- reveal
    Screen('FillOval', c.Window, [100 100 100], [hSide2, c.vPosition/2-c.radius,hSide2+c.radius*2, c.vPosition/2+c.radius])
    Screen('DrawText', c.Window, '?', hSide2+c.radius, c.vPosition/2, c.blackText);
    Screen('DrawText', c.Window, ['$' num2str(opt2val2,'%#4.2f')], hSide2-c.radius*c.outerradius, c.vPosition/2-c.radius-c.radius*c.outerradius*2, c.textColor);
    Screen('DrawText', c.Window, ['$' num2str(opt2val1,'%#4.2f')], hSide2+2*c.radius+c.radius*c.outerradius, c.vPosition/2+c.radius-c.radius*c.outerradius*2, c.textColor);
end

% square to indicate chosen side
Screen('FrameRect', c.Window, [0 0 255], [hChosenSide-c.radius*c.outerradius*2, c.vPosition/2-c.radius-c.radius*c.outerradius*2,hChosenSide+c.radius*2+c.radius*c.outerradius*2, c.vPosition/2+c.radius+c.radius*c.outerradius*2],2)
Screen('Flip',c.Window);

if xx.debugFlag == 1
    WaitSecs(0);
else
    % adjust for fast responders here!
    if testTrials.RT <= 2 % if RT less than or equal to 2 sec, want their exposure from cue onset time to be at least 4 sec
        preOutcome=4-testTrials.RT;
    else % if they spent more than 2 seconds thinking about it, add on 2 sec of pause so odor exposure from cue onset is at least 4 sec
        preOutcome=2;
    end
    WaitSecs(preOutcome);
    
    
end

if xx.odorFlag==1
    % odor off
    ons_start = GetSecs;
    odorOffset = ons_start-xx.startTime;
    fprintf('odor off: %g\n',odorOffset);
    v.allChannelsOff();
end


% %%%% wheel spin %%%% %
if xx.debugFlag == 1
    spinTime=1;
else
    spinTime = randi(3,1)*c.TR;
end



spinSpeedL = (rand*5+5)/360*pi; % random speed (range 5-10 degrees per frame)
spinStartL = rand*2*pi; % random starting position
spinSpeedR = (rand*5+5)/360*pi; % random speed (range 5-10 degrees per frame)
spinStartR = rand*2*pi; % random starting position
% Convert movieDuration in seconds to duration in frames to draw:
movieDurationFrames=round(spinTime * c.frameRate);
for frame = 1:movieDurationFrames
    % outer circles
    Screen('FillOval', c.Window, c.borderColor, [hSide2-c.radius*c.outerradius, c.vPosition/2-c.radius-c.radius*c.outerradius,hSide2+c.radius*2+c.radius*c.outerradius, c.vPosition/2+c.radius+c.radius*c.outerradius])
    Screen('FillOval', c.Window, c.borderColor, [hSide1-c.radius*c.outerradius, c.vPosition/2-c.radius-c.radius*c.outerradius,hSide1+c.radius*2+c.radius*c.outerradius, c.vPosition/2+c.radius+c.radius*c.outerradius])
    
    % square to indicate chosen side
    Screen('FrameRect', c.Window, [0 0 255], [hChosenSide-c.radius*c.outerradius*2, c.vPosition/2-c.radius-c.radius*c.outerradius*2,hChosenSide+c.radius*2+c.radius*c.outerradius*2, c.vPosition/2+c.radius+c.radius*c.outerradius*2],2)
    
    
    % original choice circles
    if opt1type == 1 % certain
        Screen('FillArc', c.Window, [xx.brightness*color1 xx.brightness*(1-color1) 0], [hSide1, c.vPosition/2-c.radius,hSide1+c.radius*2, c.vPosition/2+c.radius], 0, opt1prob*360)
        Screen('DrawText', c.Window, ['$' num2str(opt1val1,'%#4.2f')], hSide1+c.radius*c.LriskHDisplace, c.vPosition/2, c.blackText);
    elseif opt1type == 2 % risky
        Screen('FillArc', c.Window, [xx.brightness*color1 xx.brightness*(1-color1) 0], [hSide1, c.vPosition/2-c.radius,hSide1+c.radius*2, c.vPosition/2+c.radius], 0, opt1prob*360)
        Screen('FillArc', c.Window, [xx.brightness*(1-color1) xx.brightness*color1 0], [hSide1, c.vPosition/2-c.radius,hSide1+c.radius*2, c.vPosition/2+c.radius], opt1prob*360, (1-opt1prob)*360)
        Screen('DrawText', c.Window, ['$' num2str(opt1val2,'%#4.2f')], hSide1+c.LriskHDisplace*c.radius/2, c.vPosition/2-c.riskVDisplace*c.radius/2*((opt1prob-0.5)/0.25), c.blackText);
        Screen('DrawText', c.Window, ['$' num2str(opt1val1,'%#4.2f')], hSide1+c.radius*1.5*0.8, c.vPosition/2+c.riskVDisplace*c.radius/2*((opt1prob-0.5)/0.25), c.blackText);
    elseif opt1type == 3 % ambig -- reveal
        Screen('FillOval', c.Window, [100 100 100], [hSide1, c.vPosition/2-c.radius,hSide1+c.radius*2, c.vPosition/2+c.radius])
        Screen('DrawText', c.Window, '?', hSide1+c.radius, c.vPosition/2, c.blackText);
        Screen('DrawText', c.Window, ['$' num2str(opt1val2,'%#4.2f')], hSide1-c.radius*c.outerradius, c.vPosition/2-c.radius-c.radius*c.outerradius*2, c.textColor);
        Screen('DrawText', c.Window, ['$' num2str(opt1val1,'%#4.2f')], hSide1+2*c.radius+c.radius*c.outerradius, c.vPosition/2+c.radius-c.radius*c.outerradius*2, c.textColor);
    end
    
    
    if opt2type == 1 % certain
        Screen('FillArc', c.Window, [xx.brightness*color2 xx.brightness*(1-color2) 0], [hSide2, c.vPosition/2-c.radius,hSide2+c.radius*2, c.vPosition/2+c.radius], 0, opt2prob*360)
        Screen('DrawText', c.Window, ['$' num2str(opt2val1,'%#4.2f')], hSide2+c.radius*c.LriskHDisplace, c.vPosition/2, c.blackText);
    elseif opt2type == 2 % risky
        Screen('FillArc', c.Window, [xx.brightness*color2 xx.brightness*(1-color2) 0], [hSide2, c.vPosition/2-c.radius,hSide2+c.radius*2, c.vPosition/2+c.radius], 0, opt2prob*360)
        Screen('FillArc', c.Window, [xx.brightness*(1-color2) xx.brightness*color2 0], [hSide2, c.vPosition/2-c.radius,hSide2+c.radius*2, c.vPosition/2+c.radius], opt2prob*360, (1-opt2prob)*360)
        Screen('DrawText', c.Window, ['$' num2str(opt2val2,'%#4.2f')], hSide2+c.LriskHDisplace*c.radius/2, c.vPosition/2-c.riskVDisplace*c.radius/2*((opt2prob-0.5)/0.25), c.blackText);
        Screen('DrawText', c.Window, ['$' num2str(opt2val1,'%#4.2f')], hSide2+c.radius*1.5*0.8, c.vPosition/2+c.riskVDisplace*c.radius/2*((opt2prob-0.5)/0.25), c.blackText);
    elseif opt2type == 3 % ambig -- reveal
        Screen('FillOval', c.Window, [100 100 100], [hSide2, c.vPosition/2-c.radius,hSide2+c.radius*2, c.vPosition/2+c.radius])
        Screen('DrawText', c.Window, '?', hSide2+c.radius, c.vPosition/2, c.blackText);
        Screen('DrawText', c.Window, ['$' num2str(opt2val2,'%#4.2f')], hSide2-c.radius*c.outerradius, c.vPosition/2-c.radius-c.radius*c.outerradius*2, c.textColor);
        Screen('DrawText', c.Window, ['$' num2str(opt2val1,'%#4.2f')], hSide2+2*c.radius+c.radius*c.outerradius, c.vPosition/2+c.radius-c.radius*c.outerradius*2, c.textColor);
    end
    
    
    currentAngleL = (spinStartL + spinSpeedL*(frame)*((movieDurationFrames-frame)/movieDurationFrames+1));
    currentXPosL = (c.radius+c.rouletteRadius)*sin(currentAngleL)+c.circL+c.radius;
    currentYPosL= (c.radius+c.rouletteRadius)*cos(currentAngleL)+c.vPosition/2;
    currentAngleR = pi-(spinStartR + spinSpeedR*(frame)*((movieDurationFrames-frame)/movieDurationFrames+1));
    currentXPosR = (c.radius+c.rouletteRadius)*sin(currentAngleR)+c.circR+c.radius;
    currentYPosR = (c.radius+c.rouletteRadius)*cos(currentAngleR)+c.vPosition/2;
    
    if strcmp(testTrials.key,'1!')
        Screen('FillOval', c.Window, [0 0 0], [currentXPosL-c.rouletteRadius, currentYPosL-c.rouletteRadius,currentXPosL+c.rouletteRadius, currentYPosL+c.rouletteRadius])
    elseif strcmp(testTrials.key,'4$')
        Screen('FillOval', c.Window, [0 0 0], [currentXPosR-c.rouletteRadius, currentYPosR-c.rouletteRadius,currentXPosR+c.rouletteRadius, currentYPosR+c.rouletteRadius])
    end
    
    Screen('Flip',c.Window);
end

% outcome - the angle determines the amount (take last currentAngle)
% outer circles
Screen('FillOval', c.Window, c.borderColor, [hSide2-c.radius*c.outerradius, c.vPosition/2-c.radius-c.radius*c.outerradius,hSide2+c.radius*2+c.radius*c.outerradius, c.vPosition/2+c.radius+c.radius*c.outerradius])
Screen('FillOval', c.Window, c.borderColor, [hSide1-c.radius*c.outerradius, c.vPosition/2-c.radius-c.radius*c.outerradius,hSide1+c.radius*2+c.radius*c.outerradius, c.vPosition/2+c.radius+c.radius*c.outerradius])

% original choice circles
if opt1type == 1 % certain
    Screen('FillArc', c.Window, [xx.brightness*color1 xx.brightness*(1-color1) 0], [hSide1, c.vPosition/2-c.radius,hSide1+c.radius*2, c.vPosition/2+c.radius], 0, opt1prob*360)
    Screen('DrawText', c.Window, ['$' num2str(opt1val1,'%#4.2f')], hSide1+c.radius*c.LriskHDisplace, c.vPosition/2, c.blackText);
elseif opt1type == 2 % risky
    Screen('FillArc', c.Window, [xx.brightness*color1 xx.brightness*(1-color1) 0], [hSide1, c.vPosition/2-c.radius,hSide1+c.radius*2, c.vPosition/2+c.radius], 0, opt1prob*360)
    Screen('FillArc', c.Window, [xx.brightness*(1-color1) xx.brightness*color1 0], [hSide1, c.vPosition/2-c.radius,hSide1+c.radius*2, c.vPosition/2+c.radius], opt1prob*360, (1-opt1prob)*360)
    Screen('DrawText', c.Window, ['$' num2str(opt1val2,'%#4.2f')], hSide1+c.LriskHDisplace*c.radius/2, c.vPosition/2-c.riskVDisplace*c.radius/2*((opt1prob-0.5)/0.25), c.blackText);
    Screen('DrawText', c.Window, ['$' num2str(opt1val1,'%#4.2f')], hSide1+c.radius*1.5*0.8, c.vPosition/2+c.riskVDisplace*c.radius/2*((opt1prob-0.5)/0.25), c.blackText);
elseif opt1type == 3 % ambig -- reveal
    Screen('FillOval', c.Window, [100 100 100], [hSide1, c.vPosition/2-c.radius,hSide1+c.radius*2, c.vPosition/2+c.radius])
    Screen('DrawText', c.Window, '?', hSide1+c.radius, c.vPosition/2, c.blackText);
    Screen('DrawText', c.Window, ['$' num2str(opt1val2,'%#4.2f')], hSide1-c.radius*c.outerradius, c.vPosition/2-c.radius-c.radius*c.outerradius*2, c.textColor);
    Screen('DrawText', c.Window, ['$' num2str(opt1val1,'%#4.2f')], hSide1+2*c.radius+c.radius*c.outerradius, c.vPosition/2+c.radius-c.radius*c.outerradius*2, c.textColor);
end


if opt2type == 1 % certain
    Screen('FillArc', c.Window, [xx.brightness*color2 xx.brightness*(1-color2) 0], [hSide2, c.vPosition/2-c.radius,hSide2+c.radius*2, c.vPosition/2+c.radius], 0, opt2prob*360)
    Screen('DrawText', c.Window, ['$' num2str(opt2val1,'%#4.2f')], hSide2+c.radius*c.LriskHDisplace, c.vPosition/2, c.blackText);
elseif opt2type == 2 % risky
    Screen('FillArc', c.Window, [xx.brightness*color2 xx.brightness*(1-color2) 0], [hSide2, c.vPosition/2-c.radius,hSide2+c.radius*2, c.vPosition/2+c.radius], 0, opt2prob*360)
    Screen('FillArc', c.Window, [xx.brightness*(1-color2) xx.brightness*color2 0], [hSide2, c.vPosition/2-c.radius,hSide2+c.radius*2, c.vPosition/2+c.radius], opt2prob*360, (1-opt2prob)*360)
    Screen('DrawText', c.Window, ['$' num2str(opt2val2,'%#4.2f')], hSide2+c.LriskHDisplace*c.radius/2, c.vPosition/2-c.riskVDisplace*c.radius/2*((opt2prob-0.5)/0.25), c.blackText);
    Screen('DrawText', c.Window, ['$' num2str(opt2val1,'%#4.2f')], hSide2+c.radius*1.5*0.8, c.vPosition/2+c.riskVDisplace*c.radius/2*((opt2prob-0.5)/0.25), c.blackText);
elseif opt2type == 3 % ambig -- reveal
    Screen('FillOval', c.Window, [100 100 100], [hSide2, c.vPosition/2-c.radius,hSide2+c.radius*2, c.vPosition/2+c.radius])
    Screen('DrawText', c.Window, '?', hSide2+c.radius, c.vPosition/2, c.blackText);
    Screen('DrawText', c.Window, ['$' num2str(opt2val2,'%#4.2f')], hSide2-c.radius*c.outerradius, c.vPosition/2-c.radius-c.radius*c.outerradius*2, c.textColor);
    Screen('DrawText', c.Window, ['$' num2str(opt2val1,'%#4.2f')], hSide2+2*c.radius+c.radius*c.outerradius, c.vPosition/2+c.radius-c.radius*c.outerradius*2, c.textColor);
end

% square to indicate chosen side
Screen('FrameRect', c.Window, [0 0 255], [hChosenSide-c.radius*c.outerradius*2, c.vPosition/2-c.radius-c.radius*c.outerradius*2,hChosenSide+c.radius*2+c.radius*c.outerradius*2, c.vPosition/2+c.radius+c.radius*c.outerradius*2],2)

if strcmp(testTrials.key,'1!')
    Screen('FillOval', c.Window, [0 0 0], [currentXPosL-c.rouletteRadius, currentYPosL-c.rouletteRadius,currentXPosL+c.rouletteRadius, currentYPosL+c.rouletteRadius])
elseif strcmp(testTrials.key,'4$')
    Screen('FillOval', c.Window, [0 0 0], [currentXPosR-c.rouletteRadius, currentYPosR-c.rouletteRadius,currentXPosR+c.rouletteRadius, currentYPosR+c.rouletteRadius])
end

% calculate and display outcome
% find angle of option 1 and 2 respectively
if sidePres == 1
    finalAngle1 = pi-rem(currentAngleL,2*pi);
    finalAngle2 = pi-(2*pi+rem(currentAngleR,2*pi));
elseif sidePres == 2
    finalAngle1 = pi-(2*pi+rem(currentAngleR,2*pi));
    finalAngle2 = pi-rem(currentAngleL,2*pi);
end

while finalAngle1 < 0
    finalAngle1 = finalAngle1+2*pi;
end
while finalAngle2 < 0
    finalAngle2 = finalAngle2+2*pi;
end

% option 1 outcome
if finalAngle1 > opt1prob*2*pi
    outcome1 = opt1val2;
else
    outcome1 = opt1val1;
end

fprintf('opt 1 angle: %g, prob: %g, side: %g \n', finalAngle1, opt1prob*2*pi,sidePres)
fprintf('opt 2 angle: %g, prob: %g, side: %g\n', finalAngle2, opt2prob*2*pi,sidePres)
%option 2 outcome
if finalAngle2 > opt2prob*2*pi
    outcome2 = opt2val2;
else
    outcome2 = opt2val1;
end


if chosenOption == 1
    outcomeVal = outcome1;
    nonChosenOutcomeVal = outcome2;
elseif chosenOption == 2
    outcomeVal = outcome2;
    nonChosenOutcomeVal = outcome1;
end



Screen('DrawText', c.Window, ['You won $' num2str(outcomeVal,'%#4.2f')], hChosenSide, 5*c.vPosition/6, c.textColor);
%Screen('DrawText', c.Window, ['You could have won $' num2str(nonChosenOutcomeVal,'%#4.2f')], hNotChosenSide, 5*c.vPosition/6, c.textColor);

% save ITI just before screen flip...
fprintf('outcome: %g, non-chosen outcome: %g\n',outcomeVal,nonChosenOutcomeVal);
ons_start = GetSecs;
nOutcomeShown = ons_start - xx.startTime;
fprintf('outcome revealed: %g\n',nOutcomeShown);

Screen('Flip',c.Window);
if xx.debugFlag == 1
    GetKey({'1!','4$'},[],[],-3);
else
    WaitSecs(2);
end

% fixation
DrawFormattedText(c.Window, '+','center','center',250,100);
Screen('Flip',c.Window);
if xx.debugFlag==1
    ITI=0; % debug mode
else
    ITI = randi(3,1)*c.TR;
end
WaitSecs(ITI);

% store stuff
data(xx.option1typeCol) = opt1type;
data(xx.option1val1Col) = opt1val1;
data(xx.option1val2Col) = opt1val2;
data(xx.option1probCol) = opt1prob;

data(xx.option2typeCol) = opt2type;
data(xx.option2val1Col) = opt2val1;
data(xx.option2val2Col) = opt2val2;
data(xx.option2probCol) = opt2prob;

data(xx.choseCol) = chosenOption;
data(xx.outcomeCol) = outcomeVal;
data(xx.nonChosenOutcomeCol) = nonChosenOutcomeVal;

data(xx.choiceOnsetCol) = nChoiceOnset;
data(xx.choseOptionTimeCol) = nChoiceMadeOnset;
data(xx.outcomeShownCol) = nOutcomeShown;

data(xx.RTCol) = testTrials.RT;
data(xx.keyCol) = choseKey;

end