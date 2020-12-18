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


function [data] = load_mod_logfile(proj,subj_study,name,run_id,log_name,Ntail)


tmp_path = [proj.path.code,'tmp/'];

% Create a list of log files for study and subject
cmd = ['! ls ',proj.path.raw_data,subj_study,'/logfiles/', ...
       subj_study,'_',name,'/',log_name,'_experiment*.log > ',tmp_path,subj_study,'_', ...
       name,'_log_list.txt'];
%disp(cmd);
eval(cmd);

% Extract filename of modulate 1
cmd = ['! sed -n ''',num2str(run_id),'{p;q}'' ',tmp_path,subj_study,'_',name,...
       '_log_list.txt > ',tmp_path,log_name,'_',num2str(run_id),'_logfile.txt'];
%disp(cmd);
eval(cmd);

fid = fopen([tmp_path,log_name,'_',num2str(run_id),'_logfile.txt'],'r');
filename = fscanf(fid,'%s');
fclose(fid);

% Load the correct logfile
cmd = ['! tail ',filename,' -n +',num2str(Ntail),' > ',tmp_path,log_name,'_',num2str(run_id),'_log.txt'];
%disp(cmd);
eval(cmd);
data = readtable([tmp_path,log_name,'_',num2str(run_id),'_log.txt']);
