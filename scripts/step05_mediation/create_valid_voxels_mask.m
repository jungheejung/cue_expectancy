%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% run to extract single trial file paths
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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
        matlab_moduledir = '/dartfs-hpc/rc/lab/C/CANlab/modules';
        main_dir = '/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_cue';
%         singletrial_dir = fullfile(main_dir, 'analysis','fmri','nilearn','singletrial');
        singletrial_dir = '/dartfs-hpc/scratch/f0042x1/singletrial_smooth';
        beh_dir = fullfile(main_dir, 'data', 'beh', 'beh03_bids');
        NPS_fname = fullfile(main_dir, 'analysis/fmri/nilearn/deriv01_signature/rampupdown/signature-NPSpos_sub-all_runtype-pvc_event-stimulus.tsv');
        graymatter_mask = fullfile(matlab_moduledir, 'CanlabCore/CanlabCore/canlab_canonical_brains/Canonical_brains_surfaces/gray_matter_mask.nii');
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
sub = cell(1, length(sublist));
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
    disp(strcat('starting ', sublist{s}))%strcat('sub-',sprintf('%04d', sublist(s)))))
    
    singletrial_flist = dir(fullfile(singletrial_dir, sublist{s},...
        strcat(sublist{s}, '*_runtype-', task, '*_event-',eventlist{e},'*.nii')   ));
%                         strcat('smooth-6mm_',sublist{s}, '*_runtype-', task, '*_event-',eventlist{e},'*.nii')   ));
    if ~isempty(singletrial_flist)
    singletrial_fldr = {singletrial_flist.folder}; fname = {singletrial_flist.name};
    singletrial_files = strcat(singletrial_fldr,'/', fname)';
        

    % step 02: identify number of unique sub/ses/runs and load behavioral files
    unique_bids = unique_combination_bids(singletrial_files);

    % step 03: merge the behavioral files and niftifiles based on intersection
    %          Extract the base filenames from the full path filenames
    beh_df = load_beh_based_on_bids(beh_dir, unique_bids);
    combinedTable = innerjoin(npsdf, beh_df, 'Keys', 'singletrial_fname');
    singletrial_basefname = cellfun(@(x) extractAfter(x, max(strfind(x, filesep))), singletrial_files, 'UniformOutput', false);
%     if dir_location== 'discovery'
% %     Define the prefix and merge dataframe based on single trial filenames
%         prefix = 'smooth-6mm_';
%         combinedTable.singletrial_fname = strcat(prefix, combinedTable.singletrial_fname);
%     end
    merge_beh_nii = merge_on_nifti_beh(singletrial_basefname, combinedTable);

    % step 04: if any of the Y regressors have NA values, the mediation will fail. Remove these instances
    metadf_clean = remove_missing_behvalues(merge_beh_nii, 'outcomerating');

    % step 05: contrast code the X regressors. Originally, they are strings in my behavioral dataframe
    cue_contrast_mapper = containers.Map({'low_cue', 'high_cue'}, [-1, 1]);
    stim_contrast_mapper = containers.Map({'low_stim', 'med_stim', 'high_stim'}, [-1, 0, 1]);
    metadf_cue = contrast_coding(metadf_clean, 'cuetype', 'cue_contrast', cue_contrast_mapper);
    metadf_con = contrast_coding(metadf_cue, 'stimtype', 'stim_contrast', stim_contrast_mapper);

    % step 06: the mediation code expects the full path of nifti files. Construct this based on the basename columns
    mediation_df = add_fullpath_column(metadf_con, singletrial_dir, sublist{s}, 'singletrial_fname', 'fullpath_fname');

    % step 07: final step! construct the X, M, Y cells for the mediation analysis  
    X{1,s} = mediation_df.stim_contrast;
    M{1,s} = mediation_df.fullpath_fname;
    Y{1,s} = mediation_df.outcomerating;
    cov{1,s} = mediation_df.cue_contrast;
    l2m(s) = mean(mediation_df.NPSpos); 
    sub{1,s} = sublist{s}; 

    end
end
end

fprintf('Size of X: %s\n', mat2str(size(X)));
fprintf('Size of Y: %s\n', mat2str(size(Y)));
fprintf('Size of M: %s\n', mat2str(size(M)));
fprintf('Size of cov: %s\n', mat2str(size(cov)));
fprintf('Size of l2m: %s\n', mat2str(size(l2m)));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% identify good voxels vs. voxels to exclude
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 1. fmri_data object per subject
% - load single trials. 
% - identify non-zero non-NAN voxels ("good voxel")
% - Each participant must have at last 10 trials worth of data for a given voxel. 
% - if a voxel is zero or NaN for more than 10 trials, we drop this voxel. 
% - This results in a binary mask per participant
% - With every participant's binary mask identified, I apply a group-level threshold;
% - 50 subjects must have at least good voxels.
%
% subjectwise inclusion
sub_data = fmri_data(M{1});
threshold = 10;
mask_double = zeros(length(sub_data.dat ), length(M));
for i = 1:length(M)

    if ~isempty(M{i})
        disp('has data')
    % % Count of NON 0 or NON NaN values per row
        countsNonZeroNaN = sum(sub_data.dat ~= 0 & ~isnan(sub_data.dat), 2);
        voxels_to_include = countsNonZeroNaN > threshold;
        mask_double(:,i) = voxels_to_include;
    else
        disp(strcat('this subject ', num2str(i), ' has no data'));
        continue

    end
end
% group level inclusion
mask = sum(mask_double,2);
threshold_sub=2;
final_mask = mask > threshold_sub;
graymatter = fmri_data(which(graymatter_mask));
resampled_gray = graymatter.resample_space(sub_data);
new_graymatter_mask = (resampled_gray.dat .* final_mask) > .001;
resampled_gray.dat = new_graymatter_mask;
write(resampled_gray, 'fname', './new_graymattermask_thres2.nii', 'overwrite');

test = fmri_data('./new_graymattermask_thres2.nii');
