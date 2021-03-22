%%========================================
%%========================================
%%
%% Keith Bush, PhD (2019)
%% Univ. of Arkansas for Medical Sciences
%% Brain Imaging Research Center (BIRC)
%%
%%========================================
%%========================================

tic

%% ----------------------------------------
%% Clean up matlab environment
matlab_reset;

%% ----------------------------------------
%% Link all source code
addpath(genpath('./source/'));

% ----------------------------------------
% Initialize the projects directories and parameters.
init_project;

% % ----------------------------------------
% % Clear and reconstruct the project data folder
% clean_project;
% 
% % ----------------------------------------
% % Map top-level json and tsv files (using templates)
% % where appropriate
% map_study_readme;
% map_study_demo2tsv;    % saves directly to top-level data directory
% map_study_json;        % saves json to top-level data directory
% 
% % ----------------------------------------
% % Subject-level data mapping
% % copies, renames, zips MRI data
% % copies subject tsv and json files
% map_subj_dir;
% map_subj_bold;
% map_subj_physio;
map_subj_id_events_log2tsv; 
map_subj_mod_events_log2tsv;
map_subj_json;

toc
