function ambig_od(subjectnumber)
% function run_execinfo06_behavioral(subjectnumber,run,permute)
%
% subjectnumber -> ID number of the subject you are running
% which session of the ATD is this?  1 = prelim, 2 = main1, 3 = main2
% run -> number of current run
%----------------------------------------------------------------------------------------------------------

subnum = subjectnumber;
tic
% Scan Parameters
TR = 3.0;
session=1;

permute = 1;
outcomes = 0;

%modify this if the script name changes
scriptname = mfilename;
path = which(scriptname);
path = path(1:end-length(scriptname)-2);
cd(path);
behavioralpath = path;

%load(strcat('trialinfo_behav_',num2str(run))); % load run info


load('od_ambig_trial_order1.mat')

totaltrials = length(trial_info);
length(trial_info)
if permute == 1 % randomize order of trials within current run
    for i=1:totaltrials
        trial_info(i,10) = i;
    end
    trial_info = trial_info(randperm(totaltrials),:);
    new_order = trial_info(:,10)';
    paradigm{1} = paradigm{1}(new_order);
    paradigm{2} = paradigm{2}(new_order);
    trial_info = trial_info(:,1:9);
%    save(strcat(subjectnumber,'_permuted_order_',num2str(run),'.mat'),'trial_info');
end

% oamg - I use 1, 1-second.
% This part is to set the ITI for different trials. We use three different
% ITI's unlike Huettel who used 5.
n_iti = 3;
iti = [ones(1,totaltrials/n_iti) ones(1,totaltrials/n_iti) ones(1,totaltrials/n_iti)];
%iti = TR*iti(randperm(totaltrials));

startsecs=getsecs;  % begin time tracking

[window, screenRect] = SCREEN(0,'OpenWindow',[],[],16); 

rect = [0 0 250 250];
center{1} = [301 384]; % Center of left circle
center{2} = [722 384]; % Center of right circle
midRect{1} = CenterRectOnPoint(rect,center{1}(1)+1,center{1}(2)+1);
midRect{2} = CenterRectOnPoint(rect,center{2}(1)+1,center{2}(2)+1);
reward_coord_x = 315;
reward_coord_y = 404;
radius = 124;

% Construct fixation cross screen
cross = SCREEN(window,'OpenOffscreenWindow',[],screenRect);
SCREEN(cross,'DrawLine',0,491,383,532,383,3,3);
SCREEN(cross,'DrawLine',0,511,364,511,404,3,3);

% Construct blank screens
blank_screen = SCREEN(window,'OpenOffscreenWindow',[],screenRect);
blank_rect = SCREEN(window,'OpenOffscreenWindow',[],rect+[0 0 150 150]);

% Construct ambiguous probability screen
unknown = SCREEN(window,'OpenOffscreenWindow',[],rect);
SCREEN(unknown,'FrameArc',0,rect,0,360,2,2);
SCREEN(unknown,'TextFont','Arial');
SCREEN(unknown,'TextSize',100);
SCREEN(unknown,'DrawText','?',100,160,0);

% Construct results pie charts
red(1) = SCREEN(window,'OpenOffscreenWindow',[],rect);  % 100% green
SCREEN(red(1),'FillArc',[0 238 0],rect,0,360);

red(2) = SCREEN(window,'OpenOffscreenWindow',[],rect);  % 25% red
SCREEN(red(2),'FillArc',[238 0 0],rect,-90,90);
SCREEN(red(2),'FillArc',[0 238 0],rect,0,270);

red(3) = SCREEN(window,'OpenOffscreenWindow',[],rect);  % 50/50
SCREEN(red(3),'FillArc',[238 0 0],rect,270,180);
SCREEN(red(3),'FillArc',[0 238 0],rect,90,180);

red(4) = SCREEN(window,'OpenOffscreenWindow',[],rect);  % 75% red
SCREEN(red(4),'FillArc',[238 0 0],rect,180,270);
SCREEN(red(4),'FillArc',[0 238 0],rect,90,90);

red(5) = SCREEN(window,'OpenOffscreenWindow',[],rect);  % 100% red
SCREEN(red(5),'FillArc',[238 0 0],rect,0,360);

warning off;
Hidecursor;
outcounter = 0;
moneywon = 0;
for a=1:totaltrials % begin trial loop
%for a = 1:5,
    outcounter = outcounter+1;
   
    switcher = floor(rand*2)+1; % switcher is responsible for randomly switching left/right positioning of gambles
    if switcher == 1    % gambles are left/right switched
        temp_rect = midRect{1};
        midRect{1} = midRect{2};
        midRect{2} = temp_rect;           
        for j = 1:2
            circle_money_red{j} = center{abs(j-3)} - [33 -15];  % circle_money_red variable sets position of $ amounts inside circle
            circle_money_green{j} = center{abs(j-3)} - [33 -15];
            ambig_money_red{j} = circle_money_red{j} - [175 50];
            ambig_money_green{j} = circle_money_green{j} + [175 50];
            if paradigm{j}(a) == 2 | paradigm{j}(a) == 4
                circle_money_red{j} = circle_money_red{j} - [55 40];
                circle_money_green{j} = circle_money_green{j} + [50 40];
            elseif paradigm{j}(a) == 3
                circle_money_red{j} = circle_money_red{j} - [0 40];
                circle_money_green{j} = circle_money_green{j} + [0 40];
            end
        end
    else    % gambles are unswitched
        for j = 1:2
            circle_money_red{j} = center{j} - [33 -15]; 
            circle_money_green{j} = center{j} - [33 -15];
            ambig_money_red{j} = circle_money_red{j} - [175 50];
            ambig_money_green{j} = circle_money_green{j} + [175 50];
            if paradigm{j}(a) == 2 | paradigm{j}(a) == 4
                circle_money_red{j} = circle_money_red{j} - [55 40];
                circle_money_green{j} = circle_money_green{j} + [50 40];
            elseif paradigm{j}(a) == 3
                circle_money_red{j} = circle_money_red{j} - [0 40];
                circle_money_green{j} = circle_money_green{j} + [0 40];
            end
        end
    end
    
    % display gambles
    if trial_info(a,1) == 2 | trial_info(a,1) == 4
        SCREEN('CopyWindow',unknown,window,rect,midRect{1});
    else
        SCREEN('CopyWindow',red(paradigm{1}(a)),window,rect,midRect{1});        
    end
    SCREEN('CopyWindow',red(paradigm{2}(a)),window,rect,midRect{2});
    SCREEN(window, 'FrameOval',0,midRect{1}+[-20 -20 20 20],22,22);
    SCREEN(window, 'FrameOval',0,midRect{2}+[-20 -20 20 20],22,22);
    
    reward(1) = trial_info(a,2);
    reward(2) = trial_info(a,5);
    rewardgreen(1) = trial_info(a,3);
    rewardgreen(2) = trial_info(a,6);
    
    % display possible rewards
    SCREEN(window,'TextFont','Arial');
    SCREEN(window,'TextSize',40);
    if trial_info(a,1) == 2 | trial_info(a,1) == 4
        SCREEN(window,'DrawText',strcat('$',num2str(reward(1))),ambig_money_red{1}(1),ambig_money_red{1}(2),[0 0 255]);  
        SCREEN(window,'DrawText',strcat('$',num2str(rewardgreen(1))),ambig_money_green{1}(1),ambig_money_green{1}(2),[0 0 255]);
    else
        if paradigm{1}(a) ~= 1
            SCREEN(window,'DrawText',strcat('$',num2str(reward(1))),circle_money_red{1}(1),circle_money_red{1}(2),255);
        end
        if paradigm{1}(a) ~= 5
            SCREEN(window,'DrawText',strcat('$',num2str(rewardgreen(1))),circle_money_green{1}(1),circle_money_green{1}(2),255);
        end
    end   
    if paradigm{2}(a) ~= 1
        SCREEN(window,'DrawText',strcat('$',num2str(reward(2))),circle_money_red{2}(1),circle_money_red{2}(2),255);
    end
    if paradigm{2}(a) ~= 5
        SCREEN(window,'DrawText',strcat('$',num2str(rewardgreen(2))),circle_money_green{2}(1),circle_money_green{2}(2),255);
    end
    
    output(a,1) = getsecs-startsecs;
    
    press = 0;
    while press == 0 %& ((Getsecs - respon_start) < 5)
        [z,b,c] = KbCheck;
        if(find(c)==37) % user chooses left gamble
            press=1;
            side = 1;
        elseif(find(c)==39) % user chooses right gamble
            press=2;
            side = 2;
        elseif (find(c)==97)  % 49
            press = 1;
            side=1;
        elseif (find(c)==98) % 50
            press = 2;
            press=2;
        elseif(find(c)==27) % escape sequence
            press=3;
            
%             fid = fopen([path,'error_ATD_',int2str(subjectnumber)],'_', int2str(session), '.txt'),'w')
%             %fid = fopen(strcat(behavioralpath,'error_',subjectnumber,'_',num2str(run),'.txt'),'w');
%             fprintf(fid,'%s\r\n','TimeSt   PercC  Rew1C   Rew2C   PercU   Rew1U   Rew2U   Unknown   TimeRsp    Choice     TimeRw   RewardC  RewardU');
%             for row=1:a-1
%                 fprintf(fid,'%7.3f\t  %3.0f \t %3.0f\t %3.0f \t %3.0f \t %3.0f \t %3.0f\t %3.0f\t  %7.3f\t%1.0f \t%7.3f\t  %3.0f \t   %3.0f\r\n',output(row,1),output(row,2),output(row,3),output(row,4),output(row,5),output(row,6),output(row,7),output(row,8),output(row,9),output(row,10),output(row,11),output(row,12),output(row,13));
%             end
%             fprintf(fid,'%s',strcat('Run Aborted After Trial #',num2str(a),'...'));
%             fclose(fid);
            SCREEN('CloseAll')
        end
    end
    responsetime = (getsecs-startsecs);
    other = abs(press-3);       % 'other' indicates gamble user did NOT choose
    otherside = abs(side-3);
    
    output(a,press*3-1) = (paradigm{abs(switcher-3)}(a)-1)*25;
    output(a,press*3) = reward(abs(switcher-3));
    output(a,press*3+1) = rewardgreen(abs(switcher-3));
    output(a,other*3-1) = (paradigm{switcher}(a)-1)*25;
    output(a,other*3) = reward(switcher);
    output(a,other*3+1)=rewardgreen(switcher); 
    output(a,8) = (trial_info(a,1)==2 | trial_info(a,1)==4)*(abs(switcher-3));
    output(a,9) = responsetime;
    output(a,10) = press;
    
    if switcher == 1
        press = abs(press-3);
        other = abs(other-3);    
    end
    
    % display box around selected gamble
    
%     if trial_info(a,1) == 2 | trial_info(a,1) == 4
%         SCREEN(window,'Waitblanking');
%         SCREEN('CopyWindow',blank_rect,window,rect,midRect{press}+[-100 -100 100 100]);
%         SCREEN('CopyWindow',blank_rect,window,rect,midRect{other}+[-100 -100 100 100]);
%         SCREEN('CopyWindow',red(paradigm{press}(a)),window,rect,midRect{press});
%         SCREEN('CopyWindow',red(paradigm{other}(a)),window,rect,midRect{other});
%     end
    SCREEN(window,'Framerect',[0 255 0],midRect{press}+[-60 -60 60 60],10,10);
    %SCREEN(window, 'FrameOval',0,midRect{1}+[-20 -20 20 20],22,22);
    %SCREEN(window, 'FrameOval',0,midRect{2}+[-20 -20 20 20],22,22);
        if trial_info(a,1) == 2 | trial_info(a,1) == 4
        SCREEN(window,'DrawText',strcat('$',num2str(reward(1))),ambig_money_red{1}(1),ambig_money_red{1}(2),[0 0 255]);  
        SCREEN(window,'DrawText',strcat('$',num2str(rewardgreen(1))),ambig_money_green{1}(1),ambig_money_green{1}(2),[0 0 255]);
    else
        if paradigm{1}(a) ~= 1
            SCREEN(window,'DrawText',strcat('$',num2str(reward(1))),circle_money_red{1}(1),circle_money_red{1}(2),255);
        end
        if paradigm{1}(a) ~= 5
            SCREEN(window,'DrawText',strcat('$',num2str(rewardgreen(1))),circle_money_green{1}(1),circle_money_green{1}(2),255);
        end
    end   
    if paradigm{2}(a) ~= 1
        SCREEN(window,'DrawText',strcat('$',num2str(reward(2))),circle_money_red{2}(1),circle_money_red{2}(2),255);
    end
    if paradigm{2}(a) ~= 5
        SCREEN(window,'DrawText',strcat('$',num2str(rewardgreen(2))),circle_money_green{2}(1),circle_money_green{2}(2),255);
    end
    pause(.5)
%     
%     %display actual results behind ambig? - OAMG
%     if paradigm{press}(a) ~= 1
%         SCREEN(window,'DrawText',strcat('$',num2str(reward(press))),circle_money_red{press}(1),circle_money_red{press}(2),255);            
%     end
%     if paradigm{press}(a) ~= 5
%         SCREEN(window,'DrawText',strcat('$',num2str(rewardgreen(press))),circle_money_green{press}(1),circle_money_green{press}(2),255);
%     end        
%     if paradigm{other}(a) ~= 1
%         SCREEN(window,'DrawText',strcat('$',num2str(reward(other))),circle_money_red{other}(1),circle_money_red{other}(2),255);
%     end        
%     if paradigm{other}(a) ~= 5
%         SCREEN(window,'DrawText',strcat('$',num2str(rewardgreen(other))),circle_money_green{other}(1),circle_money_green{other}(2),255);
%     end
%     waitsecs(2);
%     while mod((getsecs-startsecs),TR) > .001    % wait for onset of next TR
%     end
    
    if outcomes == 0    % uses predetermined win/loss information
        won_press = trial_info(a,press+7);
        won_other = trial_info(a,other+7);
    else    % randomly generates win/loss information
        perc_press = (paradigm{press}(a)-1)/4;
        perc_other = (paradigm{other}(a)-1)/4;
        if rand<=perc_press
            won_press = 1;
        else
            won_press = 0;
        end
        if rand<=perc_other
            won_other = 1;
        else
            won_other = 0;
        end
    end
    
    % figure out what the ending quadrant should be
    if won_press == 1 
        if paradigm{press}(a) == 2
            whichquad = 1;
        elseif paradigm{press}(a) == 3
            whichquad = floor(rand*2)+1;
        elseif paradigm{press}(a) == 4
            whichquad = ceil(2^(floor(rand*3)));
        else
            whichquad = floor(rand*4)+1;
        end
    else
        if paradigm{press}(a) == 4
            whichquad = 3;
        elseif paradigm{press}(a) == 3
            whichquad = floor(rand*2)+3;
        elseif paradigm{press}(a) == 2
            whichquad = floor(rand*3)+2;
        else
            whichquad = floor(rand*4)+1;
        end
    end
    
    if won_other == 1 
        if paradigm{other}(a) == 2
            whichquad_other = 1;
        elseif paradigm{other}(a) == 3
            whichquad_other = floor(rand*2)+1;
        elseif paradigm{other}(a) == 4
            whichquad_other = ceil(2^(floor(rand*3)));
        else
            whichquad_other = floor(rand*4)+1;
        end
    else
        if paradigm{other}(a) == 4
            whichquad_other = 3;
        elseif paradigm{other}(a) == 3
            whichquad_other = floor(rand*2)+3;
        elseif paradigm{other}(a) == 2
            whichquad_other = floor(rand*3)+2;
        else
            whichquad_other = floor(rand*4)+1;
        end
    end
    
    slowdownRate = .6; % the ball slows down more as this value increases
    
    % set up properties for each spinner
    anglestep = zeros(1,2);
    while abs(anglestep(press) - anglestep(other)) < 3
        anglestep(press) = floor(rand*5)+7;
        anglestep(other) = floor(rand*5)+7;
    end
    max_rotations = 4;    % Slower spinner will rotate between max_rotations-1 and max_rotations before stopping
    if anglestep(1) < anglestep(2)
        range(1) = floor(360*(max_rotations-1)/((1-slowdownRate/2)*anglestep(1)));
        range(2) = floor(360*(max_rotations)/((1-slowdownRate/2)*anglestep(1)));
    else
        range(1) = floor(360*(max_rotations-1)/((1-slowdownRate/2)*anglestep(2)));
        range(2) = floor(360*(max_rotations)/((1-slowdownRate/2)*anglestep(2)));
    end
    spin_frames = floor(rand*(range(2)-range(1)))+1+range(1);
    
    % figure out what the starting angle should be
    slowdown = 0;
    for spinIter = 1:spin_frames
        slowdown = slowdown+(1-slowdownRate)+slowdownRate*(spin_frames+1-spinIter)/spin_frames;
    end
    if switcher ~= 1
        startangle(press) = ((whichquad-1)*90 + floor(rand*78)+6 - mod(anglestep(press)*slowdown,360));
        startangle(other) = ((whichquad_other-1)*90 + floor(rand*78)+6 + mod(anglestep(other)*slowdown,360));
    else
        startangle(other) = ((whichquad-1)*90 + floor(rand*78)+6 + mod(anglestep(other)*slowdown,360));
        startangle(press) = ((whichquad_other-1)*90 + floor(rand*78)+6 - mod(anglestep(press)*slowdown,360));
    end
    
%     %    display the "ball" slightly before ball begins moving
%     SCREEN(window,'FillOval',255,[(center{press}(1)-(radius+11)*cos(startangle(press)*pi/180))-7 (center{press}(2)-(radius+11)*sin(startangle(press)*pi/180))-7 (center{press}(1)-(radius+11)*cos(startangle(press)*pi/180))+7 (center{press}(2)-(radius+11)*sin(startangle(press)*pi/180))+7])
%     SCREEN(window,'FillOval',255,[(center{other}(1)-(radius+11)*cos(startangle(other)*pi/180))-7 (center{other}(2)-(radius+11)*sin(startangle(other)*pi/180))-7 (center{other}(1)-(radius+11)*cos(startangle(other)*pi/180))+7 (center{other}(2)-(radius+11)*sin(startangle(other)*pi/180))+7])
%     
%    waitsecs(1)
    spinsecs = getsecs;
    increase = 0;
%     for spin = 1:spin_frames % loop responsible for ball movement
%         increase = increase + (1-slowdownRate)+slowdownRate*(spin_frames-spin+1)/spin_frames;
%         angle(press) = startangle(press)+(increase)*anglestep(press);
%         angle(other) = startangle(other)-(increase)*anglestep(other);
%         SCREEN(window,'WaitBlanking');
%         SCREEN(window, 'FrameOval',0,midRect{1}+[-20 -20 20 20],22,22);
%         SCREEN(window, 'FrameOval',0,midRect{2}+[-20 -20 20 20],22,22);
%         SCREEN(window,'FillOval',255,[(center{press}(1)-(radius+11)*cos(angle(press)*pi/180))-7 (center{press}(2)-(radius+11)*sin(angle(press)*pi/180))-7 (center{press}(1)-(radius+11)*cos(angle(press)*pi/180))+7 (center{press}(2)-(radius+11)*sin(angle(press)*pi/180))+7])
%         SCREEN(window,'FillOval',255,[(center{other}(1)-(radius+11)*cos(angle(other)*pi/180))-7 (center{other}(2)-(radius+11)*sin(angle(other)*pi/180))-7 (center{other}(1)-(radius+11)*cos(angle(other)*pi/180))+7 (center{other}(2)-(radius+11)*sin(angle(other)*pi/180))+7])
%     end
%     waitsecs(1);
%     
    output(a,11) = (getsecs-startsecs);
    
    % determine reward and display
    if won_press==1
        output(a,12) = reward(press);
        moneywon = moneywon+reward(press);
%        SCREEN(window,'TextSize',30);
%        SCREEN(window,'DrawText',strcat('You won',' $',num2str(reward(press))),center{side}(1)-85,center{side}(2)+250,0);
    else
        output(a,12) = rewardgreen(press);
        moneywon = moneywon+rewardgreen(press);
%        SCREEN(window,'TextSize',30);
%        SCREEN(window,'DrawText',strcat('You won',' $',num2str(rewardgreen(press))),center{side}(1)-85,center{side}(2)+250,0);
    end
%     waitsecs(2);
% %     SCREEN('CopyWindow',blank_screen,window,screenRect,[(center{1}+[-100 200]) (center{2}+[100 350])]);
%     if won_other == 1
%         SCREEN(window,'DrawText',strcat('You could have won',' $',num2str(reward(other))),center{otherside}(1)-150,center{otherside}(2)+250,0);
%     else
%         SCREEN(window,'DrawText',strcat('You could have won',' $',num2str(rewardgreen(other))),center{otherside}(1)-150,center{otherside}(2)+250,0);
%     end
%     
%     waitsecs(1);
%     
%     while mod((getsecs-startsecs),TR) > .001
%     end
%     
    %Determine result of non-chosen gamble
    if(paradigm{other}(a) == 5 | (paradigm{other}(a) == 4 & whichquad_other~=3) | (paradigm{other}(a) == 3 & whichquad_other < 3) | (paradigm{other}(a) == 2 & whichquad_other == 1))
        output(a,13) = reward(other);
    else
        output(a,13) = rewardgreen(other);
    end
    
     SCREEN('CopyWindow',blank_screen,window,screenRect,screenRect);
%     
%     % switch midRects back to original if switched in current trial
     if switcher == 1
         temp_rect = midRect{1};
         midRect{1} = midRect{2};
         midRect{2} = temp_rect;
     end%
     
     SCREEN('CopyWindow',cross,window,screenRect,screenRect);
     %waitsecs(iti(a));
     SCREEN('CopyWindow',blank_screen,window,screenRect,screenRect);
end


% write output to file
file_name = ['RG_ambig_', int2str(subnum), '_', int2str(session),'.mat']
save(file_name)
currentdir = pwd
% fid = fopen(strcat(path,'output_ATD_',int2str(subjectnumber),'_', int2str(session), '.txt'),'w');
% fprintf(fid,'%s\r\n','TimeSt   PercC  Rew1C   Rew2C   PercU   Rew1U   Rew2U   Unknown   TimeRsp    Choice     TimeRw   RewardC  RewardU');
% for row=1:a
%     fprintf(fid,'%7.3f\t  %3.0f \t %3.0f\t %3.0f \t %3.0f \t %3.0f \t %3.0f\t %3.0f\t  %7.3f\t%1.0f \t%7.3f\t  %3.0f \t   %3.0f\r\n',output(row,1),output(row,2),output(row,3),output(row,4),output(row,5),output(row,6),output(row,7),output(row,8),output(row,9),output(row,10),output(row,11),output(row,12),output(row,13));
% end
% fclose(fid);

ShowCursor;
SCREEN('CloseAll')
toc