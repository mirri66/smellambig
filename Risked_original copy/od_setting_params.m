
clear
    gat_trials = []; gat_para1 = []; gat_para2 = [];
for run = 1:9
    load(['trialinfo_', int2str(run), '.mat'])
    gat_trials = [gat_trials; trial_info];
    
    gat_para1 = [gat_para1 paradigm{1}]; 
    gat_para2 = [gat_para2 paradigm{2}]; 
end


a_c_trials = find(gat_trials(:,1) ==4)
c_r_trials = find(gat_trials(:,1) ==3)


a_c_param = gat_trials(a_c_trials, :)
a_c_parad1 = gat_para1(a_c_trials)
a_c_parad2 = gat_para2(a_c_trials)
c_r_param = gat_trials(c_r_trials, :)
c_r_parad1 = gat_para1(c_r_trials)
c_r_parad2 = gat_para2(c_r_trials)

temp1 = [];
temp2=[];
for i = 1:length(a_c_trials)
    o1v1(i) = a_c_param(i,2)
    o1v2(i) = a_c_param(i,3)
    o2v1(i) = a_c_param(i,5)
    o2v2(i) = a_c_param(i,6)
    o1ev(i) = a_c_param(i,4)
    o2ev(i) = a_c_param(i,7)
    
    if a_c_parad1(i) == 1
        temp1 = 0;
    elseif a_c_parad1(i) == 2
        temp1 = .25;
    elseif a_c_parad1(i) == 3
        temp1 = .50;
    elseif a_c_parad1(i) == 4
        temp1 = .75;
    elseif a_c_parad1(i) == 5
        temp1 = 1;
    end
    
    if a_c_parad2(i) == 1
        temp2 = 0;
    elseif a_c_parad2(i) == 2
        temp2 = .25;
    elseif a_c_parad2(i) == 3
        temp2 = .50;
    elseif a_c_parad2(i) == 4
        temp2 = .75;
    elseif a_c_parad2(i) == 5
        temp2 = 1;
    end
    
    o1p(i) = temp1
    o2p(i) = temp2
end

tally_a_c = [ o1p' o1v1' o1v2' o1ev' o2p' o2v1' o2v2' o2ev']


    temp1 = [];
temp2=[];
for i = 1:length(c_r_trials)
    o1v1(i) = c_r_param(i,2)
    o1v2(i) = c_r_param(i,3)
    o2v1(i) = c_r_param(i,5)
    o2v2(i) = c_r_param(i,6)
    o1ev(i) = c_r_param(i,4)
    o2ev(i) = c_r_param(i,7)
    
    if c_r_parad1(i) == 1
        temp1 = 0;
    elseif c_r_parad1(i) == 2
        temp1 = .25;
    elseif c_r_parad1(i) == 3
        temp1 = .50;
    elseif c_r_parad1(i) == 4
        temp1 = .75;
    elseif c_r_parad1(i) == 5
        temp1 = 1;
    end
    
    if c_r_parad2(i) == 1
        temp2 = 0;
    elseif c_r_parad2(i) == 2
        temp2 = .25;
    elseif c_r_parad2(i) == 3
        temp2 = .50;
    elseif c_r_parad2(i) == 4
        temp2 = .75;
    elseif c_r_parad2(i) == 5
        temp2 = 1;
    end
    
    o1p(i) = temp1
    o2p(i) = temp2
end

tally_c_r = [ o1p' o1v1' o1v2' o1ev' o2p' o2v1' o2v2' o2ev']
    
%     o1p' 
%     pause
%     o1v1' 
%     pause
%     o1v2' 
%     pause
%     o1ev' 
%     pause
%     o2p' 
%     pause
%     o2v1' 
%     pause
%     o2v2' 
%     pause
%     o2ev'
%     pause
%     
    
    
    % now that we have deciphered the old parameters, let's set up some new
    % ones...
    
    clear
    
    risk_options = [];
    ambig_options = [];
    EV_cert =[3 4 5 6 7]
    ambig_EV_ratio = [.5 1 2 3 4 5 6]
    zero_poss = [];
    %nonzero = [];
    EV_ratio = []; trial_cert = [];type=[]; zero_count=[]; count = 1;
    for j=1:length(ambig_EV_ratio) 
        for i=1:length(EV_cert)
            %nonzero = [nonzero; EV_cert(i)*(ambig_EV_ratio(j)*.7) EV_cert(i)*(ambig_EV_ratio(j)*1.3)];
            zero_poss = [zero_poss; EV_cert(i)*2*ambig_EV_ratio(j) 0 ];
            EV_ratio = [EV_ratio; ambig_EV_ratio(j)];
            trial_cert = [trial_cert; EV_cert(i)];
            type =[type; 4]; % a_c is type 4
            zero_count = [zero_count; 0];
            ambig_paradigm{1}(count) = 3;
            ambig_paradigm{2}(count) = 1;
            count=count+1;
        end
    end
    ambig_options = [type trial_cert EV_ratio zero_poss]
    ev = (zero_poss(:,1) + zero_poss(:,2))/2
    backend = [zeros((count-1)/2, 1); ones((count-1)/2, 1)]
    backend = backend(randperm(length(backend)))
    backend2 = backend(randperm(length(backend)))
    
    ambig_trial_info=[type zero_poss ev zero_count trial_cert  trial_cert  backend backend2]
    
    
    EV_cert =[3 4 5 6 7]
    risk_EV_ratio = [.5 1 1.3 1.6 1.9 2.2 2.5 3]
    p_50 = [];
    p_25 = [];
    p_75 = [];
    zero_poss_prob = [];zero_poss=[];trial_cert = [];EV_ratio =[];type=[]; 
    zero_count = []; count = 1;
    for j=1:length(risk_EV_ratio) 
        for i=1:length(EV_cert)
            zero_poss = [zero_poss; (EV_cert(i)*2 * risk_EV_ratio(j)) 0 ];
            zero_poss_prob = [zero_poss_prob; .5];
            EV_ratio = [EV_ratio; risk_EV_ratio(j)];
            trial_cert = [trial_cert; EV_cert(i)];
            type=[type;3]; % c_r = type 3
            zero_count = [zero_count; 0];
            risk_paradigm{1}(count) = 3; % p = 0.5?
            risk_paradigm{2}(count) = 1;
            count=count+1;
            
            zero_poss = [zero_poss; (EV_cert(i)*4* risk_EV_ratio(j)) 0 ];
            zero_poss_prob = [zero_poss_prob; .25];
            EV_ratio = [EV_ratio; risk_EV_ratio(j)]
            trial_cert = [trial_cert; EV_cert(i)];
            type=[type;3];
            zero_count = [zero_count; 0];
            risk_paradigm{1}(count) = 2; %p = 0.25?
            risk_paradigm{2}(count) = 1;
            count=count+1;
            
            zero_poss = [zero_poss; ceil(EV_cert(i)*1.33* risk_EV_ratio(j)) 0 ];
            zero_poss_prob = [zero_poss_prob; .75];
            EV_ratio = [EV_ratio; risk_EV_ratio(j)]
            trial_cert = [trial_cert; EV_cert(i)];
            type=[type;3];
            zero_count = [zero_count; 0];
            risk_paradigm{1}(count) = 4; % p=0.75?
            risk_paradigm{2}(count) = 1;
            count=count+1;
            
        end
    end
    %risk_options = [type trial_cert EV_ratio zero_poss zero_poss_prob]
    ev = trial_cert .* EV_ratio
    backend = [ ones((count-1), 1)]
    backend = backend(randperm(length(backend)))
    backend2 = backend(randperm(length(backend)))
    
    risk_trial_info=[type zero_poss ev zero_count trial_cert  trial_cert  backend backend2]
    
    
    trial_info = [risk_trial_info; ambig_trial_info];
    paradigmmat1 = [risk_paradigm{1}'; ambig_paradigm{1}'];
    paradigmmat2 = [risk_paradigm{2}'; ambig_paradigm{2}'];
    paradigm{1} = paradigmmat1
    paradigm{2} = paradigmmat2
    
    new_order = randperm(length(trial_info));
    trial_info = trial_info(new_order,:)
    paradigm{1} = paradigm{1}(new_order)
    paradigm{2} = paradigm{2}(new_order)
    
    save od_ambig_trial_order1.mat
    
   save('od_setting_params_output.mat')
   
   
   