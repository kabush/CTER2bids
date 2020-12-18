%%========================================
%%========================================
%%
%% Ivan Messias (2020)
%% Univ. of Arkansas for Medical Sciences
%% Brain Imaging Research Center (BIRC)
%%
%% Modified by Keith A. Bush (2020) - read times
%% from logfile
%%
%%========================================
%%========================================

function [log_table] = id_log2tsv(proj,design,data);

log_data = struct();

% Using design structure to pull log data
stim_log_ids = find(data(:,3)==10); %stim id from design *** TICKET ***
prep_log_ids = find(data(:,3)==20); %prep id from design *** TICKET ***
feel_log_ids = find(data(:,3)==25); %feel id from design *** TICKET ***

stim_seq = design.present_seq;
ex_stim_cnt = 0;
in_stim_cnt = 0;
tot_cnt = 0;

log_cnt = 0;

for i=1:numel(stim_seq)

    if(stim_seq(i)==1)

        ex_stim_cnt = ex_stim_cnt+1;
        tot_cnt = tot_cnt+1;
        log_cnt = log_cnt+1;

        % designed experiment
        dsgn_time = design.ex_time_seq(ex_stim_cnt)+proj.param.trg.r5_shift;
        dsgn_dur = proj.param.trg.stim_t;
        this_val = design.ex_valence_seq(ex_stim_cnt);
        this_aro = design.ex_arousal_seq(ex_stim_cnt);
        img_id = design.img_id_seq(tot_cnt);

        % true experiment
        true_time = data(stim_log_ids(tot_cnt),4);
        next_time = data(stim_log_ids(tot_cnt)+1,4);
        true_dur = next_time-true_time;

        % debug
        % disp(['ex_stim',...
        %       ', t=',num2str(dsgn_time),', t*=',num2str(true_time),...
        %       ', d=',num2str(dsgn_dur),', d*=',num2str(true_dur),...
        %       ', img=',num2str(img_id),...
        %       ', v=',num2str(this_val),', a=',num2str(this_aro)]);

        log_data.type{log_cnt} = 'ex_stim';
        log_data.db{log_cnt} = 'iaps';
        log_data.dsgn_t{log_cnt} = dsgn_time;
        log_data.true_t{log_cnt} = true_time;
        log_data.dsgn_dur_t{log_cnt} = dsgn_dur;
        log_data.true_dur_t{log_cnt} = true_dur;
        log_data.img_id{log_cnt} = img_id;
        log_data.val{log_cnt} = this_val;
        log_data.aro{log_cnt} = this_aro;

    else

        in_stim_cnt = in_stim_cnt+1;
        tot_cnt = tot_cnt+1;
        log_cnt = log_cnt+1;

        % ----------------------------------------
        % designed experiment stim
        dsgn_time = design.in_time_seq(in_stim_cnt)+proj.param.trg.r5_shift;
        dsgn_dur = proj.param.trg.stim_t;
        this_val = design.in_valence_seq(in_stim_cnt);
        this_aro = design.in_arousal_seq(in_stim_cnt);
        img_id = design.img_id_seq(tot_cnt);

        % ----------------------------------------
        % true experiment stim
        true_time = data(stim_log_ids(tot_cnt),4);
        next_time = data(stim_log_ids(tot_cnt)+1,4);
        true_dur = next_time-true_time;

        disp(['in_stim',...
              ', t=',num2str(dsgn_time),', t*=',num2str(true_time),...
              ', d=',num2str(dsgn_dur),', d*=',num2str(true_dur),...
              ', img=',num2str(img_id),...
              ', v=',num2str(this_val),', a=',num2str(this_aro)]);

        log_data.type{log_cnt} = 'in_stim';
        log_data.db{log_cnt} = 'iaps';
        log_data.dsgn_t{log_cnt} = dsgn_time;
        log_data.true_t{log_cnt} = true_time;
        log_data.dsgn_dur_t{log_cnt} = dsgn_dur;
        log_data.true_dur_t{log_cnt} = true_dur;
        log_data.img_id{log_cnt} = img_id;
        log_data.val{log_cnt} = this_val;
        log_data.aro{log_cnt} = this_aro;

        % ----------------------------------------
        %prep
        dsgn_time = dsgn_time+proj.param.trg.stim_t;
        dsgn_dur = proj.param.trg.stim_t;
        true_time = data(prep_log_ids(in_stim_cnt),4);
        next_time = data(prep_log_ids(in_stim_cnt)+1,4);
        true_dur = next_time - true_time;

        % debug
        % disp(['in_prep',...
        %       ', t=',num2str(dsgn_time),', t*=',num2str(true_time),...
        %       ', d=',num2str(dsgn_dur),', d*=',num2str(true_dur),...
        %       ', img=n/a',...
        %       ', v=n/a, a=n/a']);

        log_cnt = log_cnt+1;
        log_data.type{log_cnt} = 'in_prep';
        log_data.db{log_cnt} = 'n/a';
        log_data.dsgn_t{log_cnt} = dsgn_time;
        log_data.true_t{log_cnt} = true_time;
        log_data.dsgn_dur_t{log_cnt} = dsgn_dur;
        log_data.true_dur_t{log_cnt} = true_dur;
        log_data.img_id{log_cnt} = 'n/a';
        log_data.val{log_cnt} = 'n/a';
        log_data.aro{log_cnt} = 'n/a';

        % ----------------------------------------
        % feel
        dsgn_time = dsgn_time+proj.param.trg.stim_t;
        dsgn_dur = proj.param.trg.feel_t;
        true_time = data(feel_log_ids(in_stim_cnt),4);
        next_time = data(feel_log_ids(in_stim_cnt)+1,4);
        true_dur = next_time - true_time;

        % debug 
        % disp(['in_feel',...
        %       ', t=',num2str(dsgn_time),', t*=',num2str(true_time),...
        %       ', d=',num2str(dsgn_dur),', d*=',num2str(true_dur),...
        %       ', img=n/a',...
        %       ', v=n/a, a=n/a']);

        log_cnt = log_cnt+1;
        log_data.type{log_cnt} = 'in_feel';
        log_data.db{log_cnt} = 'n/a';
        log_data.dsgn_t{log_cnt} = dsgn_time;
        log_data.true_t{log_cnt} = true_time;
        log_data.dsgn_dur_t{log_cnt} = dsgn_dur;
        log_data.true_dur_t{log_cnt} = true_dur;
        log_data.img_id{log_cnt} = 'n/a';
        log_data.val{log_cnt} = 'n/a';
        log_data.aro{log_cnt} = 'n/a';

    end
   
end

% reformat the floating point numbers so that table writes
% to file cleanly
for i=1:numel(log_data.true_t)
    log_data.true_t{i} = sprintf('%05.3f',log_data.true_t{i});
    log_data.true_dur_t{i} = sprintf('%05.3f',log_data.true_dur_t{i});
    log_data.dsgn_t{i} = sprintf('%05.3f',log_data.dsgn_t{i});
    log_data.dsgn_dur_t{i} = sprintf('%05.3f',log_data.dsgn_dur_t{i});
end

onset = log_data.true_t';
duration = log_data.true_dur_t';
dsgn_onset = log_data.dsgn_t';
dsgn_duration = log_data.dsgn_dur_t';
trial_type = log_data.type';
database = log_data.db';
identifier = log_data.img_id';
valence = log_data.val';
arousal = log_data.aro';

log_table = table(onset,...
                  duration,...
                  dsgn_onset,...
                  dsgn_duration,...
                  trial_type,...
                  database,...
                  identifier,...
                  valence,...
                  arousal);

