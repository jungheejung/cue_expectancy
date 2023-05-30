function s01_glm(sub, input_dir, main_dir, fmriprep_dir)
    %-----------------------------------------------------------------------
    % spm SPM - SPM12 (7771)
    % cfg_basicio BasicIO - Unknown
    %-----------------------------------------------------------------------
    disp('...STARTING JOBS');

    rootgroup = settings; rootgroup.matlab.general.matfile.SaveFormat.PersonalValue = 'v7.3'
    rootgroup.matlab.general.matfile.SaveFormat.TemporaryValue = 'v7.3';
    %-----------------------------------------------------------------------
    % PARAMETERS
    %     - CUE: onset01_cue
    %     - EXPECT RATING: onset02_ratingexpect, pmod_expectRT
    %     - STIM: (onset03_stim)
    %     -     x pmod: physio
    %     - OUTCOME RATING: onset04_ratingoutcome, pmod_outcomeRT

    %% 1. load parameters _______________________________________________________
    disacqs = 0;
    disp(sub);
    disp(strcat('[ STEP 01 ] setting parameters...'));
    disp(strcat('____________________________', sub, '____________________________'))

    % contrast mapper _______________________________________________________
    keySet = {'pain', 'vicarious', 'cognitive'};
    con1 = [2 -1 -1]; con2 = [-1 2 -1]; con3 = [-1 -1 2]; con4 = [1 1 1];
    m1 = containers.Map(keySet, con1);
    m2 = containers.Map(keySet, con2);
    m3 = containers.Map(keySet, con3);
    m4 = containers.Map(keySet, con4);
    % 1-1. directories _______________________________________________________
    motion_dir = fullfile(main_dir, 'data', 'fmri', 'fmri02_motion');
    onset_dir = fullfile(main_dir, 'data', 'fmri', 'fmri01_onset', 'onset02_SPM');
    disp(strcat('input_dir: ', input_dir));
    disp(strcat('motion_dir: ', motion_dir));
    disp(strcat('onset_dir: ', onset_dir));
    disp(strcat('main_dir: ', main_dir));
    %% 2. for loop "subject-wise" _______________________________________________________
    disp(strcat('[ STEP 02 ] PRINT VARIABLE'))
    disp(strcat('sub:    ', sub));

    % find nifti files
    niilist = dir(fullfile(input_dir, sub, '*/smooth-6mm_*task-cue*_bold.nii'));
    nT = struct2table(niilist); % convert the struct array to a table
    sortedT = sortrows(nT, 'name'); % sort the table by 'DOB'

    sortedT.sub_num(:) = str2double(extractBetween(sortedT.name, 'sub-', '_'));
    sortedT.ses_num(:) = str2double(extractBetween(sortedT.name, 'ses-', '_'));
    sortedT.run_num(:) = str2double(extractBetween(sortedT.name, 'run-', '_'));

    nii_col_names = sortedT.Properties.VariableNames;
    nii_num_colomn = nii_col_names(endsWith(nii_col_names, '_num'));

    % find onset files
    onsetlist = dir(fullfile(onset_dir, sub, '*', strcat(sub, '_*_task-cue_*_events.tsv')));
    onsetT = struct2table(onsetlist);
    sortedonsetT = sortrows(onsetT, 'name');

    sortedonsetT.sub_num(:) = str2double(extractBetween(sortedonsetT.name, 'sub-', '_'));
    sortedonsetT.ses_num(:) = str2double(extractBetween(sortedonsetT.name, 'ses-', '_'));
    sortedonsetT.run_num(:) = str2double(extractBetween(sortedonsetT.name, 'run-', '_'));

    onset_col_names = sortedonsetT.Properties.VariableNames;
    onset_num_colomn = onset_col_names(endsWith(onset_col_names, '_num'));
    disp(nii_num_colomn)
    %intersection of nifti and onset files
    A = intersect(sortedT(:, nii_num_colomn), sortedonsetT(:, onset_num_colomn));

    output_dir = fullfile(main_dir, 'analysis', 'fmri', 'spm', 'univariate', 'model02_CESphysioO', ...
        '1stLevel', sub);

    if ~exist(output_dir, 'dir')
        mkdir(output_dir)
    end

    if isfile(fullfile(output_dir, 'SPM.mat'))
        delete(fullfile(output_dir,'*.nii'));
        delete(fullfile(output_dir,'SPM.mat'));
    end

    % contrasts (initialize per run)
    c01 = []; c02 = []; c03 = []; c04 = []; c05 = []; c06 = []; c07 = []; c08 = [];
    c09 = []; c10 = []; c11 = []; c12 = []; c13 = []; c14 = []; c15 = []; c16 = []; c17 = [];

    matlabbatch = cell(1, 2);
    
    %% 3. for loop "run-wise" _______________________________________________________
    for run_ind = 1:size(A, 1)
        disp(strcat('______________________run', num2str(run_ind), '____________________________'));
        sub = []; ses = []; run = [];
        sub = strcat('sub-', sprintf('%04d', A.sub_num(run_ind)));
        ses = strcat('ses-', sprintf('%02d', A.ses_num(run_ind)));
        run = strcat('run-', sprintf('%01d', A.run_num(run_ind)));

        disp(strcat('[ STEP 03 ] gunzip and saving nifti...'));
        %smooth_fname = fullfile(input_dir, sub, ses,  ...
        %    strcat('smooth-6mm_', sub, '_', ses, '_task-cue_acq-mb8_', run, '_space-MNI152NLin2009cAsym_desc-preproc_bold.nii.gz'));
        smooth_nii = fullfile(input_dir, sub, ses, ...
            strcat('smooth-6mm_', sub, '_', ses, '_task-cue_acq-mb8_', run, '_space-MNI152NLin2009cAsym_desc-preproc_bold.nii'));

        if ~exist(smooth_nii, 'file')
            disp(strcat('ABORT [!] ', smooth_nii, 'does not exist'))
            break 
        end

        disp(strcat('[ STEP 04 ]constructing contrasts...'));
        onset_glob = dir(fullfile(onset_dir, sub, ses, strcat(sub, '_', ses, '_task-cue_', strcat('run-', sprintf('%02d', A.run_num(run_ind))), '*_events.tsv')));
        onset_fname = fullfile(char(onset_glob.folder), char(onset_glob.name));

        if isempty(onset_glob)
            disp('ABORT')
            break
        end

        disp(strcat('onset folder: ', onset_glob.folder));
        disp(strcat('onset file:   ', onset_glob.name));
        cue = struct2table(tdfread(onset_fname));
        keyword = extractBetween(onset_glob.name, 'run-0', '_events.tsv');
        task = char(extractAfter(keyword, '-'));

                % 
        if strcmp(task,'pain')
            test = dir(fullfile(onset_glob.folder, strcat(sub, '_', ses, '_task-cue_',strcat('run-', sprintf('%02d', A.run_num(run_ind))), '*_events_ttl.tsv')))
            if ~isempty(test)
                onset_fname = fullfile(char(test.folder), char(test.name))
                disp(strcat('this is a pain run with a ttl file: ', onset_fname))
            else
                disp(strcat('this is a pain run without a ttl file'))
            end
        end
        
        disp(strcat('task: ', task));
        disp(strcat('[ STEP 05 ]creating motion covariate text file...'));

        %% regressor covariates ______________________________________________________
        motion_fname = fullfile(motion_dir, 'csf_24dof_dummy_spike', sub, ses, ...
        strcat(sub, '_', ses, '_task-cue_run-', sprintf('%02d', A.run_num(run_ind)), '_confounds-subset.txt'));
        if ~exist(fullfile(motion_dir, 'csf_24dof_dummy_spike', sub, ses), 'dir'), mkdir(fullfile(motion_dir, 'csf_24dof_dummy_spike', sub, ses))
        end

        if ~isfile(motion_fname)
            m_fmriprep = fullfile(fmriprep_dir, sub, ses, 'func', ...
                strcat(sub, '_', ses, '_task-social_acq-mb8_run-', sprintf('%01d', A.run_num(run_ind)), '_desc-confounds_timeseries.tsv'));
            opts = detectImportOptions(m_fmriprep, 'FileType', 'text');
            opts = setvaropts(opts, 'TreatAsMissing', {'n/a', 'NA'});
            m = readtable(m_fmriprep, opts);
            m_subset = m(:, {'csf', 'trans_x', 'trans_x_derivative1', 'trans_x_power2', 'trans_x_derivative1_power2', ...
                                 'trans_y', 'trans_y_derivative1', 'trans_y_derivative1_power2', 'trans_y_power2', ...
                                 'trans_z', 'trans_z_derivative1', 'trans_z_derivative1_power2', 'trans_z_power2', ...
                                 'rot_x', 'rot_x_derivative1', 'rot_x_derivative1_power2', 'rot_x_power2', ...
                                 'rot_y', 'rot_y_derivative1', 'rot_y_derivative1_power2', 'rot_y_power2', ...
                                 'rot_z', 'rot_z_derivative1', 'rot_z_derivative1_power2', 'rot_z_power2'});
            dummy = array2table(zeros(size(m, 1), 1), 'VariableNames', {'dummy'});
            dummy.dummy(1:6, :) = 1;

            hasMatch = ~cellfun('isempty', regexp(m.Properties.VariableNames, 'motion_outlier', 'once'));

            if any(hasMatch)
                motion_outlier = m(:, m.Properties.VariableNames(hasMatch));
                spike = sum(motion_outlier{:, :}, 2);

                m_cov = [m_subset, dummy, array2table(spike)];
                m_clean = standardizeMissing(m_cov, 'n/a');

                for i = 1:25
                    m_clean.(i)(isnan(m_clean.(i))) = nanmean(m_clean.(i));
                end

            else
                m_cov = [m_subset, dummy];
                m_clean = standardizeMissing(m_cov, 'n/a');

                for i = 1:25
                    m_clean.(i)(isnan(m_clean.(i))) = nanmean(m_clean.(i));
                end

            end

            m_double = table2array(m_clean);

            dlmwrite(motion_fname, m_double, 'delimiter', '\t', 'precision', 13);
            R = dlmread(motion_fname);
            save_m_fname = fullfile(motion_dir, 'csf_24dof_dummy_spike', sub, ses, ...
                strcat(sub, '_', ses, '_task-cue_run-', sprintf('%02d', A.run_num(run_ind)), '_confounds-subset.mat'));
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
        matlabbatch{1}.spm.stats.fmri_spec.cvi = 'None';

        % RUN 01 _________________________________________________________________________
        scans = spm_select('Expand', smooth_nii);
        matlabbatch{1}.spm.stats.fmri_spec.sess(run_ind).scans = cellstr(scans);
        matlabbatch{1}.spm.stats.fmri_spec.sess(run_ind).cond(1).name = 'CUE';
        matlabbatch{1}.spm.stats.fmri_spec.sess(run_ind).cond(1).onset = double(cue.onset01_cue);
        matlabbatch{1}.spm.stats.fmri_spec.sess(run_ind).cond(1).duration = double(repelem(1, 12)'); ;
        matlabbatch{1}.spm.stats.fmri_spec.sess(run_ind).cond(1).tmod = 0;
        matlabbatch{1}.spm.stats.fmri_spec.sess(run_ind).cond(1).pmod = struct('name', {}, 'param', {}, 'poly', {});
        matlabbatch{1}.spm.stats.fmri_spec.sess(run_ind).cond(1).orth = 0;

        matlabbatch{1}.spm.stats.fmri_spec.sess(run_ind).cond(2).name = 'EXPECT_RATING';
        matlabbatch{1}.spm.stats.fmri_spec.sess(run_ind).cond(2).onset = double(cue.onset02_ratingexpect);
        matlabbatch{1}.spm.stats.fmri_spec.sess(run_ind).cond(2).duration = double(cue.pmod_expectRT);
        matlabbatch{1}.spm.stats.fmri_spec.sess(run_ind).cond(2).tmod = 0;
        matlabbatch{1}.spm.stats.fmri_spec.sess(run_ind).cond(2).pmod = struct('name', {}, 'param', {}, 'poly', {});
        matlabbatch{1}.spm.stats.fmri_spec.sess(run_ind).cond(2).orth = 0;

        matlabbatch{1}.spm.stats.fmri_spec.sess(run_ind).cond(3).name = 'STIM';
        matlabbatch{1}.spm.stats.fmri_spec.sess(run_ind).cond(3).onset = double(cue.onset03_stim);
        matlabbatch{1}.spm.stats.fmri_spec.sess(run_ind).cond(3).duration = double(repelem(5, 12)');
        matlabbatch{1}.spm.stats.fmri_spec.sess(run_ind).cond(3).tmod = 0;
        matlabbatch{1}.spm.stats.fmri_spec.sess(run_ind).cond(3).pmod(1).name = 'physio';
        matlabbatch{1}.spm.stats.fmri_spec.sess(run_ind).cond(3).pmod(1).param = double(cue.pmod_expectangle_demean); % TODO: add physio extracted data
        matlabbatch{1}.spm.stats.fmri_spec.sess(run_ind).cond(3).pmod(1).poly = 1;
        matlabbatch{1}.spm.stats.fmri_spec.sess(run_ind).cond(3).orth = 0;

        matlabbatch{1}.spm.stats.fmri_spec.sess(run_ind).cond(4).name = 'OUTCOME_RATING';
        matlabbatch{1}.spm.stats.fmri_spec.sess(run_ind).cond(4).onset = double(cue.onset04_ratingoutcome);
        matlabbatch{1}.spm.stats.fmri_spec.sess(run_ind).cond(4).duration = double(cue.pmod_outcomeRT);
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
    SPM_fname = fullfile(output_dir, 'SPM.mat');
    matlabbatch{2}.spm.stats.fmri_est.spmmat(1) = cfg_dep('fMRI model specification: SPM.mat File', substruct('.', 'val', '{}', {1}, '.', 'val', '{}', {1}, '.', 'val', '{}', {1}), substruct('.', 'spmmat'));
    matlabbatch{2}.spm.stats.fmri_est.write_residuals = 0;
    matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;

    % %% 3. contrast __________________________________________________________
    batch_fname = fullfile(output_dir, strcat(strcat(sub, '_batch.mat')));
    save(batch_fname, 'matlabbatch') %,'-v7.3');

    %% 4. run __________________________________________________________
    spm('defaults', 'FMRI');
    spm_jobman('run', matlabbatch);
    clearvars matlabbatch

    disp(strcat('FINISH - subject ', sub, ' complete'))

end
