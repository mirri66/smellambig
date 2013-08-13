% run this wrapper script to generate outcome for given subject
clear
clc

 thePath.main = pwd;
    % Make sure you are starting from the smellrisk directory! ...
    [pathstr,curr_dir,ext,versn] = fileparts(pwd);
    if ~strcmp(curr_dir,'smellambig')
        error('You must start the experiment fromthe smellambig directory. Go there and try again.\n');
    end
    thePath.scripts = fullfile(thePath.main, 'scripts');
    thePath.data = fullfile(thePath.main, 'data');
    
    % Add relevant paths for this experiment
    addpath(thePath.scripts)
    addpath(thePath.data)
    

fprintf('Compute outcome for the current subject :) \n');
subjNo = input('What is the subject number? ');

cd(thePath.scripts)
[payout] = runOutcomeGen(subjNo);

basepay=7;
finalPay =basepay + payout;
fprintf(['\n\n Subject ' num2str(subjNo) ' receives base $' num2str(basepay) ' + $' num2str(payout) ' from trials for a total of $' num2str(finalPay) '\n\n']);
