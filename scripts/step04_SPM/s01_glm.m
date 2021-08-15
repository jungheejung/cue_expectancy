function s01_glm(input)
%-----------------------------------------------------------------------
% Job saved on 30-Jun-2021 19:26:24 by cfg_util (rev $Rev: 7345 $)
% spm SPM - SPM12 (7771)
% cfg_basicio BasicIO - Unknown
%-----------------------------------------------------------------------
disp('...STARTING JOBS');

rootgroup = settings; rootgroup.matlab.general.matfile.SaveFormat.PersonalValue = 'v7.3'
rootgroup.matlab.general.matfile.SaveFormat.TemporaryValue = 'v7.3';
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
%sub_list = {2,3,4,5,6,7,8,9,10,11,13,14,15,16,17,18,19,20,21,23,24,25}
numscans = 56;
disacqs = 0;
disp(input);
disp(strcat('[ STEP 01 ] setting parameters...'));

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
disp(strcat('[ STEP 02 ] PRINT VARIABLE'))
disp(strcat('sub_num:  ', sub_num));
disp(strcat('sub:    ', sub));


% filelist = dir(fullfile(onset_dir, sub, '*/*_events.tsv'));
%filelist = dir(fullfile(fmriprep_dir, sub, '*/func/smooth_5mm_*task-social*_bold.nii'));
%T = struct2table(filelist); % convert the struct array to a table
%sortedT = sortrows(T, 'name'); % sort the table by 'DOB'

% find nifti files
niilist = dir(fullfile(fmriprep_dir, sub, '*/func/smooth_5mm_*task-social*_bold.nii'));
nT = struct2table(niilist); % convert the struct array to a table
sortedT = sortrows(nT, 'name'); % sort the table by 'DOB'

sortedT.sub_num(:) = str2double(extractBetween(sortedT.name, 'sub-', '_'));
sortedT.ses_num(:) = str2double(extractBetween(sortedT.name, 'ses-', '_'));
sortedT.run_num(:) = str2double(extractBetween(sortedT.name, 'run-', '_'));

nii_col_names = sortedT.Properties.VariableNames;
nii_num_colomn = nii_col_names(endsWith(nii_col_names, '_num'));

% find onset files
onsetlist = dir(fullfile(onset_dir, sub, '*', strcat(sub, '_*_task-social_*_events.tsv')));
onsetT = struct2table(onsetlist);
sortedonsetT = sortrows(onsetT, 'name');

sortedonsetT.sub_num(:) = str2double(extractBetween(sortedonsetT.name, 'sub-', '_'));
sortedonsetT.ses_num(:) = str2double(extractBetween(sortedonsetT.name, 'ses-', '_'));
sortedonsetT.run_num(:) = str2double(extractBetween(sortedonsetT.name, 'run-', '-'));

onset_col_names = sortedonsetT.Properties.VariableNames;
onset_num_colomn = onset_col_names(endsWith(onset_col_names, '_num'));

%intersection of nifti and onset files
A = intersect(sortedT(:,nii_num_colomn),sortedonsetT(:,onset_num_colomn));

output_dir = fullfile(main_dir,'analysis', 'fmri', 'spm', 'model-01_CcEScaA',...
'1stLevel',sub);
if ~exist(output_dir, 'dir')
    mkdir(output_dir)
end
if isfile(fullfile(output_dir,'SPM.mat'))
   delete *.nii
   delete SPM.mat
end

% contrasts (initialize per run)
c01 = []; c02 = []; c03 = []; c04 = [];c05 = []; c06 = []; c07 = []; c08 = [];
c09 = []; c10 = []; c11 = []; c12 = [];c13 = []; c14 = []; c15 = []; c16 = []; c17 = [];


matlabbatch = cell(1,2);
% matlabbatch{1}.spm.stats.fmri_spec.sess(run_ind) = cell(1,size(sortedT,1));
%% 3. for loop "run-wise" _______________________________________________________
for run_ind = 1: size(A,1)
    disp(strcat('______________________run', num2str(run_ind), '____________________________'));
    % [x] extract sub, ses, run info
    % sub_num = sscanf(char(extractBetween(sortedT.name(run_ind), 'sub-', '_')),'%d'); sub = strcat('sub-', sprintf('%04d', sub_num));
    % ses_num = sscanf(char(extractBetween(sortedT.name(run_ind), 'ses-', '_')),'%d'); ses = strcat('ses-', sprintf('%02d', ses_num));
    % run_num = sscanf(char(extractBetween(sortedT.name(run_ind), 'run-', '_')),'%d'); run = strcat('run-', sprintf('%01d', run_num));
    sub=[];ses=[];run = [];
    sub = strcat('sub-', sprintf('%04d', A.sub_num(run_ind)));
    ses = strcat('ses-', sprintf('%02d', A.ses_num(run_ind)));
    run = strcat('run-', sprintf('%01d', A.run_num(run_ind)));

    disp(strcat('[ STEP 03 ] gunzip and saving nifti...'));
    % smooth_5mm_sub-0006_ses-01_task-social_acq-mb8_run-1_space-MNI152NLin2009cAsym_desc-preproc_bold.nii
    % smooth_5mm_sub-0003_ses-01_task-social_acq-mb8_run-1_space-MNI152NLin2009cAsym_desc-preproc_bold_masked.nii.gz
    smooth_fname = fullfile(fmriprep_dir, sub, ses, 'func',...
                   strcat('smooth_5mm_', sub, '_', ses, '_task-social_acq-mb8_', run, '_space-MNI152NLin2009cAsym_desc-preproc_bold.nii.gz'));
    smooth_nii = fullfile(fmriprep_dir, sub, ses, 'func',...
                   strcat('smooth_5mm_', sub, '_', ses, '_task-social_acq-mb8_', run, '_space-MNI152NLin2009cAsym_desc-preproc_bold.nii'));
    if ~exist(smooth_nii,'file'), gunzip(smooth_fname)
    end
    % scan_fname = fullfile(fmriprep_dir, sub, ses, 'func',...
    %strcat(sub, '_', ses, '_task-social_acq-mb8_', run, '_space-MNI152NLin2009cAsym_desc-preproc_bold.nii.gz'));
    %nii_fname = fullfile(fmriprep_dir, sub, ses, 'func',...
    %strcat(sub, '_', ses, '_task-social_acq-mb8_', run, '_space-MNI152NLin2009cAsym_desc-preproc_bold.nii'));
    %disp(strcat('nifti files: ', nii_fname));
    %if ~exist(nii_fname,'file'), gunzip(scan_fname)
    %end

    disp(strcat('[ STEP 04 ]constructing contrasts...'));
    %onset_fname   = fullfile(onset_dir, sub, ses, strcat(sub, '_', ses, '_task-social_', run, '-', task, '_events.tsv'));
    %onset_fname   = fullfile(char(sortedT.folder(run_ind)), char(sortedT.name(run_ind)));
    onset_glob    = dir(fullfile(onset_dir, sub, ses, strcat(sub, '_', ses, '_task-social_',strcat('run-', sprintf('%02d', A.run_num(run_ind))), '-*_events.tsv')));
    onset_fname   = fullfile(char(onset_glob.folder), char(onset_glob.name));
    if isempty(onset_glob)
      disp('ABORT')
      break
    end
    disp(strcat('onset folder: ', onset_glob.folder));
    disp(strcat('onset file:   ', onset_glob.name));
    social        = struct2table(tdfread(onset_fname));
    keyword       = extractBetween(onset_glob.name, 'run-0', '_events.tsv');
    task          = char(extractAfter(keyword, '-'));

    % cue_P         = [ 0,m1(task),0,0,0,0,0,0,0,0,0,0,0,0,0 ];
    % cue_V         = [ 0,m2(task),0,0,0,0,0,0,0,0,0,0,0,0,0  ];
    % cue_C         = [ 0,m3(task),0,0,0,0,0,0,0,0,0,0,0,0,0  ];
    % cue_G         = [ 0,m4(task),0,0,0,0,0,0,0,0,0,0,0,0,0  ];
    % stim_P        = [ 0,0,0,m1(task),0,0,0,0,0,0,0,0,0,0,0  ];
    % stim_V        = [ 0,0,0,m2(task),0,0,0,0,0,0,0,0,0,0,0  ];
    % stim_C        = [ 0,0,0,m3(task),0,0,0,0,0,0,0,0,0,0,0  ];
    % stim_G        = [ 0,0,0,m4(task),0,0,0,0,0,0,0,0,0,0,0  ];
    % stimXcue_P    = [ 0,0,0,0,m1(task),0,0,0,0,0,0,0,0,0,0  ];
    % stimXcue_V    = [ 0,0,0,0,m2(task),0,0,0,0,0,0,0,0,0,0  ];
    % stimXcue_C    = [ 0,0,0,0,m3(task),0,0,0,0,0,0,0,0,0,0  ];
    % stimXcue_G    = [ 0,0,0,0,m4(task),0,0,0,0,0,0,0,0,0,0  ];
    % stimXactual_P = [ 0,0,0,0,0,m1(task),0,0,0,0,0,0,0,0,0  ];
    % stimXactual_V = [ 0,0,0,0,0,m2(task),0,0,0,0,0,0,0,0,0  ];
    % stimXactual_C = [ 0,0,0,0,0,m3(task),0,0,0,0,0,0,0,0,0  ];
    % stimXactual_G = [ 0,0,0,0,0,m4(task),0,0,0,0,0,0,0,0,0  ];
    % motor         = [ 0,0,1,0,0,0,1,0,0,0,0,0,0,0,0    ];
    disp(strcat('task: ', task));
    % identify which trials have missing pmods,
    % eliminate the corresponding trial from onset too
    % c01 = [ c01  cue_P];  c02 = [ c02  cue_V];  c03 = [ c03  cue_C];  c04 = [ c04  cue_G];
    % c05 = [ c05  stim_P];  c06 = [ c06  stim_V];  c07 = [ c07  stim_C];  c08 = [ c08  stim_G];
    % c09 = [ c09  stimXcue_P];  c10 = [ c10  stimXcue_V];  c11 = [ c11  stimXcue_C];  c12 = [ c12  stimXcue_G];
    % c13 = [ c13  stimXactual_P];  c14 = [ c14  stimXactual_V];  c15 = [ c15  stimXactual_C];  c16 = [ c16  stimXactual_G];
    % c17 = [ c17  motor];

    disp(strcat('[ STEP 05 ]creating motion covariate text file...'));
    %onset_fname = '/Users/h/Documents/projects_local/social_influence_analysis/data/dartmouth/EV_bids/sub-0006/ses-01'
    %m_fmriprep   = fullfile(fmriprep_dir, sub, ses, 'func', ...
    %               strcat(sub, '_', ses, '_task-social_acq-mb8_', run, '_desc-confounds_timeseries.tsv'));
    %m            = struct2table(tdfread(m_fmriprep));
    %m_subset     = m(:, {'csf', 'white_matter', 'trans_x', 'trans_y', 'trans_z', 'rot_x', 'rot_y', 'rot_z'});
    %m_double     = table2array(m_subset);

    mask_fname = fullfile(fmriprep_dir, sub, 'ses-01', 'anat',...
    strcat(sub, '_ses-01_acq-MPRAGEXp3X08mm_desc-brain_mask.nii.gz'));
    mask_nii = fullfile(fmriprep_dir, sub, 'ses-01', 'anat',...
    strcat(sub, '_ses-01_acq-MPRAGEXp3X08mm_desc-brain_mask.nii'));
    if ~exist(mask_nii,'file'), gunzip(mask_fname)
    end

%% regressor ______________________________________________________
    motion_fname = fullfile(motion_dir, sub, ses,...
                   strcat(sub, '_', ses, '_task-social_run-' , sprintf('%02d',A.run_num(run_ind)), '_confounds-subset.txt'));
    if ~isfile(motion_fname)
        if ~exist(fullfile(motion_dir, sub, ses),'dir'), mkdir(fullfile(motion_dir, sub, ses))
        end
        m_fmriprep   = fullfile(fmriprep_dir, sub, ses, 'func', ...
                   strcat(sub, '_', ses, '_task-social_acq-mb8_', run, '_desc-confounds_timeseries.tsv'));
        m            = struct2table(tdfread(m_fmriprep));
        m_subset     = m(:, {'csf', 'white_matter', 'trans_x', 'trans_y', 'trans_z', 'rot_x', 'rot_y', 'rot_z'});
        m_double     = table2array(m_subset);
        dlmwrite(motion_fname, m_double, 'delimiter','\t','precision',13);
        R = dlmread(motion_fname);
        save_m_fname = fullfile(motion_dir, sub, ses,...
            strcat(sub, '_', ses, '_task-social_run-' , sprintf('%02d',A.run_num(run_ind)), '_confounds-subset.mat'));
        save(save_m_fname, 'R');
    else
        disp('motion subset file exists');
    end


    disp(strcat('[ STEP 06 ]starting spmbatch...'));

    %-----------------------------------------------------------------------
    matlabbatch{1}.spm.stats.fmri_spec.dir = cellstr(output_dir);
    matlabbatch{1}.spm.stats.fmri_spec.timing.units = 'secs';
    matlabbatch{1}.spm.stats.fmri_spec.timing.RT = 0.46;
    matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t = 16;
    matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t0 = 8;

    matlabbatch{1}.spm.stats.fmri_spec.fact = struct('name', {}, 'levels', {});
    matlabbatch{1}.spm.stats.fmri_spec.bases.hrf.derivs = [0 0];
    matlabbatch{1}.spm.stats.fmri_spec.volt = 1;
    matlabbatch{1}.spm.stats.fmri_spec.global = 'None';
    matlabbatch{1}.spm.stats.fmri_spec.mthresh = -Inf;
    matlabbatch{1}.spm.stats.fmri_spec.mask = {''};
    matlabbatch{1}.spm.stats.fmri_spec.cvi = 'AR(1)';

    % RUN 01 _________________________________________________________________________
    scans = spm_select('Expand',smooth_nii);
    matlabbatch{1}.spm.stats.fmri_spec.sess(run_ind).scans = cellstr(scans);
    matlabbatch{1}.spm.stats.fmri_spec.sess(run_ind).cond(1).name = 'CUE';
    matlabbatch{1}.spm.stats.fmri_spec.sess(run_ind).cond(1).onset = double(social.event01_cue_onset);
    matlabbatch{1}.spm.stats.fmri_spec.sess(run_ind).cond(1).duration = double(repelem(1,12)');;
    matlabbatch{1}.spm.stats.fmri_spec.sess(run_ind).cond(1).tmod = 0;
    matlabbatch{1}.spm.stats.fmri_spec.sess(run_ind).cond(1).pmod.name = 'cue';
    matlabbatch{1}.spm.stats.fmri_spec.sess(run_ind).cond(1).pmod.param = double(social.cue_con);
    matlabbatch{1}.spm.stats.fmri_spec.sess(run_ind).cond(1).pmod.poly = 1;
    matlabbatch{1}.spm.stats.fmri_spec.sess(run_ind).cond(1).orth = 0;

    matlabbatch{1}.spm.stats.fmri_spec.sess(run_ind).cond(2).name = 'EXPECT_RATING';
    matlabbatch{1}.spm.stats.fmri_spec.sess(run_ind).cond(2).onset = double(social.event02_expect_displayonset);
    matlabbatch{1}.spm.stats.fmri_spec.sess(run_ind).cond(2).duration = double(social.event02_expect_RT);
    matlabbatch{1}.spm.stats.fmri_spec.sess(run_ind).cond(2).tmod = 0;
    matlabbatch{1}.spm.stats.fmri_spec.sess(run_ind).cond(2).pmod = struct('name', {}, 'param', {}, 'poly', {});
    matlabbatch{1}.spm.stats.fmri_spec.sess(run_ind).cond(2).orth = 0;

    matlabbatch{1}.spm.stats.fmri_spec.sess(run_ind).cond(3).name = 'STIM';
    matlabbatch{1}.spm.stats.fmri_spec.sess(run_ind).cond(3).onset = double(social.event03_stimulus_displayonset) + 2 ;
    matlabbatch{1}.spm.stats.fmri_spec.sess(run_ind).cond(3).duration = double(repelem(5,12)');
    matlabbatch{1}.spm.stats.fmri_spec.sess(run_ind).cond(3).tmod = 0;
    matlabbatch{1}.spm.stats.fmri_spec.sess(run_ind).cond(3).pmod(1).name = 'cue';
    matlabbatch{1}.spm.stats.fmri_spec.sess(run_ind).cond(3).pmod(1).param = double(social.cue_con);
    matlabbatch{1}.spm.stats.fmri_spec.sess(run_ind).cond(3).pmod(1).poly = 1;
    matlabbatch{1}.spm.stats.fmri_spec.sess(run_ind).cond(3).pmod(2).name = 'actual_rating';
    matlabbatch{1}.spm.stats.fmri_spec.sess(run_ind).cond(3).pmod(2).param = double(social.event04_actual_angle);
    matlabbatch{1}.spm.stats.fmri_spec.sess(run_ind).cond(3).pmod(2).poly = 1;
    matlabbatch{1}.spm.stats.fmri_spec.sess(run_ind).cond(3).orth = 0;

    matlabbatch{1}.spm.stats.fmri_spec.sess(run_ind).cond(4).name = 'ACTUAL_RATING';
    matlabbatch{1}.spm.stats.fmri_spec.sess(run_ind).cond(4).onset = double(social.event04_actual_displayonset);
    matlabbatch{1}.spm.stats.fmri_spec.sess(run_ind).cond(4).duration = double(social.event04_actual_RT);
    matlabbatch{1}.spm.stats.fmri_spec.sess(run_ind).cond(4).tmod = 0;
    matlabbatch{1}.spm.stats.fmri_spec.sess(run_ind).cond(4).pmod = struct('name', {}, 'param', {}, 'poly', {});
    matlabbatch{1}.spm.stats.fmri_spec.sess(run_ind).cond(4).orth = 0;
    matlabbatch{1}.spm.stats.fmri_spec.sess(run_ind).multi = {''};
    matlabbatch{1}.spm.stats.fmri_spec.sess(run_ind).regress = struct('name', {}, 'val', {});
    matlabbatch{1}.spm.stats.fmri_spec.sess(run_ind).multi_reg = cellstr(motion_fname);
    matlabbatch{1}.spm.stats.fmri_spec.sess(run_ind).hpf = 128;
end


%% 2. estimation __________________________________________________________
%
disp(strcat('[ STEP 07 ] estimation '))
SPM_fname= fullfile(output_dir, 'SPM.mat' );
matlabbatch{2}.spm.stats.fmri_est.spmmat(1) = cfg_dep('fMRI model specification: SPM.mat File', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
% matlabbatch{2}.spm.stats.fmri_est.spmmat = cellstr(SPM_fname);
matlabbatch{2}.spm.stats.fmri_est.write_residuals = 0;
matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;

% %% 3. contrast __________________________________________________________
%
%disp(strcat('[ STEP 08 ] first level contrast'))
%matlabbatch{3}.spm.stats.con.spmmat(1) = cfg_dep('Model estimation: SPM.mat File', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
%matlabbatch{3}.spm.stats.con.spmmat = cellstr(SPM_fname);
%matlabbatch{3}.spm.stats.con.consess{1}.tcon = struct('name', 'cue_P>VC',  'weights', c01, 'sessrep' , 'none');
%matlabbatch{3}.spm.stats.con.consess{2}.tcon = struct('name', 'cue_V>PC',  'weights', c02, 'sessrep' , 'none');
%matlabbatch{3}.spm.stats.con.consess{3}.tcon = struct('name', 'cue_C>PV',  'weights', c03, 'sessrep' , 'none');
%matlabbatch{3}.spm.stats.con.consess{4}.tcon = struct('name', 'cue_G',     'weights', c04, 'sessrep' , 'none');
%matlabbatch{3}.spm.stats.con.consess{5}.tcon = struct('name', 'stim_P>VC', 'weights', c05, 'sessrep' , 'none');
%matlabbatch{3}.spm.stats.con.consess{6}.tcon = struct('name', 'stim_V>PC', 'weights', c06, 'sessrep' , 'none');
%matlabbatch{3}.spm.stats.con.consess{7}.tcon = struct('name', 'stim_C>PV', 'weights', c07, 'sessrep' , 'none');
%matlabbatch{3}.spm.stats.con.consess{8}.tcon = struct('name', 'stim_G',    'weights', c08, 'sessrep' , 'none');
%matlabbatch{3}.spm.stats.con.consess{9}.tcon = struct('name',  'stimXcue_P>VC',  'weights', c09, 'sessrep' , 'none');
%matlabbatch{3}.spm.stats.con.consess{10}.tcon = struct('name', 'stimXcue_V>PC',  'weights', c10, 'sessrep' , 'none');
%matlabbatch{3}.spm.stats.con.consess{11}.tcon = struct('name', 'stimXcue_C>PV',  'weights', c11, 'sessrep' , 'none');
%matlabbatch{3}.spm.stats.con.consess{12}.tcon = struct('name', 'stimXcue_G',     'weights', c12, 'sessrep' , 'none');
%matlabbatch{3}.spm.stats.con.consess{13}.tcon = struct('name', 'stimXactual_P>VC', 'weights', c13, 'sessrep' , 'none');
%matlabbatch{3}.spm.stats.con.consess{14}.tcon = struct('name', 'stimXactual_V>PC', 'weights', c14, 'sessrep' , 'none');
%matlabbatch{3}.spm.stats.con.consess{15}.tcon = struct('name', 'stimXactual_C>PV', 'weights', c15, 'sessrep' , 'none');
%matlabbatch{3}.spm.stats.con.consess{16}.tcon = struct('name', 'stimXactual_G',    'weights', c16, 'sessrep' , 'none');
%matlabbatch{3}.spm.stats.con.consess{17}.tcon = struct('name', 'motor', 'weights', c17, 'sessrep' , 'none');
%matlabbatch{3}.spm.stats.con.delete = 1;

%disp(strcat('[ STEP 09 ] contrast estimation'))
% matlabbatch{4}.spm.stats.fmri_est.spmmat(1) = cfg_dep('Contrast Manager: SPM.mat File', substruct('.','val', '{}',{3}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
%matlabbatch{4}.spm.stats.fmri_est.spmmat = cellstr(SPM_fname);
%matlabbatch{4}.spm.stats.fmri_est.write_residuals = 0;
%matlabbatch{4}.spm.stats.fmri_est.method.Classical = 1;

batch_fname = fullfile(output_dir, strcat(strcat(sub, '_batch.mat')));
save( batch_fname,'matlabbatch') %, '-v7.3');



%% 4. run __________________________________________________________
spm('defaults', 'FMRI');
spm_jobman('run',matlabbatch);
clearvars matlabbatch

disp(strcat('FINISH - subject ', sub,  ' complete'))

end
