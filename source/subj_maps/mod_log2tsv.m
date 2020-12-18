%%========================================
%%========================================
%%
%% Keith Bush (2020)
%% Univ. of Arkansas for Medical Sciences
%% Brain Imaging Research Center (BIRC)
%%
%%========================================
%%========================================

function [log_table] = mod_log2tsv(proj,design,subj_study,name,run_id)
%
%

% ----------------------------------------
% Load the top-level logfile (stims and fb trials
stim = load_mod_logfile(proj,subj_study,name,run_id,'logfile',2);
fb = load_mod_logfile(proj,subj_study,name,run_id,'feedback',1);
dyn = load_mod_logfile(proj,subj_study,name,run_id,'dynamic',1);

% times
mod_time = table2array(stim(:,4));
fb_time = table2array(fb(:,6));
fb_values = table2array(fb(:,4));
dyn_time = table2array(dyn(:,5));

% recreate average feedback
avg_fb_values = 0*fb_values;
for i=3:numel(fb_values)
    all_idx = (i-2):i;
    tcp_samples = fb_values(all_idx);
    for j=1:numel(tcp_samples)

        tcp_samples(j) = tcp_samples(j) - mod(tcp_samples(j),100);
        tcp_samples(j) = tcp_samples(j)/100-50;
    end
    avg_fb_values(i) = mean(tcp_samples)/50;
end


% states
mod_state = table2array(stim(:,3));
fb_state = table2array(fb(:,3));
dyn_state_raw = table2array(dyn(:,1));

% img ids (Adding 1  to convert python
% indices to matlab indices
dyn_img_idx_raw = table2array(dyn(:,2))+1;

% thresholds 
dyn_thresh_trigger =table2array(dyn(:,3));
dyn_fb_trigger = table2array(dyn(:,4));

% convert text dyn_state to numeric
dyn_state = [];
for j=1:numel(dyn_state_raw)

    if(strcmp(dyn_state_raw{j},'img')~=0)
        dyn_state = [dyn_state;10];
    end
    
    if(strcmp(dyn_state_raw{j},'fix')~=0)
        dyn_state = [dyn_state;15];
    end

    if(strcmp(dyn_state_raw{j},'e_img')~=0)
        dyn_state = [dyn_state; 99];
    end

end

%% IMPORTANT!!! There is a bug in the logging
%% logic that logs additional images even
%% when the dynamic image has been triggered
%% Find and remove bad dynamic logs (of images)
ids_to_keep = [];

for j=1:numel(dyn_state)
    state = dyn_state(j);
    
    % ----------------------------------------
    if(state==10)

        % if img of followed by fix for same img_id
        if(j<numel(dyn_state) & dyn_state(j+1)==15 & ...
           dyn_img_idx_raw(j) == dyn_img_idx_raw(j+1))
            ids_to_keep = [ids_to_keep,j];


        else

            %%% Very special case (handles CTER_021 Run2 bug)
            %% if img is followed by img which is followed
            %% by a fix
            %% 
            if(j<numel(dyn_state)-1)
                
                if(dyn_state(j+1)==10 & ...
                   dyn_state(j+2)==15 & ...
                   dyn_img_idx_raw(j) ~= dyn_img_idx_raw(j+1) & ...
                    j==1)

                    ids_to_keep = [ids_to_keep,j];
                    
                end

            end

        end

    end

    % ----------------------------------------
    if(state==99)
        ids_to_keep = [ids_to_keep,j];
    end

end

% debug
dyn_state_pre = dyn_state;

%% Calculating the duration of volume-driven stimuli
dyn_duration = [];
dyn_state(max(ids_to_keep))
if(dyn_state(max(ids_to_keep))==99)
    dyn_duration = dyn_time(ids_to_keep(1:end-1)+1)-dyn_time(ids_to_keep(1:end-1));
    dyn_duration = [dyn_duration;-99];
else
    dyn_duration = dyn_time(ids_to_keep+1)-dyn_time(ids_to_keep);
end

%% Clean version of dynamic log!!!
dyn_state = dyn_state(ids_to_keep);
dyn_time = dyn_time(ids_to_keep);
dyn_img_idx = dyn_img_idx_raw(ids_to_keep);
dyn_thresh_trigger = dyn_thresh_trigger(ids_to_keep);
dyn_fb_trigger = dyn_fb_trigger(ids_to_keep);

%% Correcting the duration of emergency stimuli to -99
%% to aide in processing later
emg_ids = find(dyn_state==99);
dyn_duration(emg_ids) = -99;

% [dyn_state,dyn_time,dyn_duration] % debug

%% This logic controls for missing values 
dyn_present_ids = find(design.present_seq==1);
dyn_val = [];
dyn_aro = [];
for j=1:numel(dyn_img_idx)
    match_idx = find(dyn_present_ids==dyn_img_idx(j));
    dyn_val = [dyn_val;design.fs_valence_seq(match_idx)];
    dyn_aro = [dyn_aro;design.fs_arousal_seq(match_idx)];
end

%% Should be scaled to CURRENT Subject (even if error above)
dyn_imgs = design.img_id_seq(dyn_img_idx);
mod_imgs = design.img_id_seq(find(design.present_seq==0));


% debug
% disp([subj_study,'_',name,': ',num2str(numel(unique(dyn_img_idx)))]);


%% ========================================
%% concatenate an extra time-point to make logic
%% much easier
mod_time = [mod_time;99999999.0];
fb_time = [fb_time;99999999.0];
fb_values = [fb_values;99999999.0];
dyn_time = [dyn_time;99999999.0];    

Nmod = numel(mod_time);
Nfb = numel(fb_time);
Ndyn = numel(dyn_time);

%% ========================================
%% concatenate an extra false state to make
%% logic much easier
mod_state = [mod_state;-1];
fb_state = [fb_state;-1];
dyn_state = [dyn_state;-1];

%% Initialize logging loop
idx = [1,1,1]; %mod,fb,dyn
t = 0.0;
dt = 0.001;
notdone = 1;

%% Re-scale the fb
scale_max_init = 0.5;
scale_min_init = 0.0;
scale_change_rate = 0.5;
scale_max = scale_max_init;
scale_min = scale_max_init;

%% logging counts
log_cnt = 0;
dyn_init_cnt = 0;
dyn_img_cnt = 0;
mod_img_cnt = 0;
case_5_cnt = 0;
case_6_cnt = 0;

%% reset log storge
onset = {};
duration = {};
type = {};
dsgn_onset = {};
dsgn_duration = {};
img_id = {};
valence = {};
arousal = {};
database = {};
feedback = {};
avg_feedback = {};
threshold = {};

while(notdone)
    
    %% Update time
    t = t+dt;
    
    %% Arrange logfile times of next events
    curr_times = [mod_time(idx(1)),fb_time(idx(2)),dyn_time(idx(3))];
   
    %% ----------------------------------------
    %%calculate current feedback (value seen on screen)

    % value shipped from real-time computer (tcp_sample)
    % stripped of lower order values
    tcp_sample = fb_values(idx(2));
    tcp_sample = tcp_sample - mod(tcp_sample,100);
    
    if(tcp_sample>scale_max) 
        tmp_diff = tcp_sample-scale_max;
        scale_max = scale_max + scale_change_rate*tmp_diff;
    end
    sample = tcp_sample;
    magnitude = scale_max - scale_min;
    value = tcp_sample-scale_min;
    value = max(0.0,min(1.0,value/magnitude)); %scale to [0,1]
    curr_fb_value = value;


    %avg value
    avg_fb = avg_fb_values(idx(2));

    %% ----------------------------------------
    %% Get min time and indx
    min_time = min(curr_times);
    min_idx = find(curr_times==min_time);

    %% ----------------------------------------
    %% SPECIAL CASES (2 time-indices match!!!)
    if(numel(min_idx)==2)

        %% FB and DYN same time (special case)   
        if(min_idx(1)==2 & min_idx(2)==3)
            min_idx = 4;
        end

        %% MOD and FB same time (special case)   
        if(min_idx(1)==1 & min_idx(2)==2)
            min_idx = 5;
        end

    end

    %% ----------------------------------------
    %% SPECIAL CASES (3 time-indices match!!!)
    if(numel(min_idx)==3)
        min_idx = 6; 
    end

    %% Handle next logfile event
    if(t>min_time)


        % disp(['time=',num2str(min_time),' | [',...
        %       num2str(mod_time(idx(1))),', ',...
        %       num2str(fb_time(idx(2))),', ',...
        %       num2str(dyn_time(idx(3))),']']);

        switch(min_idx)

          %% ========================================
          %% ========================================
          case 1
            
            % disp('time driven event');
            state = mod_state(idx(min_idx));
            % disp(['   ',num2str(state)]);

            % ----------------------------------------
            if (state==10)

                % disp('   ***time driven: STIM EVENT***');
                fb_stim_trigger = 0; % turn off fb stim


                %%%% DURATION IS NEXT time-driven event
                end_time = mod_time(idx(min_idx)+1);

                % output master log data
                log_cnt = log_cnt+1;
                mod_img_cnt = mod_img_cnt+1;
                onset{log_cnt} = min_time;
                duration{log_cnt} = end_time-min_time; 
                type{log_cnt} = 'ex_stim';
                dsgn_onset{log_cnt} = design.po_time_seq(mod_img_cnt);
                dsgn_duration{log_cnt} = proj.param.trg.stim_t;
                img_id{log_cnt} = mod_imgs(mod_img_cnt);
                valence{log_cnt} = design.po_valence_seq(mod_img_cnt);
                arousal{log_cnt} = design.po_arousal_seq(mod_img_cnt);
                database{log_cnt} = 'iaps';
                feedback{log_cnt} = 'n/a';
                avg_feedback{log_cnt} = 'n/a';
                threshold{log_cnt} = 'n/a';

            end

            % ----------------------------------------
            if (state==15)
                % disp('   ***time driven: FIX EVENT***');
                fb_stim_trigger = 0; % turn off fb stim
            end

            % ----------------------------------------
            if (state==40)
                
                % disp('   ***time driven: FB EVENT***');
                fb_stim_trigger = 0; %turn off fb stim

                %%%% DURATION IS NEXT time-driven event
                end_time = fb_time(idx(2));

                % output master log data
                log_cnt = log_cnt+1;
                dyn_init_cnt = dyn_init_cnt+1;
                onset{log_cnt} = min_time;
                duration{log_cnt} = end_time-min_time; %%%2.0; % *** TICKET ***
                type{log_cnt} = 'fb_init';
                dsgn_onset{log_cnt} = design.fs_time_seq(dyn_init_cnt);
                dsgn_duration{log_cnt} = 'n/a';
                img_id{log_cnt} = 'n/a';
                valence{log_cnt} = 'n/a';
                arousal{log_cnt} = 'n/a';
                database{log_cnt} = 'n/a';
                feedback{log_cnt} = 0.5; % from rt_CTER code
                avg_feedback{log_cnt} = 'n/a';
                threshold{log_cnt} = 'n/a';

            end

            % ----------------------------------------
            % UPDATE to next time-point in this log source
            idx(min_idx)=idx(min_idx)+1;

          %% ========================================
          %% ========================================
          case 2

            % disp('volume driven event');
            state = fb_state(idx(min_idx));
            % disp(['   ',num2str(state)]);

            % ----------------------------------------
            if(state==15)
                fb_stim_trigger = 0;
            end

            % ----------------------------------------
            if(state==40)

                % disp('   ***volume driven: FB EVENT***');

                if(~fb_stim_trigger) %% Only log if fb not yet triggered

                    % %calculate average feedback
                    curr_idx = idx(2);
                    % all_idx = (curr_idx-2):curr_idx;
                    % tcp_samples = fb_values(all_idx);
                    % 
                    % for j=1:numel(tcp_samples)
                    %     tcp_samples(j) = tcp_samples(j) - mod(tcp_samples(j),100);
                    %     tcp_samples(j) = tcp_samples(j)/100-50;
                    % end
                    % avg_fb = mean(tcp_samples)/50;


                    %%%% DURATION IS NEXT time-driven event
                    end_time = fb_time(curr_idx+1);

                    % output master log data
                    log_cnt = log_cnt+1;
                    onset{log_cnt} = min_time;
                    duration{log_cnt} = end_time-min_time; %%%-99.0;
                    type{log_cnt} = 'fb';
                    dsgn_onset{log_cnt} = 'n/a';
                    dsgn_duration{log_cnt} = proj.param.mri.TR;
                    img_id{log_cnt} = 'n/a';
                    valence{log_cnt} = 'n/a';
                    arousal{log_cnt} = 'n/a';
                    database{log_cnt} = 'n/a';
                    feedback{log_cnt} = curr_fb_value;
                    avg_feedback{log_cnt} = avg_fb;
                    threshold{log_cnt} = 'n/a';
                end
            end

            % ----------------------------------------
            % UPDATE to next time-point in this log source                
            idx(min_idx)=idx(min_idx)+1;

          %% ========================================
          %% ========================================
          case 3

            % disp('dyn logic');
            state = dyn_state(idx(min_idx)); %% hard-code
            % disp(['   ',num2str(state)]);

            % ----------------------------------------
            if(state==10)

                % disp('   ***volume driven: STIM EVENT***');
                fb_stim_trigger = 1;  %% fb image triggered

                % %%%% DURATION IS NEXT time-driven event
                % end_time = dyn_time(idx(min_idx)+1);
                
                % output master log data
                log_cnt = log_cnt+1;
                dyn_img_cnt = dyn_img_cnt+1;
                onset{log_cnt} = min_time;
                duration{log_cnt} = dyn_duration(idx(min_idx)); %2.0; % *** TICKET ***
                type{log_cnt} = 'fb_stim';
                dsgn_onset{log_cnt} = 'n/a';
                dsgn_duration{log_cnt} = proj.param.trg.stim_t;
                img_id{log_cnt} = dyn_imgs(dyn_img_cnt);                    
                valence{log_cnt} = dyn_val(dyn_img_cnt);
                arousal{log_cnt} = dyn_aro(dyn_img_cnt);
                database{log_cnt} = 'iaps';
                feedback{log_cnt} = curr_fb_value;

                disp(num2str(avg_fb));
                disp(num2str(dyn_fb_trigger(dyn_img_cnt)));

                avg_feedback{log_cnt} = dyn_fb_trigger(dyn_img_cnt);
                threshold{log_cnt} = dyn_thresh_trigger(dyn_img_cnt);

            end

            % ----------------------------------------
            if(state==99)

                % disp('   ***fb driven: EMERGENCY STIM EVENT***');
                fb_stim_trigger = 1;  %%% IMAGE TRIGGERED

                end_time = mod_time(idx(1)); % next time-driven fixation

                %%%%%%%%%%%%%%%%%%%%%%%%%
                log_cnt = log_cnt+1;
                dyn_img_cnt = dyn_img_cnt+1;
                onset{log_cnt} = min_time;
                duration{log_cnt} = end_time - min_time; % -99.0; % *** TICKET ***
                type{log_cnt} = 'em_stim';
                dsgn_onset{log_cnt} = 'n/a';
                dsgn_duration{log_cnt} = proj.param.trg.stim_t;
                img_id{log_cnt} = dyn_imgs(dyn_img_cnt);                    
                valence{log_cnt} = dyn_val(dyn_img_cnt);
                arousal{log_cnt} = dyn_aro(dyn_img_cnt);
                database{log_cnt} = 'iaps';
                feedback{log_cnt} = curr_fb_value;
                avg_feedback{log_cnt} = 'n/a'; %dyn_fb_trigger(dyn_img_cnt);
                threshold{log_cnt} = 'n/a'; %dyn_thresh_trigger(dyn_img_cnt);
            end

            % ----------------------------------------
            % UPDATE to next time-point in this log source
            idx(min_idx)=idx(min_idx)+1;

          %% ========================================
          %% ========================================

          case 4
            
            % disp('=============SPECIAL CASE (2==3) ===================');
            % disp('dyn logic');

            state = dyn_state(idx(3)); %% hard-code

            % disp(['   ',num2str(state)]);
            % min_time

            % ----------------------------------------
            if(state==10)

                % debug
                % disp('   ***fb driven: STIM EVENT***');

                fb_stim_trigger = 1;  %%% IMAGE TRIGGERED

                %%%%%%%%%%%%%%%%%%%%%%%%%
                log_cnt = log_cnt+1;
                dyn_img_cnt = dyn_img_cnt+1;
                onset{log_cnt} = min_time;
                duration{log_cnt} = dyn_duration(idx(3)); %2.0; % *** TICKET ***
                type{log_cnt} = 'fb_stim';
                dsgn_onset{log_cnt} = 'n/a';
                dsgn_duration{log_cnt} = proj.param.trg.stim_t;
                img_id{log_cnt} = dyn_imgs(dyn_img_cnt); 
                valence{log_cnt} = dyn_val(dyn_img_cnt);
                arousal{log_cnt} = dyn_aro(dyn_img_cnt);
                database{log_cnt} = 'iaps';
                feedback{log_cnt} = curr_fb_value;

                disp([num2str(avg_fb),', ',num2str(dyn_fb_trigger(dyn_img_cnt))]);

                avg_feedback{log_cnt} = dyn_fb_trigger(dyn_img_cnt);
                threshold{log_cnt} = dyn_thresh_trigger(dyn_img_cnt);
            end

            % ----------------------------------------
            if(state==99)

                % debug
                % disp('   ***fb driven: EMERGENCY STIM EVENT***');

                fb_stim_trigger = 1;  %%% IMAGE TRIGGERED

                end_time = mod_time(idx(1)); %next time-driven fixation

                %%%%%%%%%%%%%%%%%%%%%%%%%
                log_cnt = log_cnt+1;
                dyn_img_cnt = dyn_img_cnt+1;
                onset{log_cnt} = min_time;
                duration{log_cnt} = end_time - min_time; %%2.0; % *** TICKET ***
                type{log_cnt} = 'em_stim';
                dsgn_onset{log_cnt} = 'n/a';
                dsgn_duration{log_cnt} = proj.param.trg.stim_t;
                img_id{log_cnt} = dyn_imgs(dyn_img_cnt);                    
                valence{log_cnt} = dyn_val(dyn_img_cnt);
                arousal{log_cnt} = dyn_aro(dyn_img_cnt);
                database{log_cnt} = 'iaps';
                feedback{log_cnt} = curr_fb_value;
                avg_feedback{log_cnt} = 'n/a'; %dyn_fb_trigger(dyn_img_cnt);
                threshold{log_cnt} = 'n/a'; %dyn_thresh_trigger(dyn_img_cnt);
            end

            % ----------------------------------------
            idx(2)=idx(2)+1;
            idx(3)=idx(3)+1;

          case 5

            case_5_cnt = case_5_cnt + 1;
            
            % disp('=============SPECIAL CASE (1==2) ===================');
            % disp('mod logic');

            state = mod_state(idx(1));

            % disp(['   ',num2str(state)]);
            % min_time

            % ----------------------------------------
            if (state==10)

                % disp('   ***time driven: stim event***');
                fb_stim_trigger = 0;

                %%%%%%%%%%%%%%%%%%%%%%%%%
                log_cnt = log_cnt+1;
                mod_img_cnt = mod_img_cnt+1;
                onset{log_cnt} = min_time;
                duration{log_cnt} = 2.0; % *** TICKET ***
                type{log_cnt} = 'ex_stim';
                dsgn_onset{log_cnt} = design.po_time_seq(mod_img_cnt);
                dsgn_duration{log_cnt} = proj.param.trg.stim_t;
                img_id{log_cnt} = mod_imgs(mod_img_cnt);
                valence{log_cnt} = design.po_valence_seq(mod_img_cnt);
                arousal{log_cnt} = design.po_arousal_seq(mod_img_cnt);
                database{log_cnt} = 'iaps';
                feedback{log_cnt} = 'n/a';
                avg_feedback{log_cnt} = 'n/a';
                threshold{log_cnt} = 'n/a';

            end

            % ----------------------------------------
            if (state==40)

                % disp('   ***time driven: fb event***');
                fb_stim_trigger = 0;

                %%%%%%%%%%%%%%%%%%%%%%%%%
                log_cnt = log_cnt+1;
                dyn_init_cnt = dyn_init_cnt+1;
                onset{log_cnt} = min_time;
                duration{log_cnt} = 2.0; % *** TICKET ***
                type{log_cnt} = 'fb_init';
                dsgn_onset{log_cnt} = design.fs_time_seq(dyn_init_cnt);
                dsgn_duration{log_cnt} = 'n/a';
                img_id{log_cnt} = 'n/a';
                valence{log_cnt} = 'n/a';
                arousal{log_cnt} = 'n/a';
                database{log_cnt} = 'n/a';
                feedback{log_cnt} = 0.5; %alpha_init=0.5
                avg_feedback{log_cnt} = 'n/a';
                threshold{log_cnt} = 'n/a';
            end

            % ----------------------------------------
            % UPDATE to next time-point in this log source
            idx(1)=idx(1)+1;
            idx(2)=idx(2)+1;

          otherwise

            case_6_cnt = case_6_cnt + 1;
            
            % disp('=============SPECIAL CASE (1==2==3) =================');

            idx(1)=idx(1)+1;
            idx(2)=idx(2)+1;
            idx(3)=idx(3)+1;

        end


        %% Loop termination (all times have been explored)
        if(idx(1)==Nmod & idx(2)==Nfb & idx(3)==Ndyn)
            notdone = 0;
        end

    end

end %while

%% Test of parsing
fb_state = 0;

for j=1:numel(type)

    if(strcmp(type(j),'fb_init'))
        fb_state = 1;
    end

    if(strcmp(type(j),'fb_stim'))
        if(fb_state)
            fb_state = 0;
        else
            logger('    error: stim w/o fb state',proj.path.logfile);
        end
    end

    if(strcmp(type(j),'em_stim'))
        if(fb_state)
            fb_state = 0;
        else
            logger('    error: stim emg w/o fb state',proj.path.logfile);
        end
    end

    if(strcmp(type(j),'ex_stim'))
        if(fb_state)
            logger('    error: ex stim in fb state',proj.path.logfile);
            fb_state = 0;
        end
    end

end

ex_stim_cnt = numel(find(strcmp(type,'ex_stim')~=0));
fb_stim_cnt = numel(find(strcmp(type,'fb_stim')~=0));
em_stim_cnt = numel(find(strcmp(type,'em_stim')~=0));

logger(['    N_ex_stim=',num2str(ex_stim_cnt)],proj.path.logfile);
logger(['    N_fb_stim=',num2str(fb_stim_cnt+em_stim_cnt)],proj.path.logfile);

real_img_seq = design.img_id_seq;
built_img_seq = cell2mat(img_id(setdiff(1:numel(img_id), ...
                               find(strcmp(img_id,'n/a')))));

seq_agree = 1;

disagree_idx = -1;
for j=1:numel(built_img_seq)
    built_img = built_img_seq(j);
    real_img = real_img_seq(j);
    if(built_img~=real_img)
        seq_agree = 0;
        if(disagree_idx == -1)
            disagree_idx = j;
        end
    end
end

logger(['    seq agree?: ',num2str(seq_agree)],proj.path.logfile);
if(~seq_agree)
    logger(['    disagree indx: ',num2str(disagree_idx)],proj.path.logfile);
end


% reformat the floating point numbers so that table writes
% to file cleanly
for i=1:numel(onset)
    onset{i} = sprintf('%05.3f',onset{i});

    duration{i} = sprintf('%05.3f',duration{i});

    if(~strcmp(dsgn_onset{i},'n/a'))
        dsgn_onset{i} = sprintf('%05.3f',dsgn_onset{i});
    end

    if(~strcmp(dsgn_duration{i},'n/a'))
        dsgn_duration{i} = sprintf('%3.1f',dsgn_duration{i});
    end

    if(~strcmp(feedback{i},'n/a'))
        feedback{i} = sprintf('%05.3f',feedback{i});
    end

    if(~strcmp(avg_feedback{i},'n/a'))
        avg_feedback{i} = sprintf('%05.3f',avg_feedback{i});
    end

    if(~strcmp(threshold{i},'n/a'))
        threshold{i} = sprintf('%05.3f',threshold{i});
    end

end

% Orient so table detec variable names as column headings
onset = onset';
duration = duration';
trial_type =  type'; %name change to satisfy BIDS validator
dsgn_onset = dsgn_onset';
dsgn_duration = dsgn_duration';
identifier = img_id';
valence = valence';
arousal = arousal';
database =  database';
feedback = feedback';
avg_feedback = avg_feedback';
threshold = threshold';

% build table
log_table = table(onset,...
                  duration,...
                  trial_type,...
                  dsgn_onset,...
                  dsgn_duration,...
                  database,...
                  identifier,...
                  valence,...
                  arousal,...
                  feedback,...
                  avg_feedback,...
                  threshold);
