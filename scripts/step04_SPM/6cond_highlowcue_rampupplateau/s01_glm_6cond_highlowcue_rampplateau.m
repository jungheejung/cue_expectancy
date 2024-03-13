function s01_glm_6cond_highlowcue_rampplateau(sub, input_dir, main_dir, fmriprep_dir, badruns_json, save_dir)

    %  if spike number is more than 20? flag and terminate. also save that in a text file. 
    %-----------------------------------------------------------------------
    % spm SPM - SPM12 (7771)
    % cfg_basicio BasicIO - Unknown
    %-----------------------------------------------------------------------
    disp('...STARTING JOBS');
    % TRY
    rootgroup = settings; rootgroup.matlab.general.matfile.SaveFormat.PersonalValue = 'v7.3'
    rootgroup.matlab.general.matfile.SaveFormat.TemporaryValue = 'v7.3';
    %-----------------------------------------------------------------------
    % PARAMETERS
    %     - STIM: CUE h x STIM h (onset03_stim)
    %     - STIM: CUE h x STIM m
    %     - STIM: CUE h x STIM l
    %     - STIM: CUE l x STIM h
    %     - STIM: CUE l x STIM m
    %     - STIM: CUE l x STIM l
    %     X ramp down and ramp up period for each of these 6 conditions
    %     - CUE:  CUE h (onset01_cue)
    %             CUE l
    %     - EXPECT RATING: onset02_ratingexpect, pmod_expectRT
    %     - OUTCOME RATING: onset04_ratingoutcome, pmod_outcomeRT

    %% 1. load parameters _______________________________________________________
    disacqs = 0;
    disp(sub);
    disp(strcat('[ STEP 01 ] setting parameters...'));
    % sub = strcat('sub-', sprintf('%04d', sub_input));
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
    nii_num_column = nii_col_names(endsWith(nii_col_names, '_num'));

    % find onset files
    onsetlist = dir(fullfile(onset_dir, sub, '*', strcat(sub, '_*_task-cue_*_events.tsv')));
    onsetT = struct2table(onsetlist);
    sortedonsetT = sortrows(onsetT, 'name');

    sortedonsetT.sub_num(:) = str2double(extractBetween(sortedonsetT.name, 'sub-', '_'));
    sortedonsetT.ses_num(:) = str2double(extractBetween(sortedonsetT.name, 'ses-', '_'));
    sortedonsetT.run_num(:) = str2double(extractBetween(sortedonsetT.name, 'run-', '_'));

    onset_col_names = sortedonsetT.Properties.VariableNames;
    onset_num_column = onset_col_names(endsWith(onset_col_names, '_num'));
    disp(onset_num_column)

    % load badruns from json _________________________________________________________________
    bad_runs_table = readBadRunsFromJSON(badruns_json);
    json_col_names = bad_runs_table.Properties.VariableNames;
    json_num_colomn = json_col_names(endsWith(json_col_names, '_num'));
    disp(bad_runs_table);
    % intersectRuns = intersect(bad_runs_table(:,json_num_colomn),sortedT(:, nii_num_column) );
    % intersectRuns = setdiff(bad_runs_table(:,json_num_colomn), sortedT(:, nii_num_column));
    % intersect_col_names = intersectRuns.Properties.VariableNames;
    % inter_num_column = intersect_col_names(endsWith(intersect_col_names, '_num'));


    [~, ia] = ismember(sortedT(:, nii_num_column), bad_runs_table(:,json_num_colomn), 'rows');
    intersectRuns = sortedT(setdiff(1:size(sortedT, 1), ia), :);
    intersect_col_names = intersectRuns.Properties.VariableNames;
    inter_num_column = intersect_col_names(endsWith(intersect_col_names, '_num'));




    %intersection of nifti and onset files
    A = intersect( intersectRuns(:, inter_num_column), sortedonsetT(:, onset_num_column) );
    disp(A);

    output_dir = fullfile(save_dir, sub);
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
        % [x] extract sub, ses, run info
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

        keyword = extractBetween(onset_glob.name, 'run-0', '_events.tsv');
        task = char(extractAfter(keyword, '-'));

        if strcmp(task,'pain')
            test = dir(fullfile(onset_glob.folder, strcat(sub, '_', ses, '_task-cue_',strcat('run-', sprintf('%02d', A.run_num(run_ind))), '*_events_ttl.tsv')));
            if ~isempty(test)
                onset_fname = fullfile(char(test.folder), char(test.name));
                cue = struct2table(tdfread(onset_fname));
                
                
                cue.rampup_onset = cue.TTL1;
                cue.rampup_dur = cue.TTL2 - cue.TTL1;
                cue.plateau_onset = cue.TTL2;
                cue.stim_dur = cue.TTL3 - cue.TTL1;
                % cue.rampdown_onset =cue.TTL3;
                % cue.rampdown_dur =cue.TTL4 - cue.TTL3;
                disp(strcat('this is a pain run with a ttl file: ', onset_fname))
            else
                disp(strcat('this is a pain run without a ttl file'))
                % rampup  = 
                % | stimtype      | rampup     | plateau    | rampdown     |
                % |---------------|------------|------------|--------------|
                % | low_stim      | 3.502      | 5.000      | 3.402        |
                % | med_stim      | 3.758      | 5.000      | 3.606        |
                % | high_stim     | 4.008      | 5.001      | 3.813        | 
                % Define the rampup values for each stim type
                
                cue = struct2table(tdfread(onset_fname));
                rampup_values = struct();
                rampup_values.low_stim = 3.502;
                rampup_values.med_stim = 3.758;
                rampup_values.high_stim = 4.008;

                rampdown_values = struct();
                rampdown_values.low_stim = 3.402;
                rampdown_values.med_stim = 3.606;
                rampdown_values.high_stim = 3.813;
                % Create a new column 'rampup' and initialize with NaN
                cue.rampup_onset = NaN(height(cue), 1); %
                cue.rampup_dur = NaN(height(cue), 1);
                cue.rampdown_onset = NaN(height(cue), 1); % onset03_stim + 5
                cue.rampdown_dur = NaN(height(cue), 1);
                cue.plateau_onset = NaN(height(cue), 1); % onset03_stim + rampup_values (per stim)
                cue.stim_dur = NaN(height(cue), 1);
                % Assign rampup values based on pmod_stimtype
                low_indices = cellfun(@(x) strcmp(x, 'low_stim'), cellstr(cue.pmod_stimtype));
                med_indices = cellfun(@(x) strcmp(x, 'med_stim'), cellstr(cue.pmod_stimtype));
                high_indices = cellfun(@(x) strcmp(x, 'high_stim'), cellstr(cue.pmod_stimtype));
                cue.rampup_dur(low_indices)= rampup_values.low_stim;
                cue.rampup_dur(med_indices)= rampup_values.med_stim;
                cue.rampup_dur(high_indices)= rampup_values.high_stim;
                cue.rampdown_dur(low_indices)= rampdown_values.low_stim;
                cue.rampdown_dur(med_indices)= rampdown_values.med_stim;
                cue.rampdown_dur(high_indices)= rampdown_values.high_stim;
                cue.rampup_onset = cue.onset03_stim;
                % cue.rampup_dur = cue.rampup_dur;
                cue.plateau_onset = cue.rampup_dur + cue.onset03_stim;
                cue.rampdown_onset = cue.rampup_dur + cue.onset03_stim + 5;
                cue.stim_dur = cue.rampup_dur + 5
                
                % cue.rampdown_dur = cue.rampdown_dur;

                
                % cue.rampup_onset
                % Display the updated table
                disp(cue);
            end
        else% for cognitive and vicarious tasks
            cue = struct2table(tdfread(onset_fname));
            cue.stim_dur = NaN(height(cue), 1);
            cue.plateau_onset = cue.onset03_stim;
            cue.rampup_onset = cue.onset03_stim - 2;
            cue.rampdown_onset = cue.onset03_stim + 5;
            % cue.rampup_dur = double(repelem(2, length(cue.onset03_stim))');
            % cue.rampdown_dur = double(repelem(2, length(cue.onset03_stim))');
            cue.stim_dur = 5
            
        end
        
        disp(strcat('task: ', task));
        disp(strcat('[ STEP 05 ]creating motion covariate text file...'));

        % cue = struct2table(tdfread(onset_fname));

        % bug report: there were spaces that added to a mistmach in dataframes
        % remove spaces
        cue.pmod_cuetype = cellstr(cue.pmod_cuetype);
        cue.pmod_stimtype = cellstr(cue.pmod_stimtype);
        cue.pmod_stimtype = strtrim(cue.pmod_stimtype);
        cue.pmod_cuetype = strtrim(cue.pmod_cuetype);
        disp(cue.pmod_cuetype)
        highcue = strcmp(cue.pmod_cuetype,'high_cue');
        lowcue = strcmp(cue.pmod_cuetype,'low_cue');
        highstim = strcmp(cue.pmod_stimtype, 'high_stim');
        medstim = strcmp(cue.pmod_stimtype, 'med_stim');
        lowstim = strcmp(cue.pmod_stimtype, 'low_stim');

% TODO
% if TTL file exists:
%     rampup is TTL1, rampdup duration is TTL2-TTL1
%     Rampdown is TTL3, ramdown duration is TTL4-TTL3
% if TTL file doen't exist, use average rampup and rampdown for specific stimulu




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
                disp("-- there are motion outliers")
                motion_outlier = m(:, m.Properties.VariableNames(hasMatch));
                spike = sum(motion_outlier{:, :}, 2);
                if size(motion_outlier,2) <= 800
                    disp("-- motion outliers are less than 20 columns")
                    m_cov = [m_subset, dummy, motion_outlier];
                    m_clean = standardizeMissing(m_cov, 'n/a');
                    for i = 1:size(m_clean,2)
                        m_clean.(i)(isnan(m_clean.(i))) = nanmean(m_clean.(i));
                    end
                elseif size(motion_outlier,2) > 800
                    disp(strcat('-- ABORT [!] too many spikes: ', size(motion_outlier,2)));
                    continue 
                end
            else
                disp("-- there are no motion outliers")
                m_cov = [m_subset, dummy];
                m_clean = standardizeMissing(m_cov, 'n/a');

                for i = 1:size(m_clean,2);
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

        % cond 1 : STIM_cue-high_stim-high
        matlabbatch{1}.spm.stats.fmri_spec.sess(run_ind).cond(1).name = strcat(task, '_STIM_cue-high_stim-high');
        matlabbatch{1}.spm.stats.fmri_spec.sess(run_ind).cond(1).onset = double(cue.rampup_onset(highcue(:,1) & highstim(:,1)));
        matlabbatch{1}.spm.stats.fmri_spec.sess(run_ind).cond(1).duration = double(repelem(cue.stim_dur, length(double(cue.plateau_onset(highcue(:,1) & highstim(:,1)))))');
        matlabbatch{1}.spm.stats.fmri_spec.sess(run_ind).cond(1).tmod = 0;
        matlabbatch{1}.spm.stats.fmri_spec.sess(run_ind).cond(1).pmod = struct('name', {}, 'param', {}, 'poly', {});
        matlabbatch{1}.spm.stats.fmri_spec.sess(run_ind).cond(1).orth = 0;


        % cond 2 : STIM_cue-high_stim-med
        matlabbatch{1}.spm.stats.fmri_spec.sess(run_ind).cond(2).name = strcat(task, '_STIM_cue-high_stim-med');
        matlabbatch{1}.spm.stats.fmri_spec.sess(run_ind).cond(2).onset = double(cue.rampup_onset(highcue(:,1) & medstim(:,1)));
        matlabbatch{1}.spm.stats.fmri_spec.sess(run_ind).cond(2).duration = double(repelem(cue.stim_dur, length(double(cue.plateau_onset(highcue(:,1) & medstim(:,1)))))');
        matlabbatch{1}.spm.stats.fmri_spec.sess(run_ind).cond(2).tmod = 0;
        matlabbatch{1}.spm.stats.fmri_spec.sess(run_ind).cond(2).pmod = struct('name', {}, 'param', {}, 'poly', {});
        matlabbatch{1}.spm.stats.fmri_spec.sess(run_ind).cond(2).orth = 0;


        % cond 3 : STIM_cue-high_stim-low
        matlabbatch{1}.spm.stats.fmri_spec.sess(run_ind).cond(3).name = strcat(task, '_STIM_cue-high_stim-low');
        matlabbatch{1}.spm.stats.fmri_spec.sess(run_ind).cond(3).onset = double(cue.rampup_onset(highcue(:,1) & lowstim(:,1)));
        matlabbatch{1}.spm.stats.fmri_spec.sess(run_ind).cond(3).duration = double(repelem(cue.stim_dur, length(double(cue.plateau_onset(highcue(:,1) & lowstim(:,1)))))');
        matlabbatch{1}.spm.stats.fmri_spec.sess(run_ind).cond(3).tmod = 0;
        matlabbatch{1}.spm.stats.fmri_spec.sess(run_ind).cond(3).pmod = struct('name', {}, 'param', {}, 'poly', {});
        matlabbatch{1}.spm.stats.fmri_spec.sess(run_ind).cond(3).orth = 0;

        
% cond 4 : STIM_cue-low_stim-high
        matlabbatch{1}.spm.stats.fmri_spec.sess(run_ind).cond(4).name = strcat(task, '_STIM_cue-low_stim-high');
        matlabbatch{1}.spm.stats.fmri_spec.sess(run_ind).cond(4).onset = double(cue.rampup_onset(lowcue(:,1) & highstim(:,1)));
        matlabbatch{1}.spm.stats.fmri_spec.sess(run_ind).cond(4).duration = double(repelem(cue.stim_dur, length(double(cue.plateau_onset(lowcue(:,1) & highstim(:,1)))))');
        matlabbatch{1}.spm.stats.fmri_spec.sess(run_ind).cond(4).tmod = 0;
        matlabbatch{1}.spm.stats.fmri_spec.sess(run_ind).cond(4).pmod = struct('name', {}, 'param', {}, 'poly', {});
        matlabbatch{1}.spm.stats.fmri_spec.sess(run_ind).cond(4).orth = 0;


% cond 5 : STIM_cue-low_stim-med
        matlabbatch{1}.spm.stats.fmri_spec.sess(run_ind).cond(5).name = strcat(task, '_STIM_cue-low_stim-med');
        matlabbatch{1}.spm.stats.fmri_spec.sess(run_ind).cond(5).onset = double(cue.rampup_onset(lowcue(:,1) & medstim(:,1)));
        matlabbatch{1}.spm.stats.fmri_spec.sess(run_ind).cond(5).duration = double(repelem(cue.stim_dur, length(double(cue.plateau_onset(lowcue(:,1) & medstim(:,1)))))');
        matlabbatch{1}.spm.stats.fmri_spec.sess(run_ind).cond(5).tmod = 0;
        matlabbatch{1}.spm.stats.fmri_spec.sess(run_ind).cond(5).pmod = struct('name', {}, 'param', {}, 'poly', {});
        matlabbatch{1}.spm.stats.fmri_spec.sess(run_ind).cond(5).orth = 0;


% cond 6 : STIM_cue-low_stim-low
        matlabbatch{1}.spm.stats.fmri_spec.sess(run_ind).cond(6).name = strcat(task, '_STIM_cue-low_stim-low');
        matlabbatch{1}.spm.stats.fmri_spec.sess(run_ind).cond(6).onset = double(cue.rampup_onset(lowcue(:,1) & lowstim(:,1)));
        matlabbatch{1}.spm.stats.fmri_spec.sess(run_ind).cond(6).duration = double(repelem(cue.stim_dur, length(double(cue.plateau_onset(lowcue(:,1) & lowstim(:,1)))))');
        matlabbatch{1}.spm.stats.fmri_spec.sess(run_ind).cond(6).tmod = 0;
        matlabbatch{1}.spm.stats.fmri_spec.sess(run_ind).cond(6).pmod = struct('name', {}, 'param', {}, 'poly', {});
        matlabbatch{1}.spm.stats.fmri_spec.sess(run_ind).cond(6).orth = 0;


        matlabbatch{1}.spm.stats.fmri_spec.sess(run_ind).cond(7).name = strcat(task, '_CUE_cue-high');
        matlabbatch{1}.spm.stats.fmri_spec.sess(run_ind).cond(7).onset = double(cue.onset01_cue(highcue(:,1)));
        matlabbatch{1}.spm.stats.fmri_spec.sess(run_ind).cond(7).duration = double(repelem(1, length(double(cue.onset01_cue(highcue(:,1)))))');
        matlabbatch{1}.spm.stats.fmri_spec.sess(run_ind).cond(7).tmod = 0;
        matlabbatch{1}.spm.stats.fmri_spec.sess(run_ind).cond(7).pmod = struct('name', {}, 'param', {}, 'poly', {});
        matlabbatch{1}.spm.stats.fmri_spec.sess(run_ind).cond(7).orth = 0;

        matlabbatch{1}.spm.stats.fmri_spec.sess(run_ind).cond(8).name = strcat(task, '_CUE_cue-low');
        matlabbatch{1}.spm.stats.fmri_spec.sess(run_ind).cond(8).onset = double(cue.onset01_cue(lowcue(:,1)));
        matlabbatch{1}.spm.stats.fmri_spec.sess(run_ind).cond(8).duration = double(repelem(1, length(double(cue.onset01_cue(lowcue(:,1)))))');
        matlabbatch{1}.spm.stats.fmri_spec.sess(run_ind).cond(8).tmod = 0;
        matlabbatch{1}.spm.stats.fmri_spec.sess(run_ind).cond(8).pmod = struct('name', {}, 'param', {}, 'poly', {});
        matlabbatch{1}.spm.stats.fmri_spec.sess(run_ind).cond(8).orth = 0;

        matlabbatch{1}.spm.stats.fmri_spec.sess(run_ind).cond(9).name = 'EXPECT_RATING';
        matlabbatch{1}.spm.stats.fmri_spec.sess(run_ind).cond(9).onset = double(cue.onset02_ratingexpect);
        matlabbatch{1}.spm.stats.fmri_spec.sess(run_ind).cond(9).duration = double(cue.pmod_expectRT);
        matlabbatch{1}.spm.stats.fmri_spec.sess(run_ind).cond(9).tmod = 0;
        matlabbatch{1}.spm.stats.fmri_spec.sess(run_ind).cond(9).pmod = struct('name', {}, 'param', {}, 'poly', {});
        matlabbatch{1}.spm.stats.fmri_spec.sess(run_ind).cond(9).orth = 0;

        matlabbatch{1}.spm.stats.fmri_spec.sess(run_ind).cond(10).name = 'OUTCOME_RATING';
        matlabbatch{1}.spm.stats.fmri_spec.sess(run_ind).cond(10).onset = double(cue.onset04_ratingoutcome);
        matlabbatch{1}.spm.stats.fmri_spec.sess(run_ind).cond(10).duration = double(cue.pmod_outcomeRT);
        matlabbatch{1}.spm.stats.fmri_spec.sess(run_ind).cond(10).tmod = 0;
        matlabbatch{1}.spm.stats.fmri_spec.sess(run_ind).cond(10).pmod = struct('name', {}, 'param', {}, 'poly', {});
        matlabbatch{1}.spm.stats.fmri_spec.sess(run_ind).cond(10).orth = 0;

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


function bad_runs_table = readBadRunsFromJSON(badruns_file)
    % Read the badruns_file and construct a table with sub_num, ses_num, and run_num
    bad_runs_table = table();

    try
        fid = fopen(badruns_file);
        json_str = fread(fid, '*char').';
        fclose(fid);
        bad_runs = jsondecode(json_str);
        
        subjects = fieldnames(bad_runs);
        num_subjects = numel(subjects);

        % Loop through each subject and their corresponding bad runs
        for i = 1:num_subjects
            sub = subjects{i};
            bad_run_list = bad_runs.(sub);
            num_bad_runs = numel(bad_run_list);
            sub_num = str2double(regexp(sub, '\d+', 'match'));
            % Extract the sub_num, ses_num, and run_num from each bad run
            for j = 1:num_bad_runs
                ses_num = str2double(extractBetween(bad_run_list{j}, 'ses-', '_run-'));
                run_num = str2double(regexp(bad_run_list{j}, 'run-(\d+)', 'tokens', 'once'));%extractBetween(bad_run_list{j}, 'ses-', '_run-');
%                 ses_num = str2double(run_info{1});
%                 run_num = str2double(run_info{2});

                % Append the data to the table
                new_row = table(sub_num, ses_num, run_num, 'VariableNames', {'sub_num', 'ses_num', 'run_num'});
                bad_runs_table = [bad_runs_table; new_row];
            end
        end

    catch
        disp('Error reading badruns JSON file.');
    end
end
