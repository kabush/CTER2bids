%%========================================
%%========================================
%%
%% Keith Bush, PhD (2020)
%% Univ. of Arkansas for Medical Sciences
%% Brain Imaging Research Center (BIRC)
%%
%%========================================
%%========================================

%% Load in path data
load('proj.mat');

%% Initialize log section
logger(['************************************************'],proj.path.logfile);
logger([' README           '],proj.path.logfile);
logger(['************************************************'],proj.path.logfile);

%% ----------------------------------------
%% Project README file
cmd = ['! cp ',proj.path.template,'README_template ',proj.path.data,'README'];
disp(cmd);
eval(cmd);
