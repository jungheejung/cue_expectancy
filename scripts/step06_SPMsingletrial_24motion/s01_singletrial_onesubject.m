function s01_singletrial_onesubject(input)
    %-----------------------------------------------------------------------
    % Job saved on 30-Jun-2021 19:26:24 by cfg_util (rev $Rev: 7345 $)
    % spm SPM - SPM12 (7771)
    % cfg_basicio BasicIO - Unknown
    %-----------------------------------------------------------------------
    % Dec 13 2021. Heejung Jung
%% _________________________________________________________________________

disp('...STARTING JOBS');
addpath(genpath('/dartfs-hpc/rc/lab/C/CANlab/modules/spm12'));
addpath(genpath('/dartfs-hpc/rc/lab/C/CANlab/modules/CanlabCore/CanlabCore'));
rootgroup = settings; rootgroup.matlab.general.matfile.SaveFormat.PersonalValue = 'v7.3'
rootgroup.matlab.general.matfile.SaveFormat.TemporaryValue = 'v7.3';
%-----------------------------------------------------------------------
% PARAMETERS
%     - CUE
%     - STIM
%     - RATING (expect, actual combined) 
%     - ['csf', 'dummy', '24motion', 'intercept']

%% 1. load parameters _______________________________________________________
numscans = 56;
disacqs = 6;
smooth = 6;
disp(input);
disp(strcat('[ STEP 01 ] setting parameters...'));

% 1-1. directories _______________________________________________________
smooth_dir = '/dartfs-hpc/rc/lab/C/CANlab/labdata/data/spacetop/derivatives/smooth_6mm'
fmriprep_dir = '/dartfs-hpc/rc/lab/C/CANlab/labdata/data/spacetop/derivatives/fmriprep'; % sub / ses
main_dir = fileparts(fileparts(pwd)); % '/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop/social/';
% motion_dir = fullfile(main_dir, 'data', 'dartmouth', 'd05_motion');
motion_dir = fullfile(main_dir, 'data', 'd04_motion');
onset_dir = fullfile(main_dir, 'data','d03_onset' ,'onset03_SPMsingletrial_24dof');

%% 2. for loop "subject-wise" _______________________________________________________
sub = strcat('sub-', sprintf('%04d', input));
disp(strcat('[ STEP 02 ] PRINT VARIABLE'))
disp(strcat('sub:    ', sub));

% find nifti files _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 
niilist = dir(fullfile(smooth_dir, sub, '*','func',strcat('smooth_', num2str(smooth),'mm_*task-social*_bold.nii')));
nT = struct2table(niilist); % convert the struct array to a table
sortedT = sortrows(nT, 'name'); % sort the table by 'DOB'
disp(sortedT); % TODO: DELETE
sortedT.sub_num(:) = str2double(extractBetween(sortedT.name, 'sub-', '_'));
sortedT.ses_num(:) = str2double(extractBetween(sortedT.name, 'ses-', '_'));
sortedT.run_num(:) = str2double(extractBetween(sortedT.name, 'run-', '_'));

nii_col_names = sortedT.Properties.VariableNames;
nii_num_column = nii_col_names(endsWith(nii_col_names, '_num'));

% find onset files _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 
onsetlist = dir(fullfile(onset_dir, sub, strcat(sub, '*_covariate-circularrating.csv')));
onsetT = struct2table(onsetlist);
sortedonsetT = sortrows(onsetT, 'name');
disp(sortedT); % TODO: DELETE
sortedonsetT.sub_num(:) = str2double(extractBetween(sortedonsetT.name, 'sub-', '_'));
sortedonsetT.ses_num(:) = str2double(extractBetween(sortedonsetT.name, 'ses-', '_'));
sortedonsetT.run_num(:) = str2double(extractBetween(sortedonsetT.name, 'run-', '_'));

onset_col_names = sortedonsetT.Properties.VariableNames;
onset_num_column = onset_col_names(endsWith(onset_col_names, '_num'));

%intersection of nifti and onset files
A = intersect(sortedT(:,nii_num_column),sortedonsetT(:,onset_num_column));


%output_dir = fullfile(main_dir,'analysis', 'fmri', 'spm', 'multivariate','s02_isolatenifti', sub);
output_dir = fullfile(main_dir, 'analysis', 'fmri', 'spm', 'multivariate_24dofcsd', 's01_singletrial', sub);
if ~exist(output_dir, 'dir')
    mkdir(output_dir)
end
if isfile(fullfile(output_dir,'SPM.mat'))
   delete *.nii
   delete SPM.mat
end

matlabbatch = cell(1,2);
T = readtable(fullfile(onset_dir, sub, strcat(sub, '_singletrial_plateau.csv')));
%T = readtable('/Users/h/Dropbox/projects_dropbox/social_influence_analysis/data/dartmouth/d06_singletrial_SPM/sub-0010/sub-0010_singletrial.csv')
%% 3. for loop "run-wise" _______________________________________________________
for run_ind = 1: size(A,1)
    disp(strcat('______________________run', num2str(run_ind), '____________________________'));
    % [x] extract sub, ses, run info
    sub=[];ses=[];run = [];
    sub = strcat('sub-', sprintf('%04d', A.sub_num(run_ind)));
    ses = strcat('ses-', sprintf('%02d', A.ses_num(run_ind)));
    run = strcat('run-', sprintf('%02d', A.run_num(run_ind)));
    fmriprep_run = strcat('run-', sprintf('%01d', A.run_num(run_ind)));
    disp(strcat('[ STEP 03 ] gunzip and saving nifti...'));
    smooth_fname = fullfile(smooth_dir, sub, ses, 'func',...
                  strcat('smooth_',num2str(smooth),'mm_', sub, '_', ses, '_task-social_acq-mb8_', fmriprep_run, '_space-MNI152NLin2009cAsym_desc-preproc_bold.nii.gz'));
    smooth_nii = fullfile(smooth_dir, sub, ses, 'func',...
                   strcat('smooth_',num2str(smooth),'mm_', sub, '_', ses, '_task-social_acq-mb8_', fmriprep_run, '_space-MNI152NLin2009cAsym_desc-preproc_bold.nii'));
    if ~exist(smooth_nii,'file'), gunzip(smooth_fname)
    end

    %% rating ______________________________________________________
    rating_fname = fullfile(onset_dir, sub, strcat(sub, '_', ses, '_', run, '_covariate-circularrating.csv'));
    rating = readtable(rating_fname);

    %% regressor ______________________________________________________
    motion_fname = fullfile(motion_dir,  '24dof_csf_spike_dummy', sub, ses,...
                   strcat(sub, '_', ses, '_task-social_run-' , sprintf('%02d',A.run_num(run_ind)), '_confounds-subset.txt'));
    if ~isfile(motion_fname)
        if ~exist(fullfile(motion_dir,'24dof_csf_spike_dummy', sub, ses),'dir'), mkdir(fullfile(motion_dir, '24dof_csf_spike_dummy',sub, ses))
        end
        m_fmriprep   = fullfile(fmriprep_dir, sub, ses, 'func', ...
                   strcat(sub, '_', ses, '_task-social_acq-mb8_', run, '_desc-confounds_timeseries.tsv'));
        opts = detectImportOptions(m_fmriprep, 'FileType', 'text');
        opts = setvaropts(opts,'TreatAsMissing',{'n/a','NA'});
        %opts = detectImportOptions(m_fmriprep, 'FileType', 'text');
        m = readtable(m_fmriprep, opts);
                %    m = readtable(tdfread(m_fmriprep),'Format','auto')
                %    m            = struct2table(tdfread(m_fmriprep));
        m_subset     = m(:, {'csf', 'trans_x',	'trans_x_derivative1',	'trans_x_power2',	'trans_x_derivative1_power2',...
        	'trans_y',	'trans_y_derivative1',	'trans_y_derivative1_power2',	'trans_y_power2',...
            	'trans_z',	'trans_z_derivative1',	'trans_z_derivative1_power2',	'trans_z_power2',...
                	'rot_x',	'rot_x_derivative1',	'rot_x_derivative1_power2',	'rot_x_power2',...
                    	'rot_y',	'rot_y_derivative1',	'rot_y_derivative1_power2',	'rot_y_power2',...
                        	'rot_z',	'rot_z_derivative1',	'rot_z_derivative1_power2',	'rot_z_power2'});
        
        hasMatch = ~cellfun('isempty', regexp(m.Properties.VariableNames, 'motion_outlier', 'once')) ;
        motion_outlier = m(:, m.Properties.VariableNames(hasMatch));
        dummy = array2table(zeros(size(m,1),1), 'VariableNames',{'dummy'});
        dummy.dummy(1:6,:) = 1;
        m_cov = [m_subset,motion_outlier, dummy];
        m_clean = standardizeMissing(m_cov,'n/a');
	for i=1:25
		m_clean.(i)(isnan(m_clean.(i)))=nanmean(m_clean.(i))
	end   




% TODO START TOMORROW DEC 13
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
    matlabbatch{1}.spm.stats.fmri_spec.mthresh = -Inf; % % tor changed; Was 0.8. 0.8 performed implicit masking and made explicit  masking impossible (may be fixed?)
    matlabbatch{1}.spm.stats.fmri_spec.mask = {''};
    matlabbatch{1}.spm.stats.fmri_spec.cvi = 'None'; % tor changed. 'AR(1)', 'None', 'FAST'

    scans = spm_select('Expand',smooth_nii);
    matlabbatch{1}.spm.stats.fmri_spec.sess(run_ind).scans = cellstr(scans);

    subset = T(T.sub == A.sub_num(run_ind) & T.ses ==  A.ses_num(run_ind) & T.run ==  A.run_num(run_ind) & ismember(T.regressor, 'True'), :);
    total_trial= size(subset,1); % 24
    r = total_trial + 1;
    % CUE, STIM
    for c = 1:total_trial
        matlabbatch{1}.spm.stats.fmri_spec.sess(run_ind).cond(c).name = strcat(subset.ev{c},'-', num2str(subset.num(c), '%02.f'));
        matlabbatch{1}.spm.stats.fmri_spec.sess(run_ind).cond(c).onset = double(subset.onset(c));
        matlabbatch{1}.spm.stats.fmri_spec.sess(run_ind).cond(c).duration = double(subset.dur(c));
        matlabbatch{1}.spm.stats.fmri_spec.sess(run_ind).cond(c).tmod = 0;
        matlabbatch{1}.spm.stats.fmri_spec.sess(run_ind).cond(c).pmod = struct('name', {}, 'param', {}, 'poly', {});
        matlabbatch{1}.spm.stats.fmri_spec.sess(run_ind).cond(c).orth = 0;

    end
    % RATING TODO: 
    % - calculate number. each run, incremenmtally, 
    % plus CUE, STIM, Rating (1) + csf, wm, 6dof, 1 dummy, intercept
    matlabbatch{1}.spm.stats.fmri_spec.sess(run_ind).cond(r).name = 'rating';
    matlabbatch{1}.spm.stats.fmri_spec.sess(run_ind).cond(r).onset = double(rating.rating);
    matlabbatch{1}.spm.stats.fmri_spec.sess(run_ind).cond(r).duration = double(rating.rt);
    matlabbatch{1}.spm.stats.fmri_spec.sess(run_ind).cond(r).tmod = 0;
    matlabbatch{1}.spm.stats.fmri_spec.sess(run_ind).cond(r).pmod = struct('name', {}, 'param', {}, 'poly', {});
    matlabbatch{1}.spm.stats.fmri_spec.sess(run_ind).cond(r).orth = 0;

    matlabbatch{1}.spm.stats.fmri_spec.sess(run_ind).multi = {''};
    matlabbatch{1}.spm.stats.fmri_spec.sess(run_ind).regress = struct('name', {}, 'val', {});
    matlabbatch{1}.spm.stats.fmri_spec.sess(run_ind).multi_reg = cellstr(motion_fname);
    matlabbatch{1}.spm.stats.fmri_spec.sess(run_ind).hpf = 180; % tor changed; 128 can be too low; should choose yourself % 128; 128;
end


%% 2. estimation __________________________________________________________
batch_fname = fullfile(output_dir, strcat(strcat(sub, '_batch.mat')));
save( batch_fname,'matlabbatch')

disp(strcat('[ STEP 07 ] estimation '))
SPM_fname= fullfile(output_dir, 'SPM.mat' );
matlabbatch{2}.spm.stats.fmri_est.spmmat(1) = cfg_dep('fMRI model specification: SPM.mat File', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
matlabbatch{2}.spm.stats.fmri_est.write_residuals = 0;
matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;


batch_fname = fullfile(output_dir, strcat(strcat(sub, '_batch.mat')));
save( batch_fname,'matlabbatch') %, '-v7.3');

%% 3. run __________________________________________________________
spm('defaults', 'FMRI');
spm_jobman('run',matlabbatch);
clearvars matlabbatch

disp(strcat('FINISH - subject ', sub,  ' complete'))

end
