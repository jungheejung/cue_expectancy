function s01_singletrial_onesubject_flex(input, keyword)
    %-----------------------------------------------------------------------
    % Job saved on 30-Jun-2021 19:26:24 by cfg_util (rev $Rev: 7345 $)
    % spm SPM - SPM12 (7771)
    % cfg_basicio BasicIO - Unknown
    %-----------------------------------------------------------------------
    % Dec 13 2021. Heejung Jung
%% _________________________________________________________________________
disp('...STARTING JOBS');
rootgroup = settings; rootgroup.matlab.general.matfile.SaveFormat.PersonalValue = 'v7.3'
rootgroup.matlab.general.matfile.SaveFormat.TemporaryValue = 'v7.3';
%-----------------------------------------------------------------------
% PARAMETERS
%     - CUE
%     - STIM
%     - RATING (expect, actual combined) 
%     - ['csf', 'white_matter', 'trans_x', 'trans_y', 'trans_z', 'rot_x', 'rot_y', 'rot_z', 'dummy', 'intercept']

%% 1. load parameters _______________________________________________________
numscans = 56;
disacqs = 6;
smooth = 6;
disp(input);
disp(strcat('[ STEP 01 ] setting parameters...'));

% 1-1. directories _______________________________________________________
key_set = {'early', 'late', 'plateau', 'post'}
value_set = {'singletrial_SPM_01-pain-early', 'singletrial_SPM_02-pain-late',...
'singletrial_SPM_03-pain-post', 'singletrial_SPM_04-pain-plateau'}
M = containers.Map(keySet,valueSet);
fmriprep_dir = '/dartfs-hpc/rc/lab/C/CANlab/labdata/data/spacetop/derivatives/dartmouth/fmriprep/fmriprep/'; % sub / ses
main_dir = fileparts(fileparts(pwd)); % '/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop/social/';
motion_dir = fullfile(main_dir, 'data', 'dartmouth', 'd05_motion');
onset_dir = fullfile(main_dir, 'data', 'dartmouth', strcat('d06_', M(keyword)));

%% 2. for loop "subject-wise" _______________________________________________________
% sub_num = sscanf(char(input),'%d');
sub = strcat('sub-', sprintf('%04d', input));
disp(strcat('[ STEP 02 ] PRINT VARIABLE'))
%disp(strcat('sub_num:  ', sub_num));
disp(strcat('sub:    ', sub));

% find nifti files
niilist = dir(fullfile(fmriprep_dir, sub, '*','func',strcat('smooth_', num2str(smooth),'mm_*task-social*_bold.nii')));
nT = struct2table(niilist); % convert the struct array to a table
sortedT = sortrows(nT, 'name'); % sort the table by 'DOB'
disp(sortedT); % TODO: DELETE
sortedT.sub_num(:) = str2double(extractBetween(sortedT.name, 'sub-', '_'));
sortedT.ses_num(:) = str2double(extractBetween(sortedT.name, 'ses-', '_'));
sortedT.run_num(:) = str2double(extractBetween(sortedT.name, 'run-', '_'));

nii_col_names = sortedT.Properties.VariableNames;
nii_num_colomn = nii_col_names(endsWith(nii_col_names, '_num'));

% find onset files
onsetlist = dir(fullfile(onset_dir, sub, strcat(sub, '_*_rating_', keyword, '.csv')));
onsetT = struct2table(onsetlist);
sortedonsetT = sortrows(onsetT, 'name');
disp(sortedT); % TODO: DELETE
sortedonsetT.sub_num(:) = str2double(extractBetween(sortedonsetT.name, 'sub-', '_'));
sortedonsetT.ses_num(:) = str2double(extractBetween(sortedonsetT.name, 'ses-', '_'));
sortedonsetT.run_num(:) = str2double(extractBetween(sortedonsetT.name, 'run-', '_'));

onset_col_names = sortedonsetT.Properties.VariableNames;
onset_num_colomn = onset_col_names(endsWith(onset_col_names, '_num'));

%intersection of nifti and onset files
A = intersect(sortedT(:,nii_num_colomn),sortedonsetT(:,onset_num_colomn));

output_dir = fullfile(main_dir,'analysis', 'fmri', 'spm', 'multivariate','s01_singletrial', M(keyword),sub);
if ~exist(output_dir, 'dir')
    mkdir(output_dir)
end
if isfile(fullfile(output_dir,'SPM.mat'))
   delete *.nii
   delete SPM.mat
end

matlabbatch = cell(1,2);
T = readtable(fullfile(onset_dir, sub, strcat(sub, '_singletrial_',keyword, '.csv')));
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
    smooth_fname = fullfile(fmriprep_dir, sub, ses, 'func',...
                  strcat('smooth_',num2str(smooth),'mm_', sub, '_', ses, '_task-social_acq-mb8_', fmriprep_run, '_space-MNI152NLin2009cAsym_desc-preproc_bold.nii.gz'));
    smooth_nii = fullfile(fmriprep_dir, sub, ses, 'func',...
                   strcat('smooth_',num2str(smooth),'mm_', sub, '_', ses, '_task-social_acq-mb8_', fmriprep_run, '_space-MNI152NLin2009cAsym_desc-preproc_bold.nii'));
    if ~exist(smooth_nii,'file'), gunzip(smooth_fname)
    end

    %% rating ______________________________________________________
    rating_fname = fullfile(onset_dir, sub, strcat(sub, '_', ses, '_', run, '_rating_', keyword,'.csv'));
    rating = readtable(rating_fname);

    %% regressor ______________________________________________________
    % {'csf', 'white_matter', 'trans_x', 'trans_y', 'trans_z', 'rot_x', 'rot_y', 'rot_z', 'DISDAQS'}
    motion_fname = fullfile(onset_dir, sub, ...
                   strcat(sub, '_', ses, '_task-social_run-' , sprintf('%02d',A.run_num(run_ind)), '_confounds-subset.txt'));
    if ~isfile(motion_fname)
        if ~exist(fullfile(onset_dir, sub),'dir'), mkdir(fullfile(onset_dir, sub))
        end
        m_fmriprep   = fullfile(fmriprep_dir, sub, ses, 'func', ...
                   strcat(sub, '_', ses, '_task-social_acq-mb8_', fmriprep_run, '_desc-confounds_timeseries.tsv'));
        m            = struct2table(tdfread(m_fmriprep));
        m_subset     = m(:, {'csf', 'white_matter', 'trans_x', 'trans_y', 'trans_z', 'rot_x', 'rot_y', 'rot_z'});
        m_double     = table2array(m_subset);i
        dummy = zeros(size(m_double,1),1);    dummy(1:disacqs,1) = 1
        m_double(:,size(m_double,2)+1) = dummy

        dlmwrite(motion_fname, m_double, 'delimiter','\t','precision',13);
        %R = dlmread(motion_fname);

        %dummy = zeros(size(R,1),1);    dummy(1:disacqs,1) = 1
        %R(:,size(R,2)+1) = dummy

        %save_m_fname = fullfile(onset_dir, sub, ...
    %        strcat(sub, '_', ses, '_task-social_run-' , sprintf('%02d',A.run_num(run_ind)), '_confounds-subset.txt'));
        %save(save_m_fname, 'R');
    else
        disp('motion subset file exists');
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
        matlabbatch{1}.spm.stats.fmri_spec.sess(run_ind).cond(c).onset = double(subset.onset{c});
        matlabbatch{1}.spm.stats.fmri_spec.sess(run_ind).cond(c).duration = double(subset.dur{c});
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
