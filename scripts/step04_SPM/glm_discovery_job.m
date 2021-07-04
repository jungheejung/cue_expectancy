function glm_discovery_job(input)
%-----------------------------------------------------------------------
% Job saved on 30-Jun-2021 19:26:24 by cfg_util (rev $Rev: 7345 $)
% spm SPM - SPM12 (7771)
% cfg_basicio BasicIO - Unknown
%-----------------------------------------------------------------------

%-----------------------------------------------------------------------
% PARAMETERS
%     - CUE
%     - CUE x cue
%     - EXPECT
%     - STIM
%     - STIM x cue
%     - STIM x actual
%     - ACTUAL
%% 1. load parameters _______________________________________________________
% [x] import csv files
% [x] list corresponding regressors.
% [x] run PVC order? or collected order? >> collected order. script will figure out corresponding contrast order
% [x] if run-keyword == pain, highlight -1
%sub_list = {2,3,4,5,6,7,8,9,10,11,13,14,15,16,17,18,19,20,21,23,24,25}
numscans = 56;
disacqs = 0;
disp(input);
disp(strcat('setting parameters...'));

% contrast mapper _______________________________________________________
keySet = {'pain','vicarious','cognitive'};
con1 = [2 -1 -1];   con2 = [-1 2 -1];  con3 = [-1 -1 2];  con4 = [1 1 1];
m1 = containers.Map(keySet,con1);
m2 = containers.Map(keySet,con2);
m3 = containers.Map(keySet,con3);
m4 = containers.Map(keySet,con4);
% 1-1. directories _______________________________________________________
fmriprep_dir = '/dartfs-hpc/rc/lab/C/CANlab/labdata/data/spacetop/derivatives/dartmouth/fmriprep/fmriprep/'; % sub / ses
main_dir = '/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop/social/';
motion_dir = fullfile(main_dir, 'data', 'dartmouth', 'd05_motion');
onset_dir = fullfile(main_dir, 'data', 'dartmouth', 'd04_EV_SPM');

%% 2. for loop "subject-wise" _______________________________________________________
sub_num = sscanf(char(input),'%d');
sub = strcat('sub-', sprintf('%04d', sub_num));
filelist = dir(fullfile(onset_dir, sub, '*/*_events.tsv'));
T = struct2table(filelist); % convert the struct array to a table
sortedT = sortrows(T, 'name'); % sort the table by 'DOB'
output_dir = fullfile(main_dir,'analysis', 'fmri', 'spm', 'model-01_CcEScaA',...
'1stLevel', sub);
if ~exist(output_dir, 'dir')
    mkdir(output_dir)
end

% contrasts (initialize per run)
c01 = []; c02 = []; c03 = []; c04 = [];c05 = []; c06 = []; c07 = []; c08 = [];
c09 = []; c10 = []; c11 = []; c12 = [];c13 = []; c14 = []; c15 = []; c16 = []; c17 = [];


matlabbatch = cell(1,2);
% matlabbatch{1}.spm.stats.fmri_spec.sess(run_ind) = cell(1,size(sortedT,1));
%% 3. for loop "run-wise" _______________________________________________________
for run_ind = 1:1% size(sortedT,1)
    disp(strcat('run', num2str(run_ind)));
    % [x] extract sub, ses, run info
    sub_num = sscanf(char(extractBetween(sortedT.name(run_ind), 'sub-', '_')),'%d'); sub = strcat('sub-', sprintf('%04d', sub_ind));
    ses_num = sscanf(char(extractBetween(sortedT.name(run_ind), 'ses-', '_')),'%d'); ses = strcat('ses-', sprintf('%02d', ses_num));
    run_num = sscanf(char(extractBetween(sortedT.name(run_ind), 'run-', '_')),'%d'); run = strcat('run-', sprintf('%01d', run_num));

    disp(strcat('gunzip and saving nifti...'));
    scan_fname = fullfile(fmriprep_dir, sub, ses, 'func',...
    strcat(sub, '_', ses, '_task-social_acq-mb8_', run, '_space-MNI152NLin2009cAsym_desc-preproc_bold.nii.gz'));
    nii_fname = fullfile(fmriprep_dir, sub, ses, 'func',...
    strcat(sub, '_', ses, '_task-social_acq-mb8_', run, '_space-MNI152NLin2009cAsym_desc-preproc_bold.nii'));
    if ~exist(nii_fname,'file'), gunzip(scan_fname)
    end

    disp(strcat('constructing contrasts...'));
    onset_fname   = fullfile(char(sortedT.folder(run_ind)), char(sortedT.name(run_ind)));
    social        = struct2table(tdfread(onset_fname));
    keyword       = extractBetween(sortedT.name(run_ind), 'run-0', '_events.tsv');
    task          = char(extractAfter(keyword, '-'));
    cue_P         = [ 0,m1(task),0,0,0,0,0,0,0,0,0,0,0,0,0 ];
    cue_V         = [ 0,m2(task),0,0,0,0,0,0,0,0,0,0,0,0,0  ];
    cue_C         = [ 0,m3(task),0,0,0,0,0,0,0,0,0,0,0,0,0  ];
    cue_G         = [ 0,m4(task),0,0,0,0,0,0,0,0,0,0,0,0,0  ];
    stim_P        = [ 0,0,0,m1(task),0,0,0,0,0,0,0,0,0,0,0  ];
    stim_V        = [ 0,0,0,m2(task),0,0,0,0,0,0,0,0,0,0,0  ];
    stim_C        = [ 0,0,0,m3(task),0,0,0,0,0,0,0,0,0,0,0  ];
    stim_G        = [ 0,0,0,m4(task),0,0,0,0,0,0,0,0,0,0,0  ];
    stimXcue_P    = [ 0,0,0,0,m1(task),0,0,0,0,0,0,0,0,0,0  ];
    stimXcue_V    = [ 0,0,0,0,m2(task),0,0,0,0,0,0,0,0,0,0  ];
    stimXcue_C    = [ 0,0,0,0,m3(task),0,0,0,0,0,0,0,0,0,0  ];
    stimXcue_G    = [ 0,0,0,0,m4(task),0,0,0,0,0,0,0,0,0,0  ];
    stimXactual_P = [ 0,0,0,0,0,m1(task),0,0,0,0,0,0,0,0,0  ];
    stimXactual_V = [ 0,0,0,0,0,m2(task),0,0,0,0,0,0,0,0,0  ];
    stimXactual_C = [ 0,0,0,0,0,m3(task),0,0,0,0,0,0,0,0,0  ];
    stimXactual_G = [ 0,0,0,0,0,m4(task),0,0,0,0,0,0,0,0,0  ];
    motor         = [ 0,0,1,0,0,0,1,0,0,0,0,0,0,0,0    ];

    % identify which trials have missing pmods,
    % eliminate the corresponding trial from onset too
    c01 = [ c01  cue_P];  c02 = [ c02  cue_V];  c03 = [ c03  cue_C];  c04 = [ c04  cue_G];
    c05 = [ c05  stim_P];  c06 = [ c06  stim_V];  c07 = [ c07  stim_C];  c08 = [ c08  stim_G];
    c09 = [ c09  stimXcue_P];  c10 = [ c10  stimXcue_V];  c11 = [ c11  stimXcue_C];  c12 = [ c12  stimXcue_G];
    c13 = [ c13  stimXactual_P];  c14 = [ c14  stimXactual_V];  c15 = [ c15  stimXactual_C];  c16 = [ c16  stimXactual_G];
    c17 = [ c17  motor];

    disp(strcat('creating motion covariate text file...'));
    %onset_fname = '/Users/h/Documents/projects_local/social_influence_analysis/data/dartmouth/EV_bids/sub-0006/ses-01'
    m_fmriprep   = fullfile(fmriprep_dir, sub, ses, 'func', ...
                   strcat(sub, '_', ses, '_task-social_acq-mb8_', run, '_desc-confounds_timeseries.tsv'));
    m            = struct2table(tdfread(m_fmriprep));
    m_subset     = m(:, {'csf', 'white_matter', 'trans_x', 'trans_y', 'trans_z', 'rot_x', 'rot_y', 'rot_z'});
    m_double     = table2array(m_subset);
    motion_fname = fullfile(motion_dir, sub, ses,...
                   strcat(sub, '_', ses, '_task-social_run-' , sprintf('%02d', run_num), '_confounds-subset.txt'));
    if ~exist(fullfile(motion_dir, sub, ses),'dir'), mkdir(fullfile(motion_dir, sub, ses))
    end
    dlmwrite(motion_fname, m_double, 'delimiter','\t','precision',13);


%     save motion_fname motion_txt -ascii -double
    disp(strcat('starting spmbatch...'));

    %-----------------------------------------------------------------------
    matlabbatch{1}.spm.stats.fmri_spec.dir = {output_dir};
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
    scans = spm_select('Expand',nii_fname);
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
% SPM_fname= fullfile(output_dir, 'SPM.mat' );
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

batch_fname = fullfile(output_dir, strcat(strcat(sub, '_batch.mat')));
save( batch_fname  ,'matlabbatch');

%% 4. run __________________________________________________________
spm_jobman('run',matlabbatch);
clearvars matlabbatch

end
