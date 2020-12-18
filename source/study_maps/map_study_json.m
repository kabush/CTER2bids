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
logger([' Top-level JSON descriptors           '],proj.path.logfile);
logger(['************************************************'],proj.path.logfile);

%% ----------------------------------------
%% Study and participant json
cmd = ['! cp ',proj.path.template,'dataset_description.json ',proj.path.data];
disp(cmd);
eval(cmd);

cmd = ['! cp ',proj.path.template,'participants.json ',proj.path.data];
disp(cmd);
eval(cmd);

%% ----------------------------------------
%% ----------------------------------------
%% BOLD files

%% ----------------------------------------
%% Identify bold json
cmd = ['! cp ',proj.path.template,'task-identify_bold.json ',proj.path.data,...
      'task-identify1_bold.json'];
disp(cmd);
eval(cmd);

cmd = ['! cp ',proj.path.template,'task-identify_bold.json ',proj.path.data,...
      'task-identify2_bold.json'];
disp(cmd);
eval(cmd);
 
%% ----------------------------------------
%% Rest bold json
cmd = ['! cp ',proj.path.template,'task-rest_bold.json ',proj.path.data];
disp(cmd);
eval(cmd);

%% ----------------------------------------
%% Modulate bold json
cmd = ['! cp ',proj.path.template,'task-modulate_bold.json ',proj.path.data,...
      'task-modulate1_bold.json'];
disp(cmd);
eval(cmd);

cmd = ['! cp ',proj.path.template,'task-modulate_bold.json ',proj.path.data,...
      'task-modulate2_bold.json'];
disp(cmd);
eval(cmd);

%% ----------------------------------------
%% ----------------------------------------
%% BIOPAC (physio) files

%% ----------------------------------------
%% Identify physio json
cmd = ['! cp ',proj.path.template,'task-identify_physio.json ',proj.path.data,...
      'task-identify1_physio.json'];
disp(cmd);
eval(cmd);

cmd = ['! cp ',proj.path.template,'task-identify_physio.json ',proj.path.data,...
      'task-identify2_physio.json'];
disp(cmd);
eval(cmd);
 
%% ----------------------------------------
%% Rest physio json
cmd = ['! cp ',proj.path.template,'task-rest_physio.json ',proj.path.data];
disp(cmd);
eval(cmd);

%% ----------------------------------------
%% Modulate physio json
cmd = ['! cp ',proj.path.template,'task-modulate_physio.json ',proj.path.data,...
      'task-modulate1_physio.json'];
disp(cmd);
eval(cmd);

cmd = ['! cp ',proj.path.template,'task-modulate_physio.json ',proj.path.data,...
      'task-modulate2_physio.json'];
disp(cmd);
eval(cmd);
