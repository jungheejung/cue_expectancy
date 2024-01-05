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

addpath(genpath('./utils'));

% Define the case variable
dir_location = 'local';  % 'local' vs. 'discovery' as needed
switch dir_location
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
    % step 01: glob all the nifti files
    % step 02: identify number of unique sub/ses/runs and load behavioral files
    % step 03: merge the behavioral files and niftifiles based on intersection
    %          Extract the base filenames from the full path filenames
    % step 04: if any of the Y regressors have NA values, the mediation will fail. Remove these instances
    % step 05: contrast code the X regressors. Originally, they are strings in my behavioral dataframe
    % step 06: the mediation code expects the full path of nifti files. Construct this based on the basename columns
    % step 07: final step! construct the X, M, Y cells for the mediation analysis
    disp(strcat('starting ', sublist{s}))%strcat('sub-',sprintf('%04d', sublist(s)))))
    
    singletrial_flist = dir(fullfile(singletrial_dir, sublist{s},...
        strcat(sublist{s}, '*_runtype-', task, '*_event-',eventlist{e},'*.nii')   ));
%                         strcat('smooth-6mm_',sublist{s}, '*_runtype-', task, '*_event-',eventlist{e},'*.nii')   ));
    if ~isempty(singletrial_flist)
    singletrial_fldr = {singletrial_flist.folder}; fname = {singletrial_flist.name};
    singletrial_files = strcat(singletrial_fldr,'/', fname)';
    
    unique_bids = unique_combination_bids(singletrial_files);

    beh_df = load_beh_based_on_bids(beh_dir, unique_bids);

    combinedTable = innerjoin(npsdf, beh_df, 'Keys', 'singletrial_fname');
    singletrial_basefname = cellfun(@(x) extractAfter(x, max(strfind(x, filesep))), singletrial_files, 'UniformOutput', false);
%     if dir_location== 'discovery'
% %     Define the prefix and merge dataframe based on single trial filenames
%         prefix = 'smooth-6mm_';
%         combinedTable.singletrial_fname = strcat(prefix, combinedTable.singletrial_fname);
%     end
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

% if Y has empty rows, remove them from all other
[X_test, Y_test, M_test, cov_test, l2m_test] = filter_empty_cells(X, Y, M, cov, l2m);
M = convert_cell2char(M_test);

% mean center l2m
mean_values = mean(l2m_test);
l2m_meancentered= l2m_test - mean_values;

% ----------------------------
% z score across participants
% ----------------------------

num_participants = numel(Y_test);
% Aggregate all data into one matrix (assuming each participant's data is a column vector)
all_data = vertcat(Y_test{:});

% Compute the mean and standard deviation across all data
mean_data = mean(all_data); 
std_data = std(all_data);

% Z-score all data using the computed mean and standard deviation
zscored_Y = cell(num_participants, 1);

for i = 1:num_participants
    participant_data = Y_test{i}; % Access the data for the current participant
    zscored_Y{i} = (participant_data - mean_data) ./ std_data;
end

% ----------------------------
% plot
% ----------------------------
% Create a histogram
% figure
% histogram(all_data, 'BinWidth', 0.5);  % Adjust the BinWidth as needed
% title('Histogram Example');
% xlabel('X-Axis Label');
% ylabel('Frequency');
% 
% figure
% zscored_ = vertcat(zscored_data{:});
% histogram(zscored_, 'BinWidth', 0.5);  % Adjust the BinWidth as needed
% title('Histogram Example');
% xlabel('X-Axis Label');
% ylabel('Frequency');


fprintf('step 2. X, Y, M fully set up');

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
brain_check = fmri_data('/Users/h/Documents/projects_local/sandbox/smooth-6mm_sub-0064_ses-01_run-02_runtype-pain_event-stimulus_trial-000_cuetype-low_stimintensity-med.nii');
montage(brain_check)
% -------------------------------------------------------------------------
% start mediation analysis
% -------------------------------------------------------------------------

addpath(genpath(fullfile(matlab_moduledir, 'CanlabCore')));
addpath(genpath(fullfile(matlab_moduledir,'Neuroimaging_Pattern_Masks')));
addpath(genpath(fullfile(matlab_moduledir,'MediationToolbox')));
addpath(genpath(fullfile(matlab_moduledir, 'spm12')));
rmpath(genpath(fullfile(matlab_moduledir,'spm12/external/fieldtrip')));
rmpath(genpath(fullfile(matlab_moduledir,'spm12/external/fieldtrip/external/stats')));

fprintf('Size of X: %s\n', mat2str(size(X)));
fprintf('Size of zscored_y: %s\n', mat2str(size(zscored_Y)));
fprintf('Size of M: %s\n', mat2str(size(M)));
fprintf('Size of cov: %s\n', mat2str(size(cov)));
fprintf('Size of l2m_centered: %s\n', mat2str(size(l2m_meancentered)));

M = M_test;
X = X_test;
Y = zscored_Y;
cov = cov_test;
l2m_meancentered = l2m_test;
SETUP.mask = which(graymatter_mask);
SETUP.preprocX = 0;
SETUP.preprocY = 0;
SETUP.preprocM = 0;
SETUP.wh_is_mediator = 'M';
% SETUP.data.covs = cov
% SETUP.data.L2M = l2m_meancentered';

mediation_brain_multilevel(X, Y, M, SETUP, 'nopreproc', 'covs', cov, 'L2M', l2m_meancentered'); %, 'boot', 'bootsamples', 1000);
mediation_brain_multilevel(X, Y, M, SETUP, 'nopreproc', 'covs', cov, 'boot', 'bootsamples', 1000);% 'L2M', l2m_meancentered',
mediation_brain_multilevel(X, Y, M, SETUP, 'nopreproc', 'boot', 'bootsamples', 1000);
SETUP = mediation_brain_corrected_threshold('fdr');

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

% Assuming X and Y are cell arrays containing double arrays
num_cells_X = numel(X);
num_cells_Y = numel(Y);
num_cells_M = numel(M);
num_cells_cov = numel(cov);
sizes_X = zeros(num_cells_X, 2); % Matrix to store sizes of X
sizes_Y = zeros(num_cells_Y, 2); % Matrix to store sizes of Y
sizes_M = zeros(num_cells_M, 2);
sizes_cov = zeros(num_cells_cov, 2);
% Loop through X and Y to get the sizes of the double arrays
for i = 1:num_cells_X
    sizes_X(i, :) = size(X{i});
end

for i = 1:num_cells_Y
    sizes_Y(i, :) = size(Y{i});
end

for i = 1:num_cells_M
    sizes_M(i, :) = size(M{i});
end

for i = 1:num_cells_cov
    sizes_cov(i, :) = size(cov{i});
end
all(all(sizes_Y(:,1) == sizes_X(:,1)))
all(all(sizes_Y(:,1) == sizes_M(:,1)))
all(all(sizes_Y(:,1) == sizes_cov(:,1)))

