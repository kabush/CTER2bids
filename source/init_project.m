%%========================================
%%========================================
%%
%% Keith Bush, PhD (2018)
%% Univ. of Arkansas for Medical Sciences
%% Brain Imaging Research Center (BIRC)
%%
%%========================================
%%========================================

%% ----------------------------------------
%% Seed random number generator
rng(1,'twister');

%% ----------------------------------------
%% Initialize project param structure
proj = struct;

%% ----------------------------------------
%% Link tools
proj.path.tools.kablab = '/home/kabush/lib/kablab/';
addpath(genpath(proj.path.tools.kablab));

%% ----------------------------------------
%% Project Flag Definitions
proj.flag.clean_build = 1;

%% ----------------------------------------
%% Project Path Definitions

%% Raw data
proj.path.raw_data = '/raw/bush/';
proj.path.raw_cog = [proj.path.raw_data,'cogbehav/'];
proj.path.raw_physio = 'physio';
proj.path.hr = [proj.path.raw_data,'kubios/']; 
proj.path.raw_logs = 'logfiles';
proj.path.raw_tabs = 'tabs';
proj.path.atlas = '/home/kabush/atlas/';
proj.path.demo = 'demo';

%% Workspace
proj.path.home = '/home/kabush/workspace/';
proj.path.code_name = 'CTER2bids';
proj.path.data_name = 'CTER';
proj.path.code = [proj.path.home,'code/',proj.path.code_name,'/'];
proj.path.data = [proj.path.home,'bids/',proj.path.data_name,'/'];
proj.path.log =[proj.path.code,'log/']; 
proj.path.fig = [proj.path.code,'fig/'];

%% Subject Lists
proj.path.subj_list = [proj.path.code,'subj_lists/'];

%% Design path (this is a meta source file)
proj.path.design = [proj.path.code,'design/'];
proj.path.mod_design = [proj.path.code,'task_design/best_design/'];

%% Template path (this is a meta source file)
proj.path.template = [proj.path.code,'template/'];

%% Logging (creates a unique time-stampted logfile)
formatOut = 'yyyy_mm_dd_HH:MM:SS';
t = datetime('now');
ds = datestr(t,formatOut);
proj.path.logfile = [proj.path.log,'logfile_',ds,'.txt'];

%% ----------------------------------------
%% Task file nomenclature
proj.path.task.name_id1 = 'Identify_run_1';
proj.path.task.name_id2 = 'Identify_run_2';
proj.path.task.name_rest = 'Rest';

%% ----------------------------------------
%% Project Parameter Definitions

%% Data source
proj.param.studies = {'CTER'};

%% fMRI Processing param
proj.param.mri.TR = 2.0;
proj.param.mri.slices = 37;
proj.param.mri.slice_pattern = 'seq+z';
proj.param.mri.do_anat = 'yes';
proj.param.mri.do_epi = 'yes';
proj.param.mri.FD_thresh = 0.5;
proj.param.mri.FD_bad_frac = 0.5;

%% Length of stimulus (in seconds)
proj.param.trg.stim_t = 2;
proj.param.trg.feel_t = 8;

%% *** Annoying extra parameter (silently swear at Philips software
%% engineers) ***  This shift is due to manner in which the design
%% was orginally constructed to accomodate the real-time
%% processing pipeline.  Prior to the Philips R5 upgrade
%% we were dropping 4 inital TRs, so the design built this in.
%% After the R5 upgrade we were dropping zero TRs but the
%% first TR is processed strangely and so is skipped. To
%% adjust for this we shift the design earlier in time by 3*TRs
%% (TR=2s). Basic problem is that the design assumed an 18 s transient period
%% at the start of the identification runs which changed to 12 s
%% following R5 upgrades (shift was introduced to keep original
%% design files intact (possibly bad decision in the long run)
proj.param.trg.r5_shift = -6;

%% ----------------------------------------
%% Write out initialized project structure
save('proj.mat','proj');

