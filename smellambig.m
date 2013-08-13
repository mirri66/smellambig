% smellambig wrapper
% copied from wrapper for Stanford PTB tasks

function smellambig()
clear;
clc;

v.odorFlag=0;

PsychJavaTrouble
pwd
path.main = pwd;


exptname = 'smellambig';

[pathstr,curr_dir,ext] = fileparts(pwd);
if ~strcmp(curr_dir,'smellambig')
    error('You must start the experiment from the smellambig directory. Go there and try again.\n');
end
javaaddpath('.');

% define and add standard paths 
path.data = fullfile(path.main, 'data');
path.diaries = fullfile(path.main, 'diaries');
path.stim = fullfile(path.main, 'stim');
path.scripts = fullfile(path.main, 'scripts');
addpath(path.data)
addpath(path.diaries)
addpath(path.stim)
addpath(path.scripts)

% start the experiment!
fprintf('Welcome!\n');
subjNo = input('What is the subject number? (0-99): ');

% check for existing file for that subject
cd(path.data);
    savename = [exptname num2str(subjNo) '.mat'];
if (exist(savename,'file'))>0
   cd(path.main)
   
end

% set up diary
diarySetup(path.diaries, [exptname num2str(subjNo)])

 % odor setup
 if v.odorFlag>0
    % *** mini-VAS stuff *** % DEBUG
    javaaddpath('.');
    v = minivas(); % connect miniVAS - might have to use javaaddpath to add the scripts folder the first time you run this??
    v.allChannelsOff(); % make sure all channels off at start of session
    
    %enable all channels
    v.setChannelsEnabled([ones(1,30)]);
    
 end



% %%%% run main tasks %%%% %
data = [];
c = exptSetup;
c.path = path;

% override exptSetup here
Screen('TextSize',c.Window,round(c.scrsz(3)/50));

% add session specific data
c.subjNo = subjNo;
c.exptname = exptname;

% Huettel ambig task
[HuettelData] = smellHuettelRisk(c,v); 
data.HuettelData = HuettelData;
% 





% save data

cd(path.data)
savename = [exptname num2str(subjNo) '.mat'];
save(savename, 'data');

ListenChar(0)
sca

end