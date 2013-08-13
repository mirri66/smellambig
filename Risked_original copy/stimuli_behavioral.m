function stimuli_behavioral()

fid = fopen('stimuli.txt','w');
for i = 1:8,
    load(strcat('trialinfo_behav_',num2str(i)));
    for j = 1:size(trial_info,1)
        for k = 1:size(trial_info,2)
            if (k == 4)
                fprintf(fid,'\t%5.2f\t',trial_info(j,k));
            else
                fprintf(fid,'%4d\t',trial_info(j,k));
            end;
        end;
        fprintf(fid,'%4d\t%4d\n',paradigm{1}(j),paradigm{2}(j));
    end;
end;
fclose(fid);