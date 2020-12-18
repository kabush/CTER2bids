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

%% Load in path data
load('proj.mat');

%% Create the subjects to be analyzed (possible multiple studies)
subjs = load_subjs(proj);

%% Preprocess fMRI of each subject in subjects list 
for i=1:numel(subjs)

    %%  Assign file paths
    design_path = proj.path.design;  %raw design
    log_path = proj.path.log;  %log
    tmp_path = [proj.path.code,'tmp/'];
    
    %% extract subject info
    subj_study = subjs{i}.study;
    name = subjs{i}.name;

    %% debug
    logger([subj_study,':',name],proj.path.logfile);

    %% ----------------------------------------
    %% Pull Identify 1 log data below
    
    % Load in design files
    load([design_path,'run1_design.mat']);
    
    % Creat a list of log files for study and subject
    cmd = ['! ls ',proj.path.raw_data,subj_study,'/logfiles/', ...
           subj_study,'_',name,'/logfile_collection*.log > ',tmp_path,subj_study,'_', ...
           name,'_log_list.txt'];
    disp(cmd);
    eval(cmd);
    
    % Extract name of Identify 1
    cmd = ['! sed -n ''1{p;q}'' ',tmp_path,subj_study,'_',name,...
           '_log_list.txt > ',tmp_path,'identify_1_logfile.txt'];
    disp(cmd);
    eval(cmd);
    
    fid = fopen([tmp_path,'identify_1_logfile.txt'],'r');
    filename = fscanf(fid,'%s');
    fclose(fid);
    
    % Read the correct logfile
    cmd = ['! tail ',filename,' -n +2 > ',tmp_path,'identify_1_log.txt'];
    disp(cmd);
    eval(cmd);
    raw_log_data = csvread([tmp_path,'identify_1_log.txt']);
    
    % Pull the logfile's data
    [id1_log_table] = id_log2tsv(proj,run1_design,raw_log_data);

    % Transfer table to text file
    file_name = ['sub-',name,'_task-identify1_events.tsv'];
    func_path = [proj.path.data,'sub-',name,'/func/'];
    writetable(id1_log_table,fullfile(func_path,file_name),...
               'FileType','text','Delimiter','\t');

    % debug
    disp(' ');
    disp(' ');
    disp(' ');
    
    %% ----------------------------------------
    %% Pull Identify 2 log data below
    
    % Load in design files
    load([design_path,'run2_design.mat']);
    
    % Creat a list of log files for study and subject
    cmd = ['! ls ',proj.path.raw_data,subj_study,'/logfiles/', ...
           subj_study,'_',name,'/logfile_collection*.log > ',tmp_path,subj_study,'_', ...
           name,'_log_list.txt'];
    disp(cmd);
    eval(cmd);
    
    % Extract name of Identify 1
    cmd = ['! sed -n ''2{p;q}'' ',tmp_path,subj_study,'_',name,...
           '_log_list.txt > ',tmp_path,'identify_2_logfile.txt'];
    disp(cmd);
    eval(cmd);
    
    fid = fopen([tmp_path,'identify_2_logfile.txt'],'r');
    filename = fscanf(fid,'%s');
    fclose(fid);
    
    % Read the correct logfile
    cmd = ['! tail ',filename,' -n +2 > ',tmp_path,'identify_2_log.txt'];
    disp(cmd);
    eval(cmd);
    raw_log_data = csvread([tmp_path,'identify_2_log.txt']);
    
    % Pull the logfile's data
    [id2_log_table] = id_log2tsv(proj,run2_design,raw_log_data);
    
    % Transfer table to text file
    file_name = ['sub-',name,'_task-identify2_events.tsv'];
    func_path = [proj.path.data,'sub-',name,'/func/'];
    writetable(id2_log_table,fullfile(func_path,file_name),...
               'FileType','text','Delimiter','\t');


    % Clean-up
    eval(['! rm ',tmp_path,'*']);

end
