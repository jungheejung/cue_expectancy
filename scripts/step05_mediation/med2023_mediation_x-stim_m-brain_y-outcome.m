% -------------------------------------------------------------------------
% script overview
% -------------------------------------------------------------------------

% This is a script that runs the multilevel mediation analysis 
% for the cue expectancy pain task
% 
% X is stimulus contrast (high med low = 1, 0, -1)
% M is singletrials from stimulus epoch (pain plateau)
% Y is outcome rating from behavioral measures
% cov is cue contrast, given that we need to account for the other experimental factor
% l2m is a moderator, a between subject variable, average NPS response.

% -------------------------------------------------------------------------
% directories and parameters
% -------------------------------------------------------------------------
% singletrial_dir = '/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop/social/analysis/fmri/fsl/multivariate/isolate_nifti';
addpath(genpath('./utils'));

% Define the case variable
case = 'discovery'; %'local';  % Change this to 'discovery' as needed
switch case
    case 'local'
        matlab_moduledir = '/Users/h/Documents/MATLAB';
        main_dir = '/Volumes/spacetop_projects_cue';
        singletrial_dir = fullfile('/Volumes/seagate/cue_singletrials/uncompressed_singletrial');
        beh_dir = '/Volumes/seagate/cue_singletrials/beh03_bids';
        NPS_fname = '/Users/h/Documents/projects_local/cue_expectancy/analysis/fmri/nilearn/deriv01_signature/rampupdown/signature-NPSpos_sub-all_runtype-pvc_event-stimulus.tsv';
        graymatter_mask = '/Users/h/Documents/MATLAB/CanlabCore/CanlabCore/canlab_canonical_brains/Canonical_brains_surfaces/gray_matter_mask.nii';
    case 'discovery'
        matlab_moduledir = '/dartfs-hpc/rc/lab/C/CANlab/modules'
        main_dir = '/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_cue';
%         singletrial_dir = fullfile(main_dir, 'analysis','fmri','nilearn','singletrial');
        singletrial_dir = '/dartfs-hpc/scratch/f0042x1/singletrial_smooth';
        beh_dir = fullfile(main_dir, 'data', 'beh', 'beh03_bids');
        NPS_fname = fullfile(main_dir, 'analysis/fmri/nilearn/deriv01_signature/rampupdown/signature-NPSpos_sub-all_runtype-pvc_event-stimulus.tsv');
        graymatter_mask = fullfile(matlab_moduledir, 'CanlabCore/CanlabCore/canlab_canonical_brains/Canonical_brains_surfaces/gray_matter_mask.nii')
    otherwise
        error('Invalid case specified.');
end


addpath(genpath(fullfile(matlab_moduledir, 'CanlabCore')));
addpath(genpath(fullfile(matlab_moduledir,'Neuroimaging_Pattern_Masks')));
addpath(genpath(fullfile(matlab_moduledir,'MediationToolbox')));
rmpath(genpath(fullfile(matlab_moduledir,'spm12/external/fieldtrip')));
rmpath(genpath(fullfile(matlab_moduledir,'spm12/external/fieldtrip/external/stats')));
% script_mediation_dir = pwd;
% main_dir = fileparts(fileparts(script_mediation_dir)); % /dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_social
% main_dir = '/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_cue';
% main_dir = '/Volumes/spacetop_projects_cue';
% 
% singletrial_dir = fullfile(main_dir, 'analysis','fmri','nilearn','singletrial');
% beh_dir = fullfile(main_dir, 'data', 'beh', 'beh03_bids');

% singletrial_dir = fullfile('/Volumes/seagate/cue_singletrials/uncompressed_singletrial');
% beh_dir = '/Volumes/seagate/cue_singletrials/beh03_bids';
sublist = find_sublist_from_dir(singletrial_dir); % find subdirectories that start with keyword "sub-"
X = cell(1, length(sublist));
M = cell(1, length(sublist));
Y = cell(1, length(sublist));
cov = cell(1, length(sublist));
l2m = zeros(1, length(sublist));

eventlist = {'stim'}; 
%{'cue', 'stim'}

task = 'pain';
fprintf('step 1. parameter setup')

% -------------------------------------------------------------------------
% construct dataframes for mediation analysis
% -------------------------------------------------------------------------
% NPS_fname = '/Users/h/Documents/projects_local/cue_expectancy/analysis/fmri/nilearn/deriv01_signature/rampupdown/signature-NPSpos_sub-all_runtype-pvc_event-stimulus.tsv';

npsdf = readtable(NPS_fname,"FileType","text", 'Delimiter', ',');
for e = 1:length(eventlist)
for s = 1:length(sublist)
    %%%% step 01: glob all the nifti files
    %%%% step 02: identify number of unique sub/ses/runs and load behavioral files
    %%%% step 03: merge the behavioral files and niftifiles based on intersection
    % Extract the base filenames from the full path filenames
    %%%% step 04: if any of the Y regressors have NA values, the mediation will fail. Remove these instances
    %%%% step 05: contrast code the X regressors. Originally, they are strings in my behavioral dataframe
    %%%% step 06: the mediation code expects the full path of nifti files. Construct this based on the basename columns
    %%%% step 07: final step! construct the X, M, Y cells for the mediation analysis
    disp(strcat('starting ', sublist{s}))%strcat('sub-',sprintf('%04d', sublist(s)))))
    
    singletrial_flist = dir(fullfile(singletrial_dir, sublist{s},...
                        strcat(sublist{s}, '*_runtype-', task, '*_event-',eventlist{e},'*.nii')   ));
    if ~isempty(singletrial_flist)
    singletrial_fldr = {singletrial_flist.folder}; fname = {singletrial_flist.name};
    singletrial_files = strcat(singletrial_fldr,'/', fname)';
    
    unique_bids = unique_combination_bids(singletrial_files);

    beh_df = load_beh_based_on_bids(beh_dir, unique_bids);
    % Assuming table1 and table2 are your two tables with the same column names
    combinedTable = innerjoin(npsdf, beh_df, 'Keys', 'singletrial_fname');

    singletrial_basefname = cellfun(@(x) extractAfter(x, max(strfind(x, filesep))), singletrial_files, 'UniformOutput', false);
    merge_beh_nii = merge_on_nifti_beh(singletrial_basefname, combinedTable);
    metadf_clean = remove_missing_behvalues(merge_beh_nii, 'outcomerating');
    cue_contrast_mapper = containers.Map({'low_cue', 'high_cue'}, [-1, 1]);
    stim_contrast_mapper = containers.Map({'low_stim', 'med_stim', 'high_stim'}, [-1, 0, 1]);
    metadf_cue = contrast_coding(metadf_clean, 'cuetype', 'cue_contrast', cue_contrast_mapper);
    metadf_con = contrast_coding(metadf_cue, 'stimtype', 'stim_contrast', stim_contrast_mapper);
    mediation_df = add_fullpath_column(metadf_con, singletrial_dir, sublist{s}, 'singletrial_fname', 'fullpath_fname');
    
    X{1,s} = mediation_df.stim_contrast;
    M{1,s} = mediation_df.fullpath_fname;
    Y{1,s} = mediation_df.outcomerating;
    cov{1,s} = mediation_df.cue_contrast;
    l2m(s) = mean(mediation_df.NPSpos); 
    end
end
end

[X, Y, M, cov, l2m] = filter_empty_cells(X, Y, M, cov, l2m);
M = convert_cell2char(M);

fprintf('step 2. X, Y, M fully set up')
% Initialize an empty cell array to store the converted char arrays
% charArrays = cell(size(M));
% 
% % Loop through each element in the main cell array
% for i = 1:length(M)
%     % Extract the inner cell array
%     innerCellArray = M{i};
%     
%     % Check if the inner cell array is empty
%     if isempty(innerCellArray)
%         charArrays{i} = [];
%         continue;
%     end
% 
%     % Determine the maximum string length in the inner cell array
%     maxLength = max(cellfun(@length, innerCellArray));
% 
%     % Pad each string in the inner cell array and convert to char array
% %     charArrays{i} = char(cellfun(@(s) pad(s, maxLength), innerCellArray, 'UniformOutput', false));
%     charArrays{i} = char(innerCellArray);
% end

% -------------------------------------------------------------------------
% unzip files (bash)
% -------------------------------------------------------------------------


% find singletrial -type f -name "*.nii.gz" -exec sh -c 'mkdir -p "uncompressed_singletrial/$(dirname "{}" | cut -d "/" -f 2-)" && gunzip -c "{}" > "uncompressed_singletrial/$(dirname "{}" | cut -d "/" -f 2-)/$(basename "{}" .gz)"' \;
% 
% #!/bin/bash
% 
% # Define the main directory containing the subdirectories
% main_dir="uncompressed_singletrial"
% 
% # List of subdirectories you want to process
% subdirs=("sub-0055" "sub-0062" "sub-0071" "sub-0079" "sub-0086" "sub-0093" "sub-0101" "sub-0111" "sub-0119" "sub-0128"
% "sub-0056" "sub-0063" "sub-0073" "sub-0080" "sub-0087" "sub-0094" "sub-0102" "sub-0112" "sub-0120" "sub-0129"
% "sub-0057" "sub-0064" "sub-0074" "sub-0081" "sub-0088" "sub-0095" "sub-0103" "sub-0114" "sub-0122" "sub-0130"
% "sub-0058" "sub-0066" "sub-0075" "sub-0082" "sub-0089" "sub-0097" "sub-0104" "sub-0115" "sub-0123" "sub-0131"
% "sub-0059" "sub-0068" "sub-0076" "sub-0083" "sub-0090" "sub-0098" "sub-0106" "sub-0116" "sub-0124" "sub-0132"
% "sub-0060" "sub-0069" "sub-0077" "sub-0084" "sub-0091" "sub-0099" "sub-0107" "sub-0117" "sub-0126" "sub-0133"
% "sub-0061" "sub-0070" "sub-0078" "sub-0085" "sub-0092" "sub-0100" "sub-0109" "sub-0118" "sub-0127")
% # Loop through the specified subdirectories
% for subdir in "${subdirs[@]}"; do
%     echo "Processing $subdir..."
%     
%     # Define the source directory and target directory
%     src_dir="/Volumes/seagate/cue_singletrials/singletrial/$subdir"
%     target_dir="/Volumes/seagate/cue_singletrials/uncompressed_singletrial/$subdir"
%     
%     # Run your command for this subdirectory
%     find "$src_dir" -type f -name "*.nii.gz" -exec sh -c 'mkdir -p "$target_dir/$(dirname "{}" | cut -d "/" -f 2-)" && gunzip -c "{}" > "$target_dir/$(dirname "{}" | cut -d "/" -f 2-)/$(basename "{}" .gz)"' \;
%     
%     echo "Finished processing $subdir."
% done
%%%%%%%
% clean up empty arrays
% Assuming X, Y, and M are cell arrays containing image data for different subjects
% Assuming X, Y, and M are cell arrays containing image data for different subjects
% Assuming X, Y, and M are cell arrays containing image data for different subjects
% Assuming X, Y, and M are cell arrays containing image data for different subjects
% num_subjects = numel(X);  % Assuming X, Y, M have the same number of subjects
% 
% % Initialize cell arrays to store filtered data
% X_filtered = cell(num_subjects, 1);
% Y_filtered = cell(num_subjects, 1);
% M_filtered = cell(num_subjects, 1);
% 
% % Loop through subjects and filter out cells with empty arrays
% for i = 1:num_subjects
%     % Check if the cell contains an empty array
%     if ~isempty(X{i}) && ~isempty(Y{i}) && ~isempty(M{i}) && ~isempty(X{i}(:)) && ~isempty(Y{i}(:)) && ~isempty(M{i}(:))
%         X_filtered{i} = X{i};
%         Y_filtered{i} = Y{i};
%         M_filtered{i} = M{i};
%     end
% end
% 
% % Remove cells with empty arrays from the filtered arrays
% X_filtered = X_filtered(~cellfun('isempty', X_filtered));
% Y_filtered = Y_filtered(~cellfun('isempty', Y_filtered));
% M_filtered = M_filtered(~cellfun('isempty', M_filtered));

% Now, X_filtered, Y_filtered, and M_filtered contain only non-empty cells




% -------------------------------------------------------------------------
% start mediation analysis
% -------------------------------------------------------------------------

addpath(genpath(fullfile(matlab_moduledir, 'CanlabCore')));
addpath(genpath(fullfile(matlab_moduledir,'Neuroimaging_Pattern_Masks')));
addpath(genpath(fullfile(matlab_moduledir,'MediationToolbox')));
addpath(genpath(fullfile(matlab_moduledir, 'spm12')));
rmpath(genpath(fullfile(matlab_moduledir,'spm12/external/fieldtrip')));
rmpath(genpath(fullfile(matlab_moduledir,'spm12/external/fieldtrip/external/stats')));

SETUP.mask = which(graymatter_mask);
SETUP.preprocX = 0;
SETUP.preprocY = 0;
SETUP.preprocM = 0;
SETUP.wh_is_mediator = 'M';
% M = charArrays;
% mediation_brain_multilevel(X, Y, M, SETUP, 'nopreproc')
% X = X_filtered;
% Y = Y_filtered;
% M = M_filtered;
mediation_brain_multilevel(X, Y, M, SETUP, 'nopreproc', 'covs', cov, 'L2M', l2m)
SETUP = mediation_brain_corrected_threshold('fdr');
% Save variables with compression


dashes = '----------------------------------------------';
printstr = @(dashes) disp(dashes);
printhdr = @(str) fprintf('\n\n%s\n%s\n%s\n%s\n%s\n\n', dashes, dashes, str, dashes, dashes);

printhdr('Path a: Cue to Brain Response')

mediation_brain_results('a', 'thresh', ...
    SETUP.fdr_p_thresh, 'size', 5, ...
    'slices', 'tables', 'names', 'save');
print('Path_a_results.pdf', '-dpdf');

% Results for Path b
% Generate results for effects of brain responses on pain reports, controlling for stimulus  temperature.
printhdr('Path b: Brain Response to Actual Rating, Adjusting for Cue')

mediation_brain_results('b', 'thresh', ...
    SETUP.fdr_p_thresh, 'size', 5, ...
    'slices', 'tables', 'names', 'save');
print('Path_b_results.pdf', '-dpdf');
% Results for Path a*b
% Generate results for the mediation effect. Here, we'll return some clusters structures with results to the workspace as output so we can examine them later. (We can also load them from disk).
printhdr('Path a*b: Brain Mediators of Cue Effects on General')

[clpos, clneg, clpos_data, clneg_data, clpos_data2, clneg_data2] = mediation_brain_results('ab', 'thresh', ...
    SETUP.fdr_p_thresh, 'size', 5, ...
    'slices', 'tables', 'names', 'save');
print('Path_ab_results.pdf', '-dpdf');
% Filter beh_df to retain only rows where there was a match

    % for f = 1: length(singletrial_files)
    %     [filepath,name,ext] = fileparts(singletrial_files{f});
    %     parsef = split(name,'_');
    %     event = split(parsef{3}, '.');

    %     % corresponding nifti text
    %     nifti_fname = strcat('niftifname_', parsef{1}, '_', parsef{2}, '_', event{1}, '.txt');
            
    %     nifti_fdir = fullfile(singletrial_dir, sublist{s} );
    %     fid = fopen(fullfile(nifti_fdir, nifti_fname),'r');
    %     start_row = 1;
    %     nifti_list= textscan(fid, '%s', 'Delimiter', '', 'WhiteSpace', '', 'HeaderLines' ,start_row-1, 'ReturnOnError', false);
    %     fclose(fid);


        % % unzip via spm
        % % step 02 __________________________________________________________________
        % % based on nifti filename text file, grab corresponding behavioral data
        % cue_contrast = []; stim_contrast = []; expect_rating = []; actual_rating = [];
        % for n = 1: length(nifti_list{1})
        %     nifti_list{1}{n}
        %     A = regexp( nifti_list{1}{n}, '\<0*[+]?\d+\.?\d', 'match' );
        %     % sub_num   = strcat('sub-', A{1});
        %     % ses_num   = str2num(A{2});
        %     % run_num   = str2num(A{3});
        %     trial = str2num(A{4});
            
        %     beh_dir = fullfile(main_dir,'data','beh','beh03_bids');
        %     beh_pattern = fullfile(
        %         beh_dir,
        %         f"sub-{sub:04d}",
        %         f"ses-{ses:02d}",
        %         f"sub-{sub:04d}_ses-{ses:02d}_task-cue_*run-{run:02d}_runtype-*_events.tsv",
        %     csv_fname = dir(fullfile(beh_dir,...
        %         strcat('sub-', A{1}),...
        %         strcat('ses-', A{2}),...
        %         strcat('sub-', A{1}, '_ses-', A{2}, '_task-social_run-', A{3}, '*.csv') ));
        %     T = readtable(fullfile(csv_fname.folder, csv_fname.name));
                    
        %     % grab cue type info, append to dataframe
        %     if strcmpi(char(T.param_cue_type(trial+1)), 'low_cue')
        %         cue_contrast = [cue_contrast ; -1];
        %     elseif strcmpi(char(T.param_cue_type(trial+1)), 'high_cue')
        %         cue_contrast = [cue_contrast ; 1];
        %     end
            
	    % if strcmpi(char(T.param_stimulus_type(trial+1)), 'low_stim')
        %         stim_contrast = [stim_contrast ; 48];
        %     elseif strcmpi(char(T.param_stimulus_type(trial+1)), 'med_stim')
        %         stim_contrast = [stim_contrast ; 49];
        %     elseif strcmpi(char(T.param_stimulus_type(trial+1)), 'high_stim')
        %         stim_contrast = [stim_contrast ; 50];
        %     end

        %     actual_rating = [actual_rating; T.event04_actual_angle(trial+1)];
        %     expect_rating = [expect_rating; T.event02_expect_angle(trial+1)];
            
            
        % end
        % % step 03 __________________________________________________________________
        % %  save as csv - set table parameters
        % vnames = {'trial','cue','stim','expect_rating','actual_rating','nii_filename'};
        % vtypes = {'double','double','string','double','double','string'}
        % F = table('Size',[size(nifti_list{1},1), size(vnames,2)],'VariableNames',vnames,'VariableTypes',vtypes);
        % F.trial = [1:length(nifti_list{1})]';
        % F.cue = cue_contrast;
        % F.stim = stim_contrast;
        % F.expect_rating = expect_rating;
        % F.actual_rating = actual_rating;
        % F.nii_filename = nifti_list{1};
        % F.nii_filename = eraseBetween(F.nii_filename, 1,2); % remove the './ from the filenames'
        % save_tablename = strcat('metadata_', parsef{1}, '_', parsef{2}, '_', event{1}, '.csv')
        % writetable(F,fullfile(nifti_fdir, save_tablename));

% step 04 __________________________________________________________________
    end
end
end


%
% Subject   1,  27 images.
% Subject   2,  46 images.
% Subject   3,  47 images.
% Subject   4,  46 images.
% Subject   5,  47 images.
% Subject   6,  12 images.
% Subject   7,  35 images.
% Subject   8,  48 images.
% Subject   9,  43 images.
% Subject  10,  24 images.
% Subject  11,  48 images.
% Subject  12,  48 images.
% Subject  13,  24 images.
% Subject  14,  58 images.
% Subject  15,  48 images.
% Subject  16,  66 images.
% Subject  17,  57 images.
% Subject  18,  49 images.
% Subject  19,  36 images.
% Subject  20,  22 images.
% Subject  21,  55 images.
% Subject  22,  57 images.
% Subject  23,  24 images.
% Subject  24,  72 images.
% Subject  25,  23 images.
% Subject  26,  72 images.
% Subject  27,  47 images.
% Subject  28,  72 images.
% Subject  29,  46 images.
% Subject  30,  72 images.
% Subject  31,  68 images.
% Subject  32,  71 images.
% Subject  33,  47 images.
% Subject  34,  48 images.
% Subject  35,  24 images.
% Subject  36,  70 images.
% Subject  37,  67 images.
% Subject  38,  24 images.
% Subject  39,  72 images.
% Subject  40,  71 images.
% Subject  41,  69 images.
% Subject  42,  70 images.
% Subject  43,  71 images.
% Subject  44,  48 images.
% Subject  45,  71 images.
% Subject  46,  71 images.
% Subject  47,  46 images.
% Subject  48,  71 images.
% Subject  49,  68 images.
% Subject  50,  67 images.
% Subject  51,  12 images.
% Subject  52,  23 images.
% Subject  53,  10 images.
% Subject  54,  24 images.
% Subject  55,  24 images.
% Subject  56,  23 images.
% Subject  57,   0 images.
% Subject  58,  69 images.
% Subject  59,  62 images.
% Subject  60,   0 images.
% Subject  61,  24 images.
% Subject  62,  46 images.
% Subject  63,  71 images.
% Subject  64,  38 images.
% Subject  65,  61 images.
% Subject  66,  58 images.
% Subject  67,  18 images.
% Subject  68,  43 images.
% Subject  69,  23 images.
% Subject  70,  18 images.
% Subject  71,  64 images.
% Subject  72,  66 images.
% Subject  73,  72 images.
% Subject  74,  59 images.
% Subject  75,  72 images.
% Subject  76,  70 images.
% Subject  77,  58 images.
% Subject  78,  71 images.
% Subject  79,  69 images.
% Subject  80,  72 images.
% Subject  81,  24 images.
% Subject  82,  14 images.
% Subject  83,  70 images.
% Subject  84,  64 images.
% Subject  85,  71 images.
% Subject  86,   0 images.
% Subject  87,  31 images.
% Subject  88,  47 images.
% Subject  89,  72 images.
% Subject  90,  47 images.
% Subject  91,  69 images.
% Subject  92,  71 images.
% Subject  93,  42 images.
% Subject  94,  23 images.
% Subject  95,  66 images.
% Subject  96,  70 images.
% Subject  97,   6 images.
% Subject  98,  21 images.
% Subject  99,  24 images.
% Subject 100,  22 images.
% Subject 101,  64 images.
% Subject 102,  21 images.
% Subject 103,  71 images.
% Subject 104,  45 images.
% Subject 105,  70 images.
% Subject 106,  48 images.
% Subject 107,  56 images.
% Subject 108,  70 images.
% Subject 109,  48 images.
% Subject 110,  72 images.
% Subject 111,  67 images.




%%%%%%%%%%%%%
% archive
%%%%%%%%%%%%%

% 
% function sublist = find_sublist_from_dir(singletrial_dir)
%     items = dir(singletrial_dir);
%     sub_dirs = items([items.isdir] & startsWith({items.name}, 'sub-'));
%     sublist = {sub_dirs.name}';
% end
% 
% function unique_bids = unique_combination_bids(filenames)
%     %UNIQUE_COMBINATION_BIDS Extracts and finds unique combinations of subject, session, and run IDs from filenames.
%     %
%     % This function processes a cell array of filenames and extracts unique combinations 
%     % of subject (sub), session (ses), and run identifiers. These identifiers are expected 
%     % to be embedded in the filenames following a specific format: 'sub-XXXX_ses-YY_run-ZZ', 
%     % where 'XXXX', 'YY', and 'ZZ' are placeholders for the actual numbers.
%     %
%     %   Parameters
%     %   ----------
%     %   filenames : cell array of strings
%     %           Filenames from which to extract the sub/ses/run information. Each filename should 
%     %           follow the format 'sub-XXXX_ses-YY_run-ZZ'.
%     %
%     %   Returns
%     %   -------
%     %   unique_bids : double array
%     %           An array with unique combinations of sub/ses/run. Each row represents a unique 
%     %           combination, with columns corresponding to 'sub', 'ses', and 'run' in that order.
%     %
%     %   Example
%     %   -------
%     %           filenames = {'sub-001_ses-01_run-01_image.nii', 'sub-001_ses-02_run-01_image.nii', ...};
%     %           uniqueCombinations = unique_combination_bids(filenames);
%     %
%     %   See also REGEXP, UNIQUE
%     pattern = 'sub-(\d+)_ses-(\d+)_run-(\d+)'; % Regular expression pattern  
%     tempArray = zeros(length(filenames), 3); % Temporary array to store extracted numbers
% 
%     for i = 1:length(filenames)
%         matches = regexp(filenames{i}, pattern, 'tokens'); 
%         % If a match is found, extract the first match
%         if ~isempty(matches)
%             match = matches{1};
%             % Convert the matched strings to numbers and store in tempArray
%             tempArray(i, 1) = str2double(match{1}); % sub
%             tempArray(i, 2) = str2double(match{2}); % ses
%             tempArray(i, 3) = str2double(match{3}); % run
%         end
%     end
%     % Find unique rows in tempArray
%     unique_bids = unique(tempArray, 'rows'); 
% end
% 
% function beh_df = load_beh_based_on_bids(beh_dir, unique_bids)
%     
%     finalTable = table();
%     % Loop through each unique bid
%     for i = 1:size(unique_bids, 1)
%         % Extract sub, ses, and run for each row
%         sub = unique_bids(i, 1);
%         ses = unique_bids(i, 2);
%         run = unique_bids(i, 3);
% 
%         fname_pattern = sprintf('sub-%04d_ses-%02d_task-cue_*run-%02d_runtype-*_events.tsv', sub, ses, run);
%         filepathPattern = fullfile(beh_dir, sprintf('sub-%04d', sub), sprintf('ses-%02d', ses), fname_pattern);        
%         files = dir(filepathPattern); % Find files that match the pattern
%         
%         % Check if any file was found
%         if isempty(files)
%             fprintf('No file found for sub-%04d ses-%02d run-%02d\n', sub, ses, run);
%             continue;
%         end
%         
%         % Assuming you want to load the first matching file
%         tsvFilePath = fullfile(files(1).folder, files(1).name);
% 
%         % Load the .tsv file
%         % You can use readtable, tdfread, or any other appropriate function depending on your file structure
%         tsvData = readtable(tsvFilePath, 'FileType', 'text', 'Delimiter', '\t');
%         finalTable = [finalTable; tsvData];
%         % Display the final table
%         disp(finalTable);
% 
%     end
% end
% 
% function merge_beh_nii = merge_on_nifti_beh(singletrial_basefname, beh_df)
%     %MERGE_ON_NIFTI_BEH Merges behavior data frame with NIfTI file list based on matching filenames.
%     %
%     %   Function to filter a behavior data frame (table), keeping only those
%     %   rows where the 'singletrial_fname' field matches any filename in the
%     %   provided list of NIfTI filenames.
%     %
%     %   The function loops through the list of base filenames extracted from
%     %   NIfTI files and checks each one against the 'singletrial_fname' column
%     %   in the behavior data frame. Rows in the data frame with a matching
%     %   filename are retained.
%     %
%     %   Usage:
%     %   merge_beh_nii = merge_on_nifti_beh(singletrial_basefname, beh_df)
%     %
%     %   Parameters
%     %   ----------
%     %   singletrial_basefname - Cell array of strings, where each element is a base filename
%     %               extracted from a NIfTI file.
%     %   beh_df     - Table containing behavioral data, including a column named
%     %               'singletrial_fname' which contains filenames to be matched
%     %               against the NIfTI filenames.
%     %
%     %   Returns
%     %   -------
%     %   merge_beh_nii - Table containing only the rows from the original
%     %                    behavior data frame that have a corresponding match
%     %                    in the provided NIfTI filenames.
%     %
%     %   Example:
%     %   singletrial_basefname = {'filename1.nii', 'filename2.nii', ...};
%     %   beh_df = table(...); % Behavior data frame with 'singletrial_fname' column
%     %   merge_beh_nii = merge_on_nifti_beh(singletrial_basefname, beh_df);
%     %
%     %   See also: strcmp
% 
%     % Initialize a logical vector for matches
%     matches = false(size(beh_df, 1), 1);
% 
%     % Loop through each filename in singletrial_basefname
%     for i = 1:numel(singletrial_basefname)
%         % Update matches where there's a corresponding element in beh_df.singletrial_fname
%         matches = matches | strcmp(singletrial_basefname{i}, beh_df.singletrial_fname);
%     end
% 
%     % Filter beh_df to retain only rows where there was a match
%     merge_beh_nii = beh_df(matches, :);
% end
% 
% function modifiedTable = remove_missing_behvalues(inputTable, columnName)
%     %REMOVE_MISSING_VALUES Removes rows with missing values in a specified column of a table.
%     %
%     %   Function to filter a table by removing rows where the specified column has missing values (NaN).
%     %
%     %   Usage:
%     %   modifiedTable = remove_missing_values(inputTable, columnName)
%     %
%     %   Inputs:
%     %   inputTable - A MATLAB table.
%     %   columnName - A string specifying the column name to check for missing values.
%     %
%     %   Outputs:
%     %   modifiedTable - The modified table with rows removed where the specified column had missing values.
% 
%     % Check if the specified column contains NaN values
%     if isnumeric(inputTable.(columnName))
%         nanRows = isnan(inputTable.(columnName));
%     elseif iscategorical(inputTable.(columnName))
%         nanRows = isundefined(inputTable.(columnName));
%     else
%         error('Column data type not supported for missing value check.');
%     end
% 
%     % Remove rows where the specified column is NaN
%     modifiedTable = inputTable(~nanRows, :);
% end
% 
% function modifiedTable = contrast_coding(inputTable, columnName, newColumnName, mappingDict)
%     %MAP_STRINGS_TO_NUMERIC_ADD_COLUMN Converts specific string values in a table column to corresponding numeric values and adds them as a new column.
%     %
%     %   This function takes a table, a column name, a new column name, and a mapping dictionary. It converts the string values
%     %   in the specified column of the table to numeric values based on the provided mapping dictionary and appends these
%     %   numeric values as a new column in the table.
%     %
%     %   Usage:
%     %   modifiedTable = map_strings_to_numeric_add_column(inputTable, columnName, newColumnName, mappingDict)
%     %
%     %   Inputs:
%     %   inputTable    - A MATLAB table.
%     %   columnName    - A string specifying the column name to be processed.
%     %   newColumnName - A string specifying the name of the new column to be added to the table.
%     %   mappingDict   - A container.Map (or a struct) mapping string values to numeric values.
%     %                   e.g. mappingDict = containers.Map({'low_cue', 'high_cue'}, [-1, 1]);
%     %   Outputs:
%     %   modifiedTable - The modified table with the new column of numeric values.
% 
%     % Ensure the column exists in the table
%     if ~ismember(columnName, inputTable.Properties.VariableNames)
%         error('Specified column does not exist in the table.');
%     end
% 
%     % Initialize an array to store numeric values
%     numericValues = zeros(height(inputTable), 1);
% 
%     % Process each row in the table
%     for i = 1:height(inputTable)
%         strValue = char(inputTable.(columnName){i});
%         if isKey(mappingDict, strValue)
%             numericValues(i) = mappingDict(strValue);
%         else
%             error('Unmapped string value encountered: %s', strValue);
%         end
%     end
% 
%     % Add numeric values as a new column to the table
%     inputTable.(newColumnName) = numericValues;
% 
%     % Return the modified table
%     modifiedTable = inputTable;
% end
% 
% function T = add_fullpath_column(T, baseDir, sub, existingColName, newColName)
%     %ADD_FULLPATH_COLUMN Appends a base directory path and subject folder to filenames in a table column to create full paths.
%     %
%     %   This function takes a table and appends a base directory and subject-specific
%     %   folder paths to each filename in a specified column, then adds these full
%     %   paths as a new column in the table.
%     %
%     %   Usage:
%     %   T = add_fullpath_column(T, baseDir, sublist, existingColName, newColName)
%     %
%     %   Inputs:
%     %   T             - A MATLAB table containing the existing filename column.
%     %   baseDir       - A string representing the base directory path.
%     %   sublist       - A cell array of subject folder names.
%     %   existingColName - The name of the existing column containing the filenames.
%     %   newColName    - The name for the new column to be added to the table.
%     %
%     %   Outputs:
%     %   T             - The modified table with the new full path column added.
% 
%     % Check if the existing column name is valid
%     if ~ismember(existingColName, T.Properties.VariableNames)
%         error('The specified existing column name does not exist in the table.');
%     end
% 
%     % Initialize a cell array to store the full path filenames
%     fullpathFnames = cell(height(T), 1);
% 
%     % Loop through each row in T
%     for i = 1:height(T)
%         % Concatenate to form the full path
%         fullpathFnames{i} = fullfile(baseDir, sub, T.(existingColName){i});
%     end
% 
%     % Add the full path filenames as a new column in T
%     T.(newColName) = fullpathFnames;
% end
