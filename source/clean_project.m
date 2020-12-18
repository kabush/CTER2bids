%%========================================
%%========================================
%%
%% Keith Bush, PhD (2018)
%% Univ. of Arkansas for Medical Sciences
%% Brain Imaging Research Center (BIRC)
%%
%%========================================
%%========================================

%% ========================================
%% Load in path data
load('proj.mat');

if(proj.flag.clean_build)

    %% Set-up base data pathway
    disp(['Removing ',proj.path.data]);
    eval(['! rm -rf ',proj.path.data]);

    %% Create project directory
    disp(['Creating ',proj.path.data,' and all sub-directories']);
    eval(['! mkdir ',proj.path.data]);

end