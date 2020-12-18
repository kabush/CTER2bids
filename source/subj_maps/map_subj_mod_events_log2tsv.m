 %%========================================
%%========================================
%%
%% Keith Bush, PhD (2020)
%% Univ. of Arkansas for Medical Sciences
%% Brain Imaging Research Center (BIRC)
%%
%% Co-authors: Ivan Messias (2019)
%%             Kevin Fialkowski (2019)
%%
%%========================================
%%========================================

%% Initialize log section
logger(['************************************************'],proj.path.logfile);
logger([' Map Subj-level Identify Event files from Logs  '],proj.path.logfile);
logger(['************************************************'],proj.path.logfile);

%% ========================================
%% This script merges three independent logs created
%% during the CTER real-time processing.
%% ========================================

%% Load in path data
load('proj.mat');

%% Create the subjects to be analyzed (possible multiple studies)
subjs = load_subjs(proj);

%% ========================================
%% Preprocess fMRI of each subject in subjects list 
%% ========================================
%%
%% Special Cases ***NOT*** Handled by code (Hand Edit!!!)
%%
%% Run 1 (miss-logged feedback)
%% CTER 010 (i=8):  fb_img_id=8170 
%%       ***fb image presentation not logged. All fb >= 560.01 
%%          should be removed.  Also should remove fb_init @ 558.0720.
%%          Subject would see a fixation cross throughout.
%%                                     
%% CTER 021 (i=18): fb_img_id=9570
%%       *** fb image presnetation not logged. All fb 282.104 to
%%       318.022 should be removed.  Also should removed fb_init @
%%       279.967.
%%
%% CTER 040 (i=32): fb_img_id=9830.  
%%       ***fb image presentation not logged. All fb 508.0077 to 544.0630
%%          should be removed. Also shold remove fb_init @ 506.0660.

%% Run 2 (miss-logged feedback)
%% N/A

for i = 1:numel(subjs)

    %%  Assign file paths
    design_path = proj.path.mod_design;  %raw design
    log_path = proj.path.log;  %log
    tmp_path = [proj.path.code,'tmp/'];
    
    %% extract subject info
    subj_study = subjs{i}.study;
    name = subjs{i}.name;

    %% debug
    logger([subj_study,':',name],proj.path.logfile);

    % ----------------------------------------
    % Modulate 1 Log table
    logger(['  Mod 1'],proj.path.logfile);
    run_id = 1;
    load([design_path,'run',num2str(run_id),'_design.mat']);
    design = run1_design;
    [mod1_log_table] = mod_log2tsv(proj,design,subj_study,name,run_id);

    file_name = ['sub-',name,'_task-modulate1_events.tsv'];
    func_path = [proj.path.data,'sub-',name,'/func/'];
    writetable(mod1_log_table,fullfile(func_path,file_name),'FileType','text','Delimiter','\t');

    % ----------------------------------------
    % Modulate 2 Log table
    logger(['  Mod 2'],proj.path.logfile);
    run_id = 2;
    load([design_path,'run',num2str(run_id),'_design.mat']);
    design = run2_design;
    [mod2_log_table] = mod_log2tsv(proj,design,subj_study,name,run_id);

    file_name = ['sub-',name,'_task-modulate2_events.tsv'];
    func_path = [proj.path.data,'sub-',name,'/func/'];
    writetable(mod2_log_table,fullfile(func_path,file_name),'FileType','text','Delimiter','\t');

end
