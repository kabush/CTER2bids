%%========================================
%%========================================
%%
%% Keith Bush, PhD (2020)
%% Univ. of Arkansas for Medical Sciences
%% Brain Imaging Research Center (BIRC)
%%
%%========================================
%%========================================

%% Initialize log section
logger(['************************************************'],proj.path.logfile);
logger([' Map Subject-level MRI data          '],proj.path.logfile);
logger(['************************************************'],proj.path.logfile);

%% Load in path data
load('proj.mat');

%% Create the subjects to be analyzed (possible multiple studies)
subjs = load_subjs(proj);

%% Preprocess fMRI of each subject in subjects list 
for i=1:numel(subjs)

    %% extract subject info
    subj_study = subjs{i}.study;
    name = subjs{i}.name;

    %% debug
    logger([subj_study,':',name],proj.path.logfile);

    %% ----------------------------------------
    %% map anatomical mri (anat directory)

    % define location
    anat_path = [proj.path.data,'sub-',name,'/anat/'];

    % % non-defaced version (FAST)
    % cmd = ['! cp ',proj.path.raw_data,'CTER/mri/',subj_study,'_',name,'/',...
    %        subj_study,'_',name,'_sT1W*.nii ',anat_path,'sub-',name,'_T1w.nii'];
    % disp(cmd);
    % eval(cmd);
    
    % place DEFACED T1 in directory (SLOW)
    cmd = ['! /usr/local/miniconda3/bin/python ',...
           '/home/kabush/workspace/code/pydeface/pydeface --outfile ',...
           anat_path,'sub-',name,'_T1w.nii ',...
           proj.path.raw_data,'CTER/mri/',subj_study,'_',name,'/',...
           subj_study,'_',name,'_sT1W*.nii '];
    disp(cmd);
    eval(cmd);

    % gzip
    cmd = ['! gzip ',anat_path,'sub-',name,'_T1w.nii'];
    disp(cmd);
    eval(cmd);    

    %% ----------------------------------------
    %% map functional mri (func directory)

    % define location
    func_path = [proj.path.data,'sub-',name,'/func/'];

    % copy raw identify 1 (and rename)
    cmd = ['! cp ',proj.path.raw_data,'CTER/mri/',subj_study,'_',name,'/',...
           subj_study,'_',name,'_Identify1_*.nii ',func_path,'sub-',name,'_task-identify1_bold.nii'];
    disp(cmd);
    eval(cmd);

    % copy raw identify 2 (and rename)
    cmd = ['! cp ',proj.path.raw_data,'CTER/mri/',subj_study,'_',name,'/',...
           subj_study,'_',name,'_Identify2_*.nii ',func_path,'sub-',name,'_task-identify2_bold.nii'];
    disp(cmd);
    eval(cmd);

    % copy raw rest (and rename)
    cmd = ['! cp ',proj.path.raw_data,'CTER/mri/',subj_study,'_',name,'/',...
           subj_study,'_',name,'_Rest*.nii ',func_path,'sub-',name,'_task-rest_bold.nii'];
    disp(cmd);
    eval(cmd);

    % copy raw modulate1 (and rename)
    cmd = ['! cp ',proj.path.raw_data,'CTER/mri/',subj_study,'_',name,'/',...
           subj_study,'_',name,'_Modulate1*.nii ',func_path,'sub-',name,'_task-modulate1_bold.nii'];
    disp(cmd);
    eval(cmd);

    % copy raw modulate2 (and rename)
    cmd = ['! cp ',proj.path.raw_data,'CTER/mri/',subj_study,'_',name,'/',...
           subj_study,'_',name,'_Modulate2*.nii ',func_path,'sub-',name,'_task-modulate2_bold.nii'];
    disp(cmd);
    eval(cmd);

    %%% logger('*** TICKET **** uncomment before using for real!',proj.path.logfile);

    % gzip all files
    cmd = ['! gzip ',func_path,'*'];
    disp(cmd);
    eval(cmd);    

end
