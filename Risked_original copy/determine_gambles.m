function [outcome] = select_gambles(subjnum)


% load up data for Main Session I
load(['RG_ambig_', int2str(subjnum), '_1.mat'])

% Choose 1 gamble
this_order = randperm(60);
trial_num = this_order(1);
%trial_num =51

ambig_prob = rand * 100;
rand_prob = rand;

choice = output(trial_num, 10);
trial_type = trial_info(trial_num,1);
this_trial = output(trial_num, :);

opt1 = this_trial(2:4);
opt2 = this_trial(5:7);

fprintf('-------Determining outcome for Gambling Circles Task: ------------\n')










if trial_type == 2
    fprintf(['selected Trial ' int2str(this_order(1)), '\n'])
    fprintf('Choices: \n')
    if opt1(3) > opt1(2)
        %Option1 = (['    Ambiguous chance of $' int2str(opt1(3)) ', otherwise $0'])
        fprintf ('    You Chose: Ambiguous chance of $%2.2f, otherwise $0 \n', opt1(3))
        opt1_win = opt1(3);
    else
        fprintf ('    You Chose: Ambiguous chance of $%2.2f, otherwise $0 \n', opt1(2))
        %Option1 = (['    Ambiguous chance of $' int2str(opt1(2)) ', otherwise $0'])
        opt1_win = opt1(2);
    end
    if opt2(3) > opt2(2)
        %Option2 = (['    Certain $' int2str(opt2(3))])
        fprintf ('    Rather than: Certain $%2.2f \n', opt2(3))
        opt2_win = opt2(3);
    else
        fprintf ('    Rather than: Certain $%2.2f \n', opt2(2))
        %Option2 = (['    Certain $' int2str(opt2(2))])
        opt2_win = opt2(2);
    end
    % what did they choose?

        fprintf('\n Determining ambiguous prob, and random number', int2str(ambig_prob))
        
        ambig_prob
        Random_outcome = rand_prob * 100
        
        if Random_outcome < ambig_prob
            fprintf('\n Outcome: --->  You won  $%2.2f!  \n', opt1_win)
            outcome = opt1_win;
        else
            fprintf('\n Outcome: --->  You lost!  sorry... \n')
            outcome = 0;
        end
elseif trial_type == 4
    fprintf(['selected Trial ' int2str(this_order(1)), '\n'])
    fprintf('Choices: \n')
    if opt1(3) > opt1(2)
        fprintf ('    You Chose: Certain $%2.2f \n', opt1(3))
        %Option1 = (['    Certain $' int2str(opt1(3))])
        opt1_win = opt1(3);
    else
        fprintf ('    You Chose: Certain $%2.2f \n', opt1(2))
        %Option1 = (['    Certain $' int2str(opt1(2))])
        opt1_win = opt1(2);
    end
    if opt2(3) > opt2(2)
        %Option2 = (['    Ambiguous chance of $' int2str(opt2(3)) ', otherwise $0'])
        
        fprintf ('    Rather than: Ambiguous chance of $%2.2f, otherwise $0', opt2(3))
        opt2_win = opt2(3);
    else
        %Option2 = (['    Ambiguous chance of $' int2str(opt2(2)) ', otherwise $0'])
        
        fprintf ('    Rather than: Ambiguous chance of $%2.2f, otherwise $0', opt2(2))
        opt2_win = opt2(2);
    end
    
    % what did they choose?
    
        fprintf('\n You collected $%2.2f! \n', opt1_win)
        outcome = opt1_win;
    
else
    if opt2(1) > 0 && opt1(1) > 0
        fprintf(['selected Trial ' int2str(this_order(1)), '\n'])
        fprintf('Choices: \n')
        if opt1(3) > opt1(2)
            fprintf ('    You chose: %2.0f %% chance of $%2.2f, otherwise $0 \n', opt1(1), opt1(3) )
            %Option1 = (['    ' int2str(opt1(1)) '% chance of $' int2str(opt1(2)) ', otherwise $' int2str(opt1(3))])
            opt1_win = opt1(3);
        else
            fprintf ('    You chose: %2.0f %% chance of $%2.2f, otherwise $0 \n', opt1(1), opt1(2) )
            %Option1 = (['    ' int2str(opt1(1)) '% chance of $' int2str(opt1(3)) ', otherwise $' int2str(opt1(2))])
            opt1_win = opt1(2);
        end
        if opt2(3) > opt2(2)
            fprintf ('    Rather than: %2.0f %% chance of $%2.2f, otherwise $0 \n', (100 - opt2(1)), opt2(3) )
            
            %Option2 = (['    ' int2str(100 - opt2(1)) '% chance of $' int2str(opt2(3)) ', otherwise $' int2str(opt2(2))])
            opt2_win = opt2(3);
        else
            
            fprintf ('    Rather than: %2.0f %% chance of $%2.2f, otherwise $0 \n', (100 - opt2(1)), opt2(2) )
            %Option2 = (['    ' int2str(100 - opt2(1)) '% chance of $' int2str(opt2(2)) ', otherwise $' int2str(opt2(3))])
            opt2_win = opt2(2);
        end
       
            fprintf('\n  Randomly selecting number from 1 to 100 \n')
            
            Random_outcome = 1-rand_prob
            
            if Random_outcome <= opt1(1)
                 fprintf('\n Outcome: --->  You won  $%2.2f!  \n', opt1_win)
                outcome = opt1_win;
            else
                fprintf('\n Outcome: --->  You lost!  sorry... \n')
                outcome = 0;
            end
       
    elseif opt2(1) == 0
        fprintf(['selected Trial ' int2str(this_order(1)), '\n'])
        fprintf('Choices: \n')
        %         Option1 = (['    ' int2str(opt1(1)) '% chance of $' int2str(opt1(2)) ', otherwise ' int2str(opt1(3))])
        %         Option2 = (['    Certain $' int2str(opt2(3))])
        if opt1(3) > opt1(2)
            fprintf ('    You Chose: %2.0f %% chance of $%2.2f, otherwise $0 \n', opt1(1), opt1(3) )
            %Option1 = (['    ' int2str(opt1(1)) '% chance of $' int2str(opt1(3)) ', otherwise ' int2str(opt1(2))])
            opt1_win = opt1(3);
        else
            fprintf ('    You Chose: %2.0f %% chance of $%2.2f, otherwise $0 \n', opt1(1), opt1(2) )
            %Option1 = (['    ' int2str(opt1(1)) '% chance of $' int2str(opt1(2)) ', otherwise ' int2str(opt1(3))])
            opt1_win = opt1(2);
        end
        if opt2(3) > opt2(2)
            fprintf ('    Rather than: Certain $%2.2f \n', opt2(3))
            %Option2 = (['    Certain $' int2str(opt2(3))])
            opt2_win = opt2(3);
        else
            fprintf ('    Rather than: Certain $%2.2f \n', opt2(2))
            %Option2 = (['    Certain $' int2str(opt2(2))])
            opt2_win = opt2(2);
        end
       
            fprintf('\n Randomly selecting number from 1 to 100 \n')
            
            Random_outcome = rand_prob *100
            
            if Random_outcome < opt1(1)
                 fprintf('\n Outcome: --->  You won  $%2.2f!  \n', opt1_win)
                outcome = opt1_win;
            else
                fprintf('\n Outcome: --->  You lost!  sorry... \n')
                outcome = 0;
            end

    elseif opt1(1) == 0
        fprintf(['selected Trial ' int2str(this_order(1)), '\n'])
        fprintf('Choices: \n')
%         Option1 = (['    Certain $' int2str(opt1(3))])
%         Option2 = (['    ' int2str(opt2(1)) '% chance of $'
%         int2str(opt2(2)) ', otherwise ' int2str(opt2(3))])
        if opt1(3) > opt1(2)
            fprintf ('    You Chose: Certain $%2.2f \n', opt1(3))
            %Option1 = (['    Certain $' int2str(opt1(3))])
            opt1_win = opt1(3);
        else
            fprintf ('    You Chose: Certain $%2.2f \n', opt1(2))
            %Option1 = (['    Certain $' int2str(opt1(2))])
            opt1_win = opt1(2);
        end
        if opt2(3) > opt2(2) 
            fprintf ('    Rather than: %2.0f %% chance of $%2.2f, otherwise $0 \n', opt2(1), opt2(3) )
            %Option2 = (['    ' int2str(opt2(1)) '% chance of $' int2str(opt2(3)) ', otherwise ' int2str(opt2(2))])
            opt2_win = opt2(3);
        else
            fprintf ('    Rather than: %2.0f %% chance of $%2.2f, otherwise $0 \n', opt2(1), opt2(2) )
            %Option2 = (['    ' int2str(opt2(1)) '% chance of $' int2str(opt2(2)) ', otherwise ' int2str(opt2(3))])
            opt2_win = opt2(2);
        end

            fprintf('\n You collected $%2.2f! \n', opt1_win)
            outcome =opt1_win;

    end
end


save(['AR_sub' int2str(subjnum) 'payout.mat'])


% 
% 
% for i = 1:100 
% results(i) = determine_gambles(subnum);
% end
% hist(results)
