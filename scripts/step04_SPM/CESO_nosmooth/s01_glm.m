function s01_glm(sub, input_dir, main_dir, fmriprep_dir, badruns_json, save_dir)
%-----------------------------------------------------------------------
% spm SPM - SPM12 (7771)
% cfg_basicio BasicIO - Unknown
%-----------------------------------------------------------------------
disp('...STARTING JOBS');

rootgroup = settings; rootgroup.matlab.general.matfile.SaveFormat.PersonalValue = 'v7.3'
rootgroup.matlab.general.matfile.SaveFormat.TemporaryValue = 'v7.3';
%% ---------------------------------------------------------------------------
%  parameters
% ----------------------------------------------------------------------------
%     - CUE: onset01_cue
%     - EXPECT RATING: onset02_ratingexpect, pmod_expectRT
%     - STIM: onset03_stim
%     - OUTCOME RATING: onset04_ratingoutcome, pmod_outcomeRT

%% ---------------------------------------------------------------------------
%  1. load parameters
% ----------------------------------------------------------------------------
disacqs = 0;
disp(strcat('[ STEP 01 ] setting parameters...'));
disp(strcat('____________________________', sub, '____________________________'))

% 1-1. contrast mapper ______________________________________________________
keySet = {'pain', 'vicarious', 'cognitive'};
con1 = [2 -1 -1]; con2 = [-1 2 -1]; con3 = [-1 -1 2]; con4 = [1 1 1];
m1 = containers.Map(keySet, con1);
m2 = containers.Map(keySet, con2);
m3 = containers.Map(keySet, con3);
m4 = containers.Map(keySet, con4);
% 1-2. directories _______________________________________________________
motion_dir = fullfile(main_dir, 'data', 'fmri', 'fmri02_motion');
onset_dir = fullfile(main_dir, 'data', 'fmri', 'fmri01_onset', 'onset02_SPM');
disp(strcat('input_dir: ', input_dir));
disp(strcat('motion_dir: ', motion_dir));
disp(strcat('onset_dir: ', onset_dir));
disp(strcat('main_dir: ', main_dir));
disp(strcat('[ STEP 02 ] PRINT VARIABLE'))
disp(strcat('sub:    ', sub));



%% ---------------------------------------------------------------------------
%  2. find nifti/ onset files and grab intersection
% ----------------------------------------------------------------------------
% niilist = dir(fullfile(input_dir, sub, '*/smooth-6mm_*task-cue*_bold.nii')); % directory for smooth data
niilist = dir(fullfile(fmriprep_dir, sub, '*/func/*task-social_*bold.nii.gz')); % directory for non-smooth fmriprep data
onsetlist = dir(fullfile(onset_dir, sub, '*', strcat(sub, '_*_task-cue_*_events.tsv')));
intersectRuns = get_intersect_runs(niilist, onsetlist, badruns_json)

% TODO: DEP after confirming SPM model --> start
% nT = struct2table(niilist); % convert the struct array to a table
% sortedT = sortrows(nT, 'name'); % sort the table by 'DOB'

% sortedT.sub_num(:) = str2double(extractBetween(sortedT.name, 'sub-', '_'));
% sortedT.ses_num(:) = str2double(extractBetween(sortedT.name, 'ses-', '_'));
% sortedT.run_num(:) = str2double(extractBetween(sortedT.name, 'run-', '_'));

% nii_col_names = sortedT.Properties.VariableNames;
% nii_num_column = nii_col_names(endsWith(nii_col_names, '_num'));

% % 2-2. find onset files
% onsetT = struct2table(onsetlist);
% sortedonsetT = sortrows(onsetT, 'name');

% sortedonsetT.sub_num(:) = str2double(extractBetween(sortedonsetT.name, 'sub-', '_'));
% sortedonsetT.ses_num(:) = str2double(extractBetween(sortedonsetT.name, 'ses-', '_'));
% sortedonsetT.run_num(:) = str2double(extractBetween(sortedonsetT.name, 'run-', '_'));

% onset_col_names = sortedonsetT.Properties.VariableNames;
% onset_num_column = onset_col_names(endsWith(onset_col_names, '_num'));
% disp(nii_num_column)

% % 2-4. intersection of nifti and onset files
% A = intersect(sortedT(:, nii_num_column), sortedonsetT(:, onset_num_column));

% % 2-3. load badruns from json 
% bad_runs_table = readBadRunsFromJSON(badruns_json);
% json_col_names = bad_runs_table.Properties.VariableNames;
% json_num_column = json_col_names(endsWith(json_col_names, '_num'));
% disp(bad_runs_table);

% [~, ia] = ismember(A(:, nii_num_column), bad_runs_table(:,json_num_column), 'rows');
% % intersectRuns = A(setdiff(1:size(A, 1), ~ia), :);
% intersectRuns = A(ia == 0, :);
% % intersect_col_names = intersectRuns.Properties.VariableNames;
% % inter_num_column = intersect_col_names(endsWith(intersect_col_names, '_num'));
% TODO: DEP after confirming SPM model <<--end



% 2-5. create output dir and remove previous SPM.mat files if any
output_dir = fullfile(save_dir, sub);
if ~exist(output_dir, 'dir')
    mkdir(output_dir)
end

if isfile(fullfile(output_dir, 'SPM.mat'))
    delete(fullfile(output_dir,'*.nii'));
    delete(fullfile(output_dir,'SPM.mat'));
end

matlabbatch = cell(1, 2);

%% ---------------------------------------------------------------------------
%  3. build model run-wise
% ----------------------------------------------------------------------------
for run_ind = 1:size(intersectRuns, 1)
    disp(strcat('______________________run', num2str(run_ind), '____________________________'));
    %  3-1. extract sub, ses, run info
    sub = []; ses = []; run = [];
    sub = strcat('sub-', sprintf('%04d', intersectRuns.sub_num(run_ind)));
    ses = strcat('ses-', sprintf('%02d', intersectRuns.ses_num(run_ind)));
    run = strcat('run-', sprintf('%01d', intersectRuns.run_num(run_ind)));
    
    disp(strcat('[ STEP 03 ] gunzip and saving nifti...'));

    preproc_nii = fullfile(fmriprep_dir, sub, ses, 'func', ...
        strcat(sub, '_', ses, '_task-social_acq-mb8_', run, '_space-MNI152NLin2009cAsym_desc-preproc_bold.nii'));
    
    if ~exist(preproc_nii, 'file')
        gunzip(strcat(preproc_nii ,'.gz'))
        % end
        % disp(strcat('ABORT [!] ', preproc_nii, 'does not exist'))
        % break
    end
    
    disp(strcat('[ STEP 04 ]constructing contrasts...'));
    onset_glob = dir(fullfile(onset_dir, sub, ses, strcat(sub, '_', ses, '_task-cue_', strcat('run-', sprintf('%02d', intersectRuns.run_num(run_ind))), '*_events.tsv')));
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
    
    if strcmp(task,'pain')
        test = dir(fullfile(onset_glob.folder, strcat(sub, '_', ses, '_task-cue_',strcat('run-', sprintf('%02d', intersectRuns.run_num(run_ind))), '*_events_ttl.tsv')))
        if ~isempty(test)
            onset_fname = fullfile(char(test.folder), char(test.name))
            disp(strcat('this is a pain run with a ttl file: ', onset_fname))
        else
            disp(strcat('this is a pain run without a ttl file'))
        end
    end
    
    disp(strcat('task: ', task));
    disp(strcat('[ STEP 05 ]creating motion covariate text file...'));

    %% ---------------------------------------------------------------------------
    %  4. nuissance covariates
    % ----------------------------------------------------------------------------

    % 4-1. load motion filename from pre-existing dir
    motion_fname = fullfile(motion_dir, 'csf_24dof_dummy_spike', sub, ses, ...
        strcat(sub, '_', ses, '_task-cue_run-', sprintf('%02d', intersectRuns.run_num(run_ind)), '_confounds-subset.txt'));
    if ~exist(fullfile(motion_dir, 'csf_24dof_dummy_spike', sub, ses), 'dir'), mkdir(fullfile(motion_dir, 'csf_24dof_dummy_spike', sub, ses))
    end
    
    % 4-2. if motion filename doesn't exist, construct it from fmriprep confounds.tsv files
    if ~isfile(motion_fname)
        m_fmriprep = fullfile(fmriprep_dir, sub, ses, 'func', ...
            strcat(sub, '_', ses, '_task-social_acq-mb8_run-', sprintf('%01d', intersectRuns.run_num(run_ind)), '_desc-confounds_timeseries.tsv'));

        save_m_fname = fullfile(motion_dir, 'csf_24dof_dummy_spike', sub, ses, ...
                strcat(sub, '_', ses, '_task-cue_run-', sprintf('%02d', intersectRuns.run_num(run_ind)), '_confounds-subset.mat'));
        process_fmriprep_data(m_fmriprep, ...
                'add_dof', 24, ...
                'add_dummy', true,...
                'num_dummy', 6,... 
                'add_motion_outlier', true,...
                'motion_outlier_threshold', 800,... 
                'save_fname',save_m_fname);
                
        % opts = detectImportOptions(m_fmriprep, 'FileType', 'text');
        % opts = setvaropts(opts, 'TreatAsMissing', {'n/a', 'NA'});
        % m = readtable(m_fmriprep, opts);

        % dummy = array2table(zeros(size(m, 1), 1), 'VariableNames', {'dummy'});
        % dummy.dummy(1:6, :) = 1;
        
        % hasMatch = ~cellfun('isempty', regexp(m.Properties.VariableNames, 'motion_outlier', 'once'));
        
        % if any(hasMatch)
        %     disp("-- there are motion outliers")
        %     motion_outlier = m(:, m.Properties.VariableNames(hasMatch));
        %     spike = sum(motion_outlier{:, :}, 2);
        %     if size(motion_outlier,2) <= 800
        %         disp("-- motion outliers are less than 800 columns")
        %         m_cov = [m_subset, dummy, motion_outlier];
        %         m_clean = standardizeMissing(m_cov, 'n/a');
        %         for i = 1:size(m_clean,2)
        %             m_clean.(i)(isnan(m_clean.(i))) = nanmean(m_clean.(i));
        %         end
        %     elseif size(motion_outlier,2) > 800
        %         disp(strcat('-- ABORT [!] too many spikes: ', size(motion_outlier,2)));
        %         continue
        %     end
        % else
        %     disp("-- there are no motion outliers")
        %     m_cov = [m_subset, dummy];
        %     m_clean = standardizeMissing(m_cov, 'n/a');
            
        %     for i = 1:size(m_clean,2);
        %         m_clean.(i)(isnan(m_clean.(i))) = nanmean(m_clean.(i));
        %     end
            
        % end
        
        % m_double = table2array(m_clean);
        
        % dlmwrite(motion_fname, m_double, 'delimiter', '\t', 'precision', 13);
        % R = dlmread(motion_fname);
        % save_m_fname = fullfile(motion_dir, 'csf_24dof_dummy_spike', sub, ses, ...
        %     strcat(sub, '_', ses, '_task-cue_run-', sprintf('%02d', intersectRuns.run_num(run_ind)), '_confounds-subset.mat'));
        % save(save_m_fname, 'R');
    else
        disp('motion subset file exists');
    end
    
    disp(strcat('[ STEP 06 ]starting spmbatch...'));
    
    %% ---------------------------------------------------------------------------
    %  5. MAIN ANALYSIS: spm batch script
    % ----------------------------------------------------------------------------

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
    scans = spm_select('Expand', preproc_nii);
    matlabbatch{1}.spm.stats.fmri_spec.sess(run_ind).scans = cellstr(scans);
    matlabbatch{1}.spm.stats.fmri_spec.sess(run_ind).cond(1).name = 'CUE';
    matlabbatch{1}.spm.stats.fmri_spec.sess(run_ind).cond(1).onset = double(cue.onset01_cue);
    matlabbatch{1}.spm.stats.fmri_spec.sess(run_ind).cond(1).duration = double(repelem(1, length(double(cue.onset01_cue)))');
    matlabbatch{1}.spm.stats.fmri_spec.sess(run_ind).cond(1).tmod = 0;
    matlabbatch{1}.spm.stats.fmri_spec.sess(run_ind).cond(1).pmod = struct('name', {}, 'param', {}, 'poly', {});
    matlabbatch{1}.spm.stats.fmri_spec.sess(run_ind).cond(1).orth = 0;
    
    matlabbatch{1}.spm.stats.fmri_spec.sess(run_ind).cond(2).name = 'EXPECT_RATING';
    matlabbatch{1}.spm.stats.fmri_spec.sess(run_ind).cond(2).onset = double(cue.onset02_ratingexpect);
    matlabbatch{1}.spm.stats.fmri_spec.sess(run_ind).cond(2).duration = double(cue.pmod_expectRT);
    matlabbatch{1}.spm.stats.fmri_spec.sess(run_ind).cond(2).tmod = 0;
    matlabbatch{1}.spm.stats.fmri_spec.sess(run_ind).cond(2).pmod = struct('name', {}, 'param', {}, 'poly', {});
    matlabbatch{1}.spm.stats.fmri_spec.sess(run_ind).cond(2).orth = 0;
    
    matlabbatch{1}.spm.stats.fmri_spec.sess(run_ind).cond(3).name = [task,'_STIM'];
    matlabbatch{1}.spm.stats.fmri_spec.sess(run_ind).cond(3).onset = double(cue.onset03_stim);
    matlabbatch{1}.spm.stats.fmri_spec.sess(run_ind).cond(3).duration = double(repelem(5, length(double(cue.onset03_stim)))');
    matlabbatch{1}.spm.stats.fmri_spec.sess(run_ind).cond(3).tmod = 0;
    matlabbatch{1}.spm.stats.fmri_spec.sess(run_ind).cond(3).pmod = struct('name', {}, 'param', {}, 'poly', {});
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

%% ---------------------------------------------------------------------------
%  6. estimation
% ----------------------------------------------------------------------------
disp(strcat('[ STEP 07 ] estimation '))
SPM_fname = fullfile(output_dir, 'SPM.mat');
matlabbatch{2}.spm.stats.fmri_est.spmmat(1) = cfg_dep('fMRI model specification: SPM.mat File', substruct('.', 'val', '{}', {1}, '.', 'val', '{}', {1}, '.', 'val', '{}', {1}), substruct('.', 'spmmat'));
matlabbatch{2}.spm.stats.fmri_est.write_residuals = 0;
matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;

batch_fname = fullfile(output_dir, strcat(strcat(sub, '_batch.mat')));
save(batch_fname, 'matlabbatch') %,'-v7.3');

spm('defaults', 'FMRI');
spm_jobman('run', matlabbatch);
clearvars matlabbatch

disp(strcat('FINISH - subject ', sub, ' complete'))

end


%% ---------------------------------------------------------------------------
%  functions
% ----------------------------------------------------------------------------
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
            
            % Append the data to the table
            new_row = table(sub_num, ses_num, run_num, 'VariableNames', {'sub_num', 'ses_num', 'run_num'});
            bad_runs_table = [bad_runs_table; new_row];
        end
    end
    
catch
    disp('Error reading badruns JSON file.');
end
end

function intersectRuns = get_intersect_runs(niilist, onsetlist, badruns_json)
    % GETINTERSECTRUNS Computes the intersection of nifti and onset files after filtering based on bad runs.
    %
    %   intersectRuns = getIntersectRuns(niilist, onsetlist, badruns_json) computes the intersection
    %   of nifti and onset files provided in niilist and onsetlist, respectively, after filtering them
    %   based on the bad runs defined in the JSON file specified by badruns_json.
    %
    %   INPUTS:
    %   - niilist: A structure array containing information about nifti files.
    %   - onsetlist: A structure array containing information about onset files.
    %   - badruns_json: The path to the JSON file containing bad run information.
    %
    %   OUTPUTS:
    %   - intersectRuns: A table containing the intersection of nifti and onset files after filtering based
    %     on bad runs.
    
        % Convert niilist and onsetlist to tables
        nT = struct2table(niilist);
        onsetT = struct2table(onsetlist);
    
        % Sort the tables by 'name'
        sortedT = sortrows(nT, 'name');
        sortedonsetT = sortrows(onsetT, 'name');
    
        % Extract sub_num, ses_num, and run_num columns
        sortedT.sub_num(:) = str2double(extractBetween(sortedT.name, 'sub-', '_'));
        sortedT.ses_num(:) = str2double(extractBetween(sortedT.name, 'ses-', '_'));
        sortedT.run_num(:) = str2double(extractBetween(sortedT.name, 'run-', '_'));
    
        sortedonsetT.sub_num(:) = str2double(extractBetween(sortedonsetT.name, 'sub-', '_'));
        sortedonsetT.ses_num(:) = str2double(extractBetween(sortedonsetT.name, 'ses-', '_'));
        sortedonsetT.run_num(:) = str2double(extractBetween(sortedonsetT.name, 'run-', '_'));
    
        % Get nii_num_column and onset_num_column
        nii_col_names = sortedT.Properties.VariableNames;
        nii_num_column = nii_col_names(endsWith(nii_col_names, '_num'));
        onset_col_names = sortedonsetT.Properties.VariableNames;
        onset_num_column = onset_col_names(endsWith(onset_col_names, '_num'));
    
        % Compute the intersection of nifti and onset files
        A = intersect(sortedT(:, nii_num_column), sortedonsetT(:, onset_num_column));
    
        % Load badruns from JSON
        bad_runs_table = readBadRunsFromJSON(badruns_json);
    
        % Get json_num_column
        json_col_names = bad_runs_table.Properties.VariableNames;
        json_num_column = json_col_names(endsWith(json_col_names, '_num'));
    
        % Find the indices to remove based on bad runs
        [~, ia] = ismember(A(:, nii_num_column), bad_runs_table(:, json_num_column), 'rows');
    
        % Filter the intersection based on bad runs
        intersectRuns = A(ia == 0, :);
    end
    

% function process_fmriprep_data(m_fmriprep, m_subset_varnames, varargin)
%     % PROCESS_FMRIPREP_DATA Process fMRIprep data and save it in a specified format with optional key-value pairs.
%     %
%     %   process_fmriprep_data(m_fmriprep, m_subset_varnames, varargin) reads and processes the fMRIprep data from
%     %   the provided file path m_fmriprep, extracts specified variables, adds optional variables based on key-value pairs,
%     %   handles motion outlier columns (if provided), applies a threshold to motion outliers (if provided),
%     %   and saves the processed data in the specified file path.
    
%         % Define optional key-value pairs and their default values
%         p = inputParser;
%         addOptional(p, 'add_dummy', false);
%         addOptional(p, 'num_dummy', 6);
%         addOptional(p, 'add_motion_outlier', true);
%         addOptional(p, 'motion_outlier_threshold', 800);
%         addOptional(p, 'save_fname', 'processed_data.mat');
        
%         % Parse the input arguments
%         parse(p, varargin{:});
        
%         % Read the fMRIprep data and handle missing values
%         opts = detectImportOptions(m_fmriprep, 'FileType', 'text');
%         opts = setvaropts(opts, 'TreatAsMissing', {'n/a', 'NA'});
%         m = readtable(m_fmriprep, opts);
    
%         % Extract specified variables
%         m_subset = m(:, m_subset_varnames);
    
%         % Add a dummy variable if requested
%         if p.Results.add_dummy
%             num_dummy = p.Results.num_dummy;
%             dummy = array2table(zeros(size(m, 1), 1), 'VariableNames', {'dummy'});
%             dummy.dummy(1:num_dummy, :) = 1;
%             m_subset = [m_subset, dummy];
%         end
    
%         % Handle motion outlier columns (if provided)
%         if p.Results.add_motion_outlier
%             hasMatch = ~cellfun('isempty', regexp(m.Properties.VariableNames, 'motion_outlier', 'once'));
            
%             if any(hasMatch)
%                 disp("-- there are motion outliers")
%                 motion_outlier = m(:, m.Properties.VariableNames(hasMatch));
%                 spike = sum(motion_outlier{:, :}, 2);
                
%                 if size(motion_outlier, 2) <= p.Results.motion_outlier_threshold
%                     disp("-- motion outliers are less than the specified threshold")
%                     m_cov = [m_subset, motion_outlier];
%                     m_clean = standardizeMissing(m_cov, 'n/a');
                    
%                     for i = 1:size(m_clean, 2)
%                         m_clean.(i)(isnan(m_clean.(i))) = nanmean(m_clean.(i));
%                     end
%                 else
%                     disp(strcat('-- ABORT [!] too many spikes: ', size(motion_outlier, 2)));
%                     return
%                 end
%             else
%                 disp("-- there are no motion outliers")
%                 m_cov = m_subset;
%                 m_clean = standardizeMissing(m_cov, 'n/a');
                
%                 for i = 1:size(m_clean, 2)
%                     m_clean.(i)(isnan(m_clean.(i))) = nanmean(m_clean.(i));
%                 end
%             end
%         else
%             disp("-- there are no motion outliers")
%             m_cov = m_subset;
%             m_clean = standardizeMissing(m_cov, 'n/a');
            
%             for i = 1:size(m_clean, 2)
%                 m_clean.(i)(isnan(m_clean.(i))) = nanmean(m_clean.(i));
%             end
%         end
    
%         % Convert to double and save to the specified file
%         m_double = table2array(m_clean);
%         dlmwrite(p.Results.save_fname, m_double, 'delimiter', '\t', 'precision', 13);
%         R = dlmread(p.Results.save_fname);
    
%         % Save the processed data in MAT format
%         save(p.Results.save_fname, 'R');
%     end


function process_fmriprep_data(m_fmriprep, varargin)
    % PROCESS_FMRIPREP_DATA Process fMRIprep data and save it in a specified format with optional key-value pairs.
    %
    %   process_fmriprep_data(m_fmriprep, varargin) reads and processes the fMRIprep data from
    %   the provided file path m_fmriprep, extracts specified variables, adds optional variables based on key-value pairs,
    %   handles motion outlier columns (if provided), applies a threshold to motion outliers (if provided),
    %   and saves the processed data in the specified file path.
    
        % Define optional key-value pairs and their default values
        p = inputParser;
        addOptional(p, 'add_dof', 6); % Default value is 6
        addOptional(p, 'add_dummy', false);
        addOptional(p, 'num_dummy', 6);
        addOptional(p, 'add_motion_outlier', false);
        addOptional(p, 'motion_outlier_threshold', 800);
        addOptional(p, 'save_fname', 'nuissance_covariates.mat');
        
        % Parse the input arguments
        parse(p, varargin{:});
        
        % Read the fMRIprep data and handle missing values
        opts = detectImportOptions(m_fmriprep, 'FileType', 'text');
        opts = setvaropts(opts, 'TreatAsMissing', {'n/a', 'NA'});
        m = readtable(m_fmriprep, opts);
    
        % Extract specified variables based on the add_dof value
        switch p.Results.add_dof
            case 6
                m_subset_varnames = {'csf', 'trans_x', 'trans_y', 'trans_z', 'rot_x', 'rot_y', 'rot_z'};
            case 12
                m_subset_varnames = {'csf', 'trans_x', 'trans_x_derivative1', ...
                    'trans_y', 'trans_y_derivative1',  ...
                    'trans_z', 'trans_z_derivative1', ...
                    'rot_x', 'rot_x_derivative1', ...
                    'rot_y', 'rot_y_derivative1', ...
                    'rot_z', 'rot_z_derivative1'};
            case 24
                m_subset_varnames = {'csf', 'trans_x', 'trans_x_derivative1', 'trans_x_power2', 'trans_x_derivative1_power2', ...
                    'trans_y', 'trans_y_derivative1', 'trans_y_derivative1_power2', 'trans_y_power2', ...
                    'trans_z', 'trans_z_derivative1', 'trans_z_derivative1_power2', 'trans_z_power2', ...
                    'rot_x', 'rot_x_derivative1', 'rot_x_derivative1_power2', 'rot_x_power2', ...
                    'rot_y', 'rot_y_derivative1', 'rot_y_derivative1_power2', 'rot_y_power2', ...
                    'rot_z', 'rot_z_derivative1', 'rot_z_derivative1_power2', 'rot_z_power2'};
            otherwise
                error('Invalid value for add_dof. Use 6, 12, or 24.');
        end
        
        m_subset = m(:, m_subset_varnames);
    

    % Add a dummy variable if requested
    if p.Results.add_dummy
        num_dummy = p.Results.num_dummy;
        dummy = array2table(zeros(size(m, 1), 1), 'VariableNames', {'dummy'});
        dummy.dummy(1:num_dummy, :) = 1;
        m_subset = [m_subset, dummy];
    end

    % Handle motion outlier columns (if provided)
    if p.Results.add_motion_outlier
        hasMatch = ~cellfun('isempty', regexp(m.Properties.VariableNames, 'motion_outlier', 'once'));
        
        if any(hasMatch)
            disp("-- there are motion outliers")
            motion_outlier = m(:, m.Properties.VariableNames(hasMatch));
            spike = sum(motion_outlier{:, :}, 2);
            
            if size(motion_outlier, 2) <= p.Results.motion_outlier_threshold
                disp("-- motion outliers are less than the specified threshold")
                m_cov = [m_subset, motion_outlier];
                m_clean = standardizeMissing(m_cov, 'n/a');
                
                for i = 1:size(m_clean, 2)
                    m_clean.(i)(isnan(m_clean.(i))) = nanmean(m_clean.(i));
                end
            else
                disp(strcat('-- ABORT [!] too many spikes: ', size(motion_outlier, 2)));
                return
            end
        else
            disp("-- there are no motion outliers")
            m_cov = m_subset;
            m_clean = standardizeMissing(m_cov, 'n/a');
            
            for i = 1:size(m_clean, 2)
                m_clean.(i)(isnan(m_clean.(i))) = nanmean(m_clean.(i));
            end
        end
    else
        disp("-- there are no motion outliers")
        m_cov = m_subset;
        m_clean = standardizeMissing(m_cov, 'n/a');
        
        for i = 1:size(m_clean, 2)
            m_clean.(i)(isnan(m_clean.(i))) = nanmean(m_clean.(i));
        end
    end

    % Convert to double and save to the specified file
    m_double = table2array(m_clean);
    % Get the file parts
    [filePath, fileName, fileExtension] = fileparts(p.Results.save_fname);
    save_fname_txt = fullfile(filePath, [fileName, '.txt']);

    dlmwrite(save_fname_txt, m_double, 'delimiter', '\t', 'precision', 13);
    R = dlmread(save_fname_txt);

    % Save the processed data in MAT format
    save(p.Results.save_fname, 'R');
    end
        
