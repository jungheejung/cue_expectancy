%-----------------------------------------------------------------------
% Job saved on 30-Jun-2021 19:26:24 by cfg_util (rev $Rev: 7345 $)
% spm SPM - SPM12 (7771)
% cfg_basicio BasicIO - Unknown
%-----------------------------------------------------------------------

%-----------------------------------------------------------------------
% PARAMETERS

%% 1. load parameters _______________________________________________________
% [ ] import csv files
% [ ] list corresponding regressors.
% [ ] run PVC order? or collected order?
% [ ] if run-keyword == pain, highlight -1


sub_ind = 6;
numscans = 56;
disacqs = 0;
sub = strcat('sub-', sprintf('%04d', sub_ind));

main_dir = '/Users/h/Documents/projects_local/social_influence_analysis/';
onset_dir = fullfile(main_dir, 'data', 'dartmouth', 'EV_bids');
filelist = dir(fullfile(onset_dir, sub, '*/*_events.tsv'));
T = struct2table(filelist); % convert the struct array to a table
sortedT = sortrows(T, 'name'); % sort the table by 'DOB'
fmri_dir = fullfile(main_dir,'analysis', 'fmri', 'spm', 'model-01_CcEScaA',...
'1stLevel', sub);

if ~exist(fmri_dir, 'dir')
    mkdir(fmri_dir)
end

c01 = []; c02 = []; c03 = []; c04 = [];
c05 = []; c06 = []; c07 = []; c08 = [];
c09 = []; c10 = []; c11 = []; c12 = [];
c13 = []; c14 = []; c15 = []; c16 = []; c17 = [];
%ses_str =  strcat('ses-',  sprintf('%02d', ses_num));
keySet = {'pain','vicarious','cognitive'};
con1 = [2 -1 -1];   con2 = [-1 2 -1];  con3 = [-1 -1 2];  con4 = [1 1 1];
m1 = containers.Map(keySet,con1);
m2 = containers.Map(keySet,con2);
m3 = containers.Map(keySet,con3);
m4 = containers.Map(keySet,con4);

matlabbatch = cell(1,2);
% matlabbatch{1}.spm.stats.fmri_spec.sess(run_ind) = cell(1,size(sortedT,1));
for run_ind = 1:1% size(sortedT,1)
    disp(strcat('run', num2str(run_ind)));
    scan_fname = fullfile(main_dir, 'analysis', 'SPM_example', 'sub-0006_ses-01_task-social_acq-mb8_run-1_space-MNI152NLin2009cAsym_desc-preproc_bold.nii');
    % scan_fname = fullfile(main_dir,'data', 'derivatives', 'fmriprep',...
    %     strcat('sub-', sprintf('%02d', sub)), 'func',...
    %     strcat('sub-', sprintf('%02d', sub), '_task-conformity_space-MNI152NLin6Asym_desc-smoothAROMAnonaggr_bold.nii'));
    csv_fname = fullfile(char(sortedT.folder(run_ind)), char(sortedT.name(run_ind)));
    keyword = extractBetween(sortedT.name(run_ind), 'run-0', '_events.tsv');
    task = char(extractAfter(keyword, '-'));
    cue_P = [ 0	m1(task)	0	0	0	0	0     0 0 0 0 0 0 0 0 ];
    cue_V = [ 0	m2(task)	0	0	0	0	0     0 0 0 0 0 0 0 0  ];
    cue_C = [ 0	m3(task)	0	0	0	0	0     0 0 0 0 0 0 0 0  ];
    cue_G = [ 0	m4(task)	0	0	0	0	0     0 0 0 0 0 0 0 0  ];
    stim_P = [ 0  0 0	m1(task)	0	0	0     0 0 0 0 0 0 0 0  ];
    stim_V = [ 0	0	0	m2(task)	0	0	0     0 0 0 0 0 0 0 0  ];
    stim_C = [ 0	0	0	m3(task)	0	0	0     0 0 0 0 0 0 0 0  ];
    stim_G = [ 0	0	0	m4(task)	0	0	0     0 0 0 0 0 0 0 0  ];
    stimXcue_P = [ 0	0	0	0	m1(task)	0	0     0 0 0 0 0 0 0 0  ];
    stimXcue_V = [ 0	0	0	0	m2(task)	0	0     0 0 0 0 0 0 0 0  ];
    stimXcue_C = [ 0	0	0	0	m3(task)	0	0     0 0 0 0 0 0 0 0  ];
    stimXcue_G = [ 0	0	0	0	m4(task)	0	0     0 0 0 0 0 0 0 0  ];
    stimXactual_P = [ 0	0	0	0	0	m1(task)	0     0 0 0 0 0 0 0 0  ];
    stimXactual_V = [ 0	0	0	0	0	m2(task)	0     0 0 0 0 0 0 0 0  ];
    stimXactual_C = [ 0	0	0	0	0	m3(task)	0     0 0 0 0 0 0 0 0  ];
    stimXactual_G = [ 0	0	0	0	0	m4(task)	0     0 0 0 0 0 0 0 0  ];
    motor = [ 0	0	1	0	0	0	1     0 0 0 0 0 0 0 0    ];
 
    % identify which trials have missing pmods,
    % eliminate the corresponding trial from onset too
    

    c01 = [ c01  cue_P];  c02 = [ c02  cue_V];  c03 = [ c03  cue_C];  c04 = [ c04  cue_G];
    c05 = [ c05  stim_P];  c06 = [ c06  stim_V];  c07 = [ c07  stim_C];  c08 = [ c08  stim_G];
    c09 = [ c09  stimXcue_P];  c10 = [ c10  stimXcue_V];  c11 = [ c11  stimXcue_C];  c12 = [ c12  stimXcue_G];
    c13 = [ c13  stimXactual_P];  c14 = [ c14  stimXactual_V];  c15 = [ c15  stimXactual_C];  c16 = [ c16  stimXactual_G];
    c17 = [ c17  motor];

    %csv_fname = '/Users/h/Documents/projects_local/social_influence_analysis/data/dartmouth/EV_bids/sub-0006/ses-01'
    social = struct2table(tdfread(csv_fname));

    motion_txt = fullfile(main_dir, 'data', 'dartmouth', 'EV', 'sub-0006',...
    'sub-0006_ses-01_task-social_acq-mb8_run-1_desc-confounds_timeseries.tsv');
    m = struct2table(tdfread(motion_txt));
    motion_txt =m(:, {'csf', 'white_matter', 'trans_x', 'trans_y', 'trans_z', 'rot_x', 'rot_y', 'rot_z'});
    mdouble = table2array(motion_txt);
    motion_fname = fullfile(main_dir, 'data', 'dartmouth', 'EV', 'sub-0006','sub-0006_ses-01_task-social_run-01_subset_confound.txt');
    dlmwrite(motion_fname,mdouble, 'delimiter','\t','precision',13);
%     save motion_fname motion_txt -ascii -double
    %-----------------------------------------------------------------------
    matlabbatch{1}.spm.stats.fmri_spec.dir = {fmri_dir};
    matlabbatch{1}.spm.stats.fmri_spec.timing.units = 'secs';
    matlabbatch{1}.spm.stats.fmri_spec.timing.RT = 0.46;
    matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t = numscans;
    matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t0 = 8;

    matlabbatch{1}.spm.stats.fmri_spec.fact = struct('name', {}, 'levels', {});
    matlabbatch{1}.spm.stats.fmri_spec.bases.hrf.derivs = [0 0];
    matlabbatch{1}.spm.stats.fmri_spec.volt = 1;
    matlabbatch{1}.spm.stats.fmri_spec.global = 'None';
    matlabbatch{1}.spm.stats.fmri_spec.mthresh = -Inf;
    matlabbatch{1}.spm.stats.fmri_spec.mask = {''}; %mask_fname
    matlabbatch{1}.spm.stats.fmri_spec.cvi = 'AR(1)';
    % RUN 01 _________________________________________________________________________
    scans = spm_select('Expand',scan_fname);
    matlabbatch{1}.spm.stats.fmri_spec.sess(run_ind).scans = cellstr(scans);
    matlabbatch{1}.spm.stats.fmri_spec.sess(run_ind).cond(1).name = 'CUE';
    matlabbatch{1}.spm.stats.fmri_spec.sess(run_ind).cond(1).onset = social.event01_cue_onset;
    matlabbatch{1}.spm.stats.fmri_spec.sess(run_ind).cond(1).duration = 1;
    matlabbatch{1}.spm.stats.fmri_spec.sess(run_ind).cond(1).tmod = 0;
    matlabbatch{1}.spm.stats.fmri_spec.sess(run_ind).cond(1).pmod.name = 'cue';
    matlabbatch{1}.spm.stats.fmri_spec.sess(run_ind).cond(1).pmod.param = social.cue_con;
    matlabbatch{1}.spm.stats.fmri_spec.sess(run_ind).cond(1).pmod.poly = 1;
    matlabbatch{1}.spm.stats.fmri_spec.sess(run_ind).cond(1).orth = 0;

    matlabbatch{1}.spm.stats.fmri_spec.sess(run_ind).cond(2).name = 'EXPECT_RATING';
    matlabbatch{1}.spm.stats.fmri_spec.sess(run_ind).cond(2).onset = social.event02_expect_displayonset(~ismissing(social.event02_expect_RT));
    matlabbatch{1}.spm.stats.fmri_spec.sess(run_ind).cond(2).duration = social.event02_expect_RT(~ismissing(social.event02_expect_RT));
    matlabbatch{1}.spm.stats.fmri_spec.sess(run_ind).cond(2).tmod = 0;
    matlabbatch{1}.spm.stats.fmri_spec.sess(run_ind).cond(2).pmod = struct('name', {}, 'param', {}, 'poly', {});
    matlabbatch{1}.spm.stats.fmri_spec.sess(run_ind).cond(2).orth = 0;

    matlabbatch{1}.spm.stats.fmri_spec.sess(run_ind).cond(3).name = 'STIM';
    matlabbatch{1}.spm.stats.fmri_spec.sess(run_ind).cond(3).onset = social.event03_stimulus_displayonset(~ismissing(social.event04_actual_angle));
    matlabbatch{1}.spm.stats.fmri_spec.sess(run_ind).cond(3).duration = 5;
    matlabbatch{1}.spm.stats.fmri_spec.sess(run_ind).cond(3).tmod = 0;
    matlabbatch{1}.spm.stats.fmri_spec.sess(run_ind).cond(3).pmod(1).name = 'cue';
    matlabbatch{1}.spm.stats.fmri_spec.sess(run_ind).cond(3).pmod(1).param = social.cue_con(~ismissing(social.event04_actual_angle));
    matlabbatch{1}.spm.stats.fmri_spec.sess(run_ind).cond(3).pmod(1).poly = 1;
    matlabbatch{1}.spm.stats.fmri_spec.sess(run_ind).cond(3).pmod(2).name = 'actual_rating';
    matlabbatch{1}.spm.stats.fmri_spec.sess(run_ind).cond(3).pmod(2).param = social.event04_actual_angle(~ismissing(social.event04_actual_angle));
    matlabbatch{1}.spm.stats.fmri_spec.sess(run_ind).cond(3).pmod(2).poly = 1;
    matlabbatch{1}.spm.stats.fmri_spec.sess(run_ind).cond(3).orth = 0;

    matlabbatch{1}.spm.stats.fmri_spec.sess(run_ind).cond(4).name = 'ACTUAL_RATING';
    matlabbatch{1}.spm.stats.fmri_spec.sess(run_ind).cond(4).onset = social.event04_actual_displayonset(~ismissing(social.event04_actual_RT));
    matlabbatch{1}.spm.stats.fmri_spec.sess(run_ind).cond(4).duration = social.event04_actual_RT(~ismissing(social.event04_actual_RT));
    matlabbatch{1}.spm.stats.fmri_spec.sess(run_ind).cond(4).tmod = 0;
    matlabbatch{1}.spm.stats.fmri_spec.sess(run_ind).cond(4).pmod = struct('name', {}, 'param', {}, 'poly', {});
    matlabbatch{1}.spm.stats.fmri_spec.sess(run_ind).cond(4).orth = 1;
    matlabbatch{1}.spm.stats.fmri_spec.sess(run_ind).multi = {''};
    matlabbatch{1}.spm.stats.fmri_spec.sess(run_ind).regress = struct('name', {}, 'val', {});
    matlabbatch{1}.spm.stats.fmri_spec.sess(run_ind).multi_reg = {motion_fname};
    matlabbatch{1}.spm.stats.fmri_spec.sess(run_ind).hpf = 128;


end



%% 2. estimation __________________________________________________________
% 
% SPM_fname= fullfile(fmri_dir, 'SPM.mat' );
% matlabbatch{2}.spm.stats.fmri_est.spmmat = cellstr(SPM_fname);
% matlabbatch{2}.spm.stats.fmri_est.write_residuals = 0;
% matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;

matlabbatch{2}.spm.stats.fmri_est.spmmat(1) = cfg_dep('fMRI model specification: SPM.mat File', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
matlabbatch{2}.spm.stats.fmri_est.write_residuals = 0;
matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;

% %% 3. contrast __________________________________________________________
%
matlabbatch{3}.spm.stats.con.spmmat(1) = cfg_dep('Model estimation: SPM.mat File', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
matlabbatch{3}.spm.stats.con.consess{1}.tcon = struct('name', 'cue_P>VC',  'weights', c01, 'sessrep' , 'none');
matlabbatch{3}.spm.stats.con.consess{2}.tcon = struct('name', 'cue_V>PC',  'weights', c02, 'sessrep' , 'none');
matlabbatch{3}.spm.stats.con.consess{3}.tcon = struct('name', 'cue_C>PV',  'weights', c03, 'sessrep' , 'none');
matlabbatch{3}.spm.stats.con.consess{4}.tcon = struct('name', 'cue_G',     'weights', c04, 'sessrep' , 'none');
matlabbatch{3}.spm.stats.con.consess{5}.tcon = struct('name', 'stim_P>VC', 'weights', c05, 'sessrep' , 'none');
matlabbatch{3}.spm.stats.con.consess{6}.tcon = struct('name', 'stim_V>PC', 'weights', c06, 'sessrep' , 'none');
matlabbatch{3}.spm.stats.con.consess{7}.tcon = struct('name', 'stim_C>PV', 'weights', c07, 'sessrep' , 'none');
matlabbatch{3}.spm.stats.con.consess{8}.tcon = struct('name', 'stim_G',    'weights', c08, 'sessrep' , 'none');
matlabbatch{3}.spm.stats.con.consess{9}.tcon = struct('name',  'stimXcue_P>VC',  'weights', c09, 'sessrep' , 'none');
matlabbatch{3}.spm.stats.con.consess{10}.tcon = struct('name', 'stimXcue_V>PC',  'weights', c10, 'sessrep' , 'none');
matlabbatch{3}.spm.stats.con.consess{11}.tcon = struct('name', 'stimXcue_C>PV',  'weights', c11, 'sessrep' , 'none');
matlabbatch{3}.spm.stats.con.consess{12}.tcon = struct('name', 'stimXcue_G',     'weights', c12, 'sessrep' , 'none');
matlabbatch{3}.spm.stats.con.consess{13}.tcon = struct('name', 'stimXactual_P>VC', 'weights', c13, 'sessrep' , 'none');
matlabbatch{3}.spm.stats.con.consess{14}.tcon = struct('name', 'stimXactual_V>PC', 'weights', c14, 'sessrep' , 'none');
matlabbatch{3}.spm.stats.con.consess{15}.tcon = struct('name', 'stimXactual_C>PV', 'weights', c15, 'sessrep' , 'none');
matlabbatch{3}.spm.stats.con.consess{16}.tcon = struct('name', 'stimXactual_G',    'weights', c16, 'sessrep' , 'none');
matlabbatch{3}.spm.stats.con.consess{17}.tcon = struct('name', 'motor', 'weights', c17, 'sessrep' , 'none');
matlabbatch{3}.spm.stats.con.delete = 0;

matlabbatch{4}.spm.stats.fmri_est.spmmat(1) = cfg_dep('Contrast Manager: SPM.mat File', substruct('.','val', '{}',{3}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
matlabbatch{4}.spm.stats.fmri_est.write_residuals = 0;
matlabbatch{4}.spm.stats.fmri_est.method.Classical = 1;

fileName = fullfile(fmri_dir, [strcat('sub-', sprintf('%02d', sub)) 'fourstep_designmatrix_jobestimation.mat']);
save( fileName  ,'matlabbatch');

%% 4. run __________________________________________________________
spm_jobman('run',matlabbatch);
clearvars matlabbatch
