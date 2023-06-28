clear; close all;

%% 
% help __________________________________________________________________
% load nifti filename (single trial)
% extract metadata
% load behavioral file
% merge metadata and behavioral file
%%
% xx : N subject x 1 cell
% yy : N subject x 1 cell
% mm : N subject x 1 cell [ K voxel x T trials ]
event = 'cue'; %string(event);
csv = 'cue-outcome'; %string(csv);
y_rating = 'outcome';% string(y_rating);
x_keyword = 'cue';
m_keyword = 'stim';
y_keyword = 'outcome';
addpath(genpath('/dartfs-hpc/rc/lab/C/CANlab/modules/MediationToolbox'));
addpath(genpath('/dartfs-hpc/rc/lab/C/CANlab/modules/CanlabCore'));
addpath(genpath('/dartfs-hpc/rc/lab/C/CANlab/modules/spm12'));
rmpath(genpath('/dartfs-hpc/rc/lab/C/CANlab/modules/spm12/external/fieldtrip'));
rmpath('/dartfs-hpc/rc/lab/C/CANlab/modules/spm12/external/fieldtrip/external/stats');

% parameters __________________________________________________________________
main_dir = fileparts(fileparts(pwd)); % /dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_cue
disp(main_dir); %main_dir = '/Volumes/spacetop_projects_social';
nifti_dir = fullfile(main_dir,'analysis','fmri','nilearn','singletrial');
meta_dir = fullfile(main_dir, 'data', 'beh', 'beh03_bids');
save_dir = fullfile(main_dir,'analysis','fmri','mediation','pdm');
% TODO: 
% [x] load bad_run json. From that exclude bad runs. 

% Use the dir function to list the contents of the parent directory
contents = dir(nifti_dir);
% Filter the results to include only directories
subDirectories = contents([contents.isdir]);
% Exclude '.' and '..' directories from the list
subDirectories = subDirectories(~ismember({subDirectories.name}, {'.', '..'}));
% Extract the names of the subdirectories
sublist = {subDirectories.name};

% sublist = [6,7,8,9,10,11,13,14,15,16,17,21,23,24,28,29,30,31,32,33,35,37,43,47,51,53,55,58,60,61,62,64,65,66,68,69,70,73,74,76,78,79,80,81,84,85];
xx = cell( length(sublist), 1);
mm = cell( length(sublist), 1);
mm_fdata = cell( length(sublist), 1);
yy = cell( length(sublist), 1);

run = {'pain', 'vicarious', 'cognitive'};

for r = 1:length(run)
    % create empty dat
    xx = cell( length(sublist), 1);
    mm = cell( length(sublist), 1);
    mm_fdata = cell( length(sublist), 1);
    yy = cell( length(sublist), 1);
    outlier = cell( length(sublist),1);
    
    % save dir
    task_subfldr = fullfile(save_dir, strcat('task-',run{r},'_x-', x_keyword, '_m-', m_keyword,'_y-',y_keyword));
    if not(exist(task_subfldr, 'dir'))
        mkdir(task_subfldr)
    end
    dat_fname =  fullfile(task_subfldr, strcat('task-',run{r},'_PDM_x-', x_keyword, '_m-', m_keyword,'_y-',y_keyword, '_DAT.mat'));
    if ~isfile(dat_fname)
        for s = 1:length(sublist)
        % step 01 __________________________________________________________________
            % grab singletrial filelists
            % sub = strcat('sub-', sprintf('%04d', sublist(s)));
            sub = sublist(s);
            basename = strcat(sub, '*runtype-', run{r}, '*_event-', event, '*');
            fname_nifti = filenames(fullfile(nifti_dir, sub, strcat(basename, '*.nii.gz')));
            % unzip for matlab
            for i = 1:numel(fname_nifti)
                fname_nii = strrep(fname_nifti{i}, '.nii.gz', '.nii');
                if ~exist(fname_nii,'file'),gunzip(fname_nifti{i}); end
            end
            singletrial_flist = filenames(fullfile(nifti_dir, sub, strcat(sub, '*runtype-', run{r}, '*_event-', event,'*.nii')));
            disp(singletrial_flist);
        % step 00 __________________________________________________________________
            % load badruns json
            json_fname = fullfile(main_dir, 'scripts/step00_qc/qc03_fmriprep_visualize/bad_runs.json');
            fileContent = fileread(json_fname);
            badRunsData = jsondecode(fileContent);
            % Iterate over the singletrial_flist and filter out filenames
            filtered_list = singletrial_flist; 
            for i = 1:numel(singletrial_flist)
                filepath = singletrial_flist{i};
                
                [~, filename, ~] = fileparts(filepath);
                sub_key = strcat('sub_', extractBetween(filename, 'sub-', '_')); % Extract subject and run information from the filepath
                if isfield(badRunsData, sub_key)
                    disp(strcat('Current subject ', sub, 'has bad runs. Filtering...'));
                    % Iterate over the bad runs for the subject
                    for j = 1:numel(badRunsData.(sub_key))
                        % reconstruct the badrun string (it doesn't have zeropadding)
                        badRun = badRunsData.(sub_key){j};
                        [session, ~] = regexp(badRun, 'ses-(\d+)_run-(\d+)', 'tokens', 'match');
                        badrun_ses_num = session{1}{1};                    badrun_run_num = session{1}{2};
                        run_to_remove = sprintf('ses-%s_run-%02d', badrun_ses_num, str2double(badrun_run_num));
                        disp(run_to_remove);
                        % remove the matching bad runs from the filtered_list
                        filtered_list = filtered_list(~cellfun(@(x) ~isempty(strfind(x, run_to_remove)), filtered_list));
                    end
                    disp(strcat("left with ", num2str(length(filtered_list)), " of trials"));
                end

            end
            singletrial_flist = filtered_list; 
            % Display the filtered filenames
                
            % fname_nifti = fullfile(nifti_dir, sub, strcat(basename, '.nii.gz'));
            % fname_nii = fullfile(nifti_dir, sub, strcat(basename, '.nii'));
            % if ~exist(fname_nii,'file'), gunzip(fname_nifti)
            % end
            % dat = fmri_data(singletrial_flist);
            % grab metadata
            % TODO: prototype:
            % onset,duration,trial_type,sub,ses,run,runtype,eventtype,trialnum,cuetype,stimtype,expectrating,outcomerating,singletrial_fname
            % /dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_cue/data/beh/beh03_bids/sub-0060/ses-01
            % sub-0060_ses-01_task-cue_acq-mb8_run-04_events.tsv
            % step 02 __________________________________________________________________
            % sub = strcat('sub-', sprintf('%04d', sublist(s)));
            % fname = strcat('metadata_', sub ,'_task-social_run-', run{r}, '_ev-', event, '.csv');
            % T = readtable(fullfile(meta_dir, sub, fname));
            % basename = strrep(strrep(fname,'metadata_',''), '.csv', '');
            beh_flist = filenames(fullfile(main_dir, 'data', 'beh', 'beh03_bids', sub, '*', strcat('*.tsv')));
            concat_beh = table();
            for i = 1:numel(beh_flist)
                % Load the TSV file
                beh_df = readtable(beh_flist{i}, 'Delimiter', ',', 'FileType', 'text');
                concat_beh = [concat_beh; beh_df];
            end
            
            % step 03 intersection of behavioral and fmri __________________________________________________________________
            % Extract the basenames without file extension from concat_beh.singletrial_fname
            basenames_concat_beh = cellfun(@(x) regexprep(x, '\.nii\.gz$', ''), concat_beh.singletrial_fname, 'UniformOutput', false);
            basenames_concat_beh = strcat(basenames_concat_beh, '.nii');
            [~, basenames_singletrial_flist, ext] = cellfun(@fileparts, singletrial_flist, 'UniformOutput', false);
            basenames_singletrial_flist = strcat(basenames_singletrial_flist, ext);

            % get intersection and select the identified rows
            [~, idx_concat_beh, idx_singletrial_flist] = intersect(basenames_concat_beh, basenames_singletrial_flist);
            subset_beh = concat_beh(idx_concat_beh, :);

            %% NOTE: doublecheck order __________________________________________________________________
            % Extract the basenames from singletrial_flist and Compare 
            [~, selected_basenames, ~] = cellfun(@fileparts, subset_beh.singletrial_fname, 'UniformOutput', false);
            is_order_match = ismember(selected_basenames, basenames_singletrial_flist);

            % Check if the order matches
            if all(is_order_match)
                disp('The order of filenames in subset_beh matches the order in singletrial_flist.');
            else
                disp('The order of filenames in subset_beh does not match the order in singletrial_flist.');
            end

            % step 04 convert values into contrast code beh __________________________________________________________________
            % Define the mapping of values to numeric codes
            % stim_map = {'high_cue', 'med_stim', 'low_stim'}; stim_linearmap = [1, -1];
            % % Convert the column values to a categorical array
            % categoricalColumn = categorical(subset_beh.stimtype, stim_map);
            % subset_beh.stim_linear = stim_linearmap(grp2idx(categoricalColumn));


            % Define the mapping of values to numeric codes
            cue_map = {'high_cue', 'low_cue'};
            cue_contrast = [1, -1];
            % Convert the column values to a categorical array
            categoricalColumn = categorical(subset_beh.cuetype, cue_map);
            subset_beh.cuecon = cue_contrast(grp2idx(categoricalColumn))';


            % step 05 __________________________________________________________________
            % provide input as XMY
            xx{s, 1} = subset_beh.cuecon; % table2array(T(:, 'cue_con'));% T.cue; %
            dat = fmri_data(singletrial_flist);
            mm{s, 1} = dat.dat;
            yy{s, 1} = subset_beh.outcomerating;% table2array(T(:,strcat(y_rating, '_rating'))); %T.outcome_rating;
            
            % step 04 __________________________________________________________________
            % diagnostics
            [wh_outlier_uncorr, wh_outlier_corr]  = plot(dat);
            outlier{s,1} = wh_outlier_corr;
            assignin('base','dat',dat);
            options.codeToEvaluate = sprintf('plot(%s)','dat');
            options.format = 'pdf';
            options.showCode = false;
            if not(exist(fullfile(task_subfldr,'diagnostics'),'dir'))
                mkdir(fullfile(task_subfldr,'diagnostics'))
            end
            options.outputDir = fullfile(task_subfldr, 'diagnostics');
            options.imageFormat = 'jpg';
            mydoc = publish('/dartfs-hpc/rc/lab/C/CANlab/modules/CanlabCore/CanlabCore/@fmri_data/plot.m',options);
            [folder, name] = fileparts(mydoc);
            movefile(mydoc, fullfile(task_subfldr, 'diagnostics',strcat('singletrial-diagnostics_run-', run{r},'_sub-' , sub,'_',datestr(now,'mm-dd-yy'), '.pdf')));
        end
    else
        load(dat_fname);
    end
    save(dat_fname,'xx','yy','mm','outlier','-v7.3');
end

%% PDM
for r = 1:length(run)
    
    % input variables
    cue_input = struct();
    
    cue_input.x_keyword = x_keyword;
    cue_input.m_keyword = m_keyword;
    cue_input.y_keyword = y_keyword;
    cue_input.main_dir = main_dir;
    disp(fname_template);
    fname_template = filenames(fullfile(main_dir, 'analysis', 'fmri', 'nilearn', 'singletrial', sublist{1}, strcat(sublist{1}, '*runtype-', run{r}, '_ev-', event,'*trial-000*.nii')));
    disp(fname_template)
    cue_input.single_nii = fname_template{1};
    % cue_input.single_nii = fullfile(main_dir, strcat('/analysis/fmri/spm/multivariate/s03_concatnifti/sub-0065/sub-0065_task-social_run-', run{r}, '_ev-', event,'.nii'));
    cue_input.sublist = sublist;
    cue_input.task = run{r};
    cue_input.iter = 5000;
    cue_input.num_components = 2;
    
    
    task_subfldr = fullfile(save_dir, strcat('task-',run{r},'_x-', x_keyword, '_m-', m_keyword,'_y-',y_keyword));
    assignin('base','input',cue_input);
    options.codeToEvaluate = sprintf('pdm_01cue_plot(%s)','cue_input');%strcat('task=', run{r});
    options.format = 'pdf';
    options.outputDir = task_subfldr;
    options.imageFormat = 'jpg';
    pdm_output = publish('pdm_01cue_plot.m',options);
    
    [folder, name] = fileparts(pdm_output);
    movefile(pdm_output, fullfile(task_subfldr,strcat('singletrial-pdm_task-',run{r},'_x-', x_keyword, '_m-', m_keyword, '_y-', y_keyword, '_',datestr(now,'mm-dd-yy'), '.pdf')));
end
