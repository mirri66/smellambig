function moneylist(subjectnumber,experimenttype)
current = pwd;
%scriptpath = which(mfilename);
%cd(scriptpath(1:end-(length(mfilename)+2)));
cd(['\\Katz\Data\ExecInfo.06\Data\Behavioral\' subjectnumber]);
% if ~exist('experimenttype')
%     experimenttype = '';
% elseif strcmp(experimenttype,'scanner')==1
%     experimenttype = '';
% end

trialcounter = 3;
ingroup = 0;
for run=[1:8];
    try behavioraldata = dlmread(strcat('output_',experimenttype,'_',subjectnumber,'_',num2str(run),'.txt'),'\t',1,0);
        size(behavioraldata,1)
        for trial = 1:size(behavioraldata,1)
            trialcounter = trialcounter+1;
            ingroup = ingroup+1;
            exceldata{trialcounter,4} = strcat('$',num2str(behavioraldata(trial,3)),' (',num2str(behavioraldata(trial,2)),'%)');
            exceldata{trialcounter,5} = strcat('$',num2str(behavioraldata(trial,4)),' (',num2str(100-behavioraldata(trial,2)),'%)');
            exceldata{trialcounter,7} = strcat('$',num2str(behavioraldata(trial,6)),' (',num2str(behavioraldata(trial,5)),'%)');
            exceldata{trialcounter,8} = strcat('$',num2str(behavioraldata(trial,7)),' (',num2str(100-behavioraldata(trial,5)),'%)');
            exceldata{trialcounter,10} = strcat('$',num2str(behavioraldata(trial,12)));
            group = ceil((trialcounter-3)/20);
            exceldata{trialcounter,1} = num2str(group);
            exceldata{trialcounter,2} = num2str(ingroup);
            if ingroup == 20, ingroup = 0; end;
        end
    catch
    end
end
exceldata{3,1} = 'Group';
exceldata{3,2} = 'Trial';
exceldata{1,4} = 'Chosen';
exceldata{1,7} = 'Not Chosen';
exceldata{2,4} = 'Choice 1';
exceldata{2,5} = 'Choice 2';
exceldata{2,7} = 'Choice 1';
exceldata{2,8} = 'Choice 2';
exceldata{2,10} = 'You Won';

toexcel(exceldata,1,1,experimenttype)
cd(current)

