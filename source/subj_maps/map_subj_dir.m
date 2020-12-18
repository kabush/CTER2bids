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
logger([' Create Subject-level directories          '],proj.path.logfile);
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
    %% make subject directory
    cmd = ['! mkdir ',proj.path.data,'sub-',name];
    disp(cmd);
    eval(cmd);

    %% ----------------------------------------
    %% map anatomical mri (anat directory)

    % create anat directory
    anat_path = [proj.path.data,'sub-',name,'/anat/'];
    cmd = ['! mkdir ',anat_path];
    disp(cmd);
    eval(cmd);

    %% ----------------------------------------
    %% map function mri (anat directory)

    % create func directory
    func_path = [proj.path.data,'sub-',name,'/func/'];
    cmd = ['! mkdir ',func_path];
    disp(cmd);
    eval(cmd);

end
