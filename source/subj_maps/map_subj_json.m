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
logger([' Map Subject-level Event files          '],proj.path.logfile);
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
    %%  define location
    func_path = [proj.path.data,'sub-',name,'/func/'];

    %% ----------------------------------------
    %% map functional mri (func directory)

    % copy raw identify 1 (and rename)
    cmd = ['! cp ',proj.path.template,'task-identify_events.json ',...
           func_path,'sub-',name,'_task-identify1_events.json'];
    disp(cmd);
    eval(cmd);

    % copy raw identify 2 (and rename)
    cmd = ['! cp ',proj.path.template,'task-identify_events.json ',...
           func_path,'sub-',name,'_task-identify2_events.json'];
    disp(cmd);
    eval(cmd);

    % copy raw modulate1 (and rename)
    cmd = ['! cp ',proj.path.template,'task-modulate_events.json ',...
           func_path,'sub-',name,'_task-modulate1_events.json'];
    disp(cmd);
    eval(cmd);

    % copy raw modulate2 (and rename)
    cmd = ['! cp ',proj.path.template,'task-modulate_events.json ',...
           func_path,'sub-',name,'_task-modulate2_events.json'];
    disp(cmd);
    eval(cmd);

end

%     %% ----------------------------------------
%     %% map functional physio (func directory)
% 
%     % copy raw identify 1 (and rename)
%     cmd = ['! cp ',proj.path.template,'task-identify_physio.json ',...
%            func_path,'sub-',name,'_task-identify1_physio.json'];
%     disp(cmd);
%     eval(cmd);
% 
%     % copy raw identify 2 (and rename)
%     cmd = ['! cp ',proj.path.template,'task-identify_physio.json ',...
%            func_path,'sub-',name,'_task-identify2_physio.json'];
%     disp(cmd);
%     eval(cmd);
% 
%     % copy raw modulate1 (and rename)
%     cmd = ['! cp ',proj.path.template,'task-modulate_physio.json ',...
%            func_path,'sub-',name,'_task-modulate1_physio.json'];
%     disp(cmd);
%     eval(cmd);
% 
%     % copy raw modulate2 (and rename)
%     cmd = ['! cp ',proj.path.template,'task-modulate_physio.json ',...
%            func_path,'sub-',name,'_task-modulate2_physio.json'];
%     disp(cmd);
%     eval(cmd);


