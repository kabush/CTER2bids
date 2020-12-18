%%========================================
%%========================================
%%
%% Keith Bush, PhD (2018)
%% Univ. of Arkansas for Medical Sciences
%% Brain Imaging Research Center (BIRC)
%%
%%========================================
%%========================================


%% Load in path data
load('proj.mat');

%% Initialize log section
logger(['************************************************'],proj.path.logfile);
logger([' Characterizing Age|Sex of Subjects             '],proj.path.logfile);
logger(['************************************************'],proj.path.logfile);

%% ----------------------------------------
%% load subjs
subjs = load_subjs(proj);

participant_id = cell(numel(subjs),1);
age = cell(numel(subjs),1);
sex = cell(numel(subjs),1);
group = cell(numel(subjs),1);

%% ----------------------------------------
%% iterate over study subjects
for i = 1:numel(subjs)

    %% extract subject info
    subj_study = subjs{i}.study;
    name = subjs{i}.name;
    id = subjs{i}.id;

    %% debug
    logger([subj_study,':',name],proj.path.logfile);

    try

        %% Load subject's sex
        demo = readtable([proj.path.raw_data,proj.path.demo,'/',subj_study,'.csv']);
        id = find(strcmp(demo.ID,name)~=0);
        participant_id{i} = name;
        age{i} = demo.Age(id);
        if(demo.Type(id)==1)
            sex{i} = 'M';
        else
            sex{i} = 'F';
        end
        group{i} = 'control';

    catch 
        disp(['  Error: could not load file(s)']);
    end

end

result = table(participant_id,age,sex,group);

path = [proj.path.data];
filename = 'participants.tsv';
writetable(result,fullfile(path,filename),'FileType','text','Delimiter','\t');


