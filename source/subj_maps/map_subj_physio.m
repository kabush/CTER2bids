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
logger([' Map Subject-level BIOPAC data          '],proj.path.logfile);
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
    %% map functional physio (func directory)

    % build and write tables
    physio_mat2tsv(proj,subj_study,name,'Identify',1);
    physio_mat2tsv(proj,subj_study,name,'Identify',2);
    physio_mat2tsv(proj,subj_study,name,'Rest');
    physio_mat2tsv(proj,subj_study,name,'Modulate',1);
    physio_mat2tsv(proj,subj_study,name,'Modulate',2);

    % define location
    func_path = [proj.path.data,'sub-',name,'/func/'];

    % gzip all files
    cmd = ['! gzip ',func_path,'*_physio.tsv'];
    disp(cmd);
    eval(cmd);    

end
